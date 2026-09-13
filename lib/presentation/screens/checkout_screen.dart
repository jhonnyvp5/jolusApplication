import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/database_service.dart';
import 'payment_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isProcessing = false;
  bool _isGettingLocation = false;
  double _ivaPercent = 12.0;
  double _logisticaCost = 15.0;
  bool _isLoadingConfig = true;

  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
    '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _addressController.text = Provider.of<UserProvider>(context, listen: false).address;
  }

  Future<void> _loadConfig() async {
    try {
      final config = await DatabaseService().getAdminProfile();
      if (config != null && mounted) {
        setState(() {
          if (config.iva != null) _ivaPercent = config.iva!;
          if (config.logistica != null) _logisticaCost = config.logistica!;
          _isLoadingConfig = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingConfig = false);
      }
    } catch (e) {
      debugPrint('Error cargando configuración: $e');
      if (mounted) setState(() => _isLoadingConfig = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Los servicios de ubicación están desactivados.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permisos de ubicación denegados.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Los permisos de ubicación están permanentemente denegados.';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";
        if (mounted) {
          setState(() {
            _addressController.text = address;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $e')),
      );
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _handleConfirmOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (userProvider.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para realizar un pedido')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final subtotal = cart.totalAmount;
      final ivaAmount = subtotal * (_ivaPercent / 100);
      final total = subtotal + ivaAmount + _logisticaCost;
      
      // Combinar fecha y hora para el objeto DateTime
      final timeParts = _selectedTime.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      int minute = int.parse(hourMin[1]);
      if (timeParts[1] == 'PM' && hour < 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      final orderDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      // 1. TEXTO CONCATENADO (Fecha + Hora con formato específico) para la columna 'comentario'
      String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
      
      final String dayName = capitalize(DateFormat('EEEE', 'es').format(_selectedDate));
      final String monthName = capitalize(DateFormat('MMMM', 'es').format(_selectedDate));
      final String year = DateFormat('yyyy').format(_selectedDate);
      final String time = DateFormat('HH:mm').format(orderDate);

      final String combinedDateTime = "Agendado para $dayName, ${_selectedDate.day} de $monthName, $year a las $time";

      final String? orderId = await orderProvider.placeOrder(
        userId: userProvider.id,
        total: total,
        items: cart.items.values.toList(),
        fecha: orderDate,
        direccion: _addressController.text.isNotEmpty ? _addressController.text : 'Dirección no especificada',
        metodoPago: 'Transferencia/Depósito',
        telefono: userProvider.phone,
        comentario: combinedDateTime, // Se guarda en 'comentario'
        observaciones: _commentController.text, // Se guarda en 'observaciones'
      );

      if (!mounted) return;

      if (orderId != null) {
        _showSuccessDialog(orderId, total);
      } else {
        _showErrorDialog('El servidor no devolvió un ID de pedido. Intenta de nuevo.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al procesar: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String orderId, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle_rounded, color: Color(0xFF1F6FE5), size: 70),
            const SizedBox(height: 24),
            Text('¡Pedido Generado!', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF00236F))),
            const SizedBox(height: 12),
            Text('Tu pedido #$orderId ha sido creado. Procedamos al pago.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey[600])),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PaymentDetailScreen(orderId: orderId, total: total)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FE5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Ir al Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Atención'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Finalizar Pedido', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF00236F))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00236F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Fecha del Evento'),
            const SizedBox(height: 16),
            _buildDateCard(),
            const SizedBox(height: 32),
            _buildHeader('Dirección del Evento'),
            const SizedBox(height: 16),
            _buildAddressField(),
            const SizedBox(height: 32),
            _buildHeader('Hora de Inicio'),
            const SizedBox(height: 16),
            _buildTimeGrid(),
            const SizedBox(height: 32),
            _buildHeader('Instrucciones u Observaciones'),
            const SizedBox(height: 16),
            _buildCommentBox(),
            const SizedBox(height: 40),
            _buildSummaryCard(cart),
            const SizedBox(height: 32),
            _buildConfirmButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF00236F),
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF1F6FE5), size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('d/M/yyyy').format(_selectedDate),
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const Spacer(),
          TextButton(
            onPressed: _selectDate,
            child: const Text('Cambiar', style: TextStyle(color: Color(0xFF1F6FE5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildAddressField() {
    return Column(
      children: [
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Ej: Calle Principal y Av. Central',
            prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF1F6FE5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _isGettingLocation ? null : _getCurrentLocation,
          child: Row(
            children: [
              _isGettingLocation 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, size: 20, color: Color(0xFF1F6FE5)),
              const SizedBox(width: 8),
              Text(
                'Usar mi ubicación actual',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F6FE5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTime == time;
        return InkWell(
          onTap: () => setState(() => _selectedTime = time),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1F6FE5) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? const Color(0xFF1F6FE5) : Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentBox() {
    return TextField(
      controller: _commentController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Escribe aquí cualquier detalle adicional...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart) {
    if (_isLoadingConfig) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final subtotal = cart.totalAmount;
    final iva = subtotal * (_ivaPercent / 100);
    final total = subtotal + iva + _logisticaCost;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', subtotal.toStringAsFixed(2)),
          const SizedBox(height: 12),
          _summaryRow('IVA (${_ivaPercent.toStringAsFixed(0)}%)', iva.toStringAsFixed(2)),
          const SizedBox(height: 12),
          _summaryRow('Logística', _logisticaCost.toStringAsFixed(2)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total a Pagar', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF00236F))),
              Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF1F6FE5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        Text('\$$value', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleConfirmOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F6FE5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Confirmar Pedido', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
