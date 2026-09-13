import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/services/database_service.dart';
import '../../core/services/email/email_service.dart';
import '../../core/models/payment_receipt_model.dart';
import '../../core/models/bank_account_model.dart';
import '../../core/theme/colors.dart';
import '../widgets/main_navigation.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String orderId;
  final double total;

  const PaymentDetailScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final _dbService = DatabaseService();
  final _emailService = EmailService();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _bankController = TextEditingController();
  final _emailController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  
  XFile? _imageFile;
  bool _isUploading = false;
  List<BankAccountModel> _bankAccounts = [];
  bool _isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Pre-llenar datos del usuario
    final user = Provider.of<UserProvider>(context, listen: false);
    String fullName = user.name;
    if (user.subname.isNotEmpty) {
      fullName += ' ${user.subname}';
    }
    _nameController.text = fullName;
    _emailController.text = user.email;

    // 2. Cargar cuentas bancarias desde el Backend Custom MySQL/PHP
    try {
      final accounts = await _dbService.getBankAccounts();
      if (!mounted) return;
      setState(() {
        _bankAccounts = accounts;
        _isLoadingBanks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingBanks = false);
      debugPrint('Error cargando cuentas: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _bankController.dispose();
    _emailController.dispose();
    _receiptNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, suba una foto del comprobante.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = Provider.of<UserProvider>(context, listen: false);
      final cart = Provider.of<CartProvider>(context, listen: false);
      
      final bytes = await _imageFile!.readAsBytes();
      final extension = _imageFile!.path.split('.').last;
      
      // 1. Subir el archivo al bucket
      final publicUrl = await _dbService.uploadReceiptFile(
        widget.orderId,
        bytes,
        extension,
      );

      if (publicUrl == null) throw Exception('Error al subir imagen');

      // 2. Registrar en la base de datos
      final receipt = PaymentReceiptModel(
        orderId: widget.orderId,
        userId: user.id,
        amount: widget.total,
        receiptUrl: publicUrl,
        receiptNumber: _receiptNumberController.text.trim(),
        fullName: _nameController.text.trim(),
        cedula: _idController.text.trim(),
        bankName: _bankController.text.trim(),
        email: _emailController.text.trim(),
        paymentDate: DateTime.now(),
      );

      await _dbService.uploadPaymentReceipt(receipt);

      // 2.5 Crear notificación en la base de datos para el usuario
      await _dbService.createNotification(
        userId: user.id,
        title: 'Reporte de Pago Recibido',
        message: 'Hemos recibido tu comprobante por \$${widget.total.toStringAsFixed(2)}. El pedido #${widget.orderId} está en revisión.',
        type: 'order',
        data: {'order_id': widget.orderId},
      );

      // 3. Enviar correo de confirmación
      try {
        await _emailService.sendPaymentConfirmationEmail(
          receipt: receipt,
          customerEmail: _emailController.text.trim(),
          orderId: widget.orderId,
          receiptImage: File(_imageFile!.path),
        );
      } catch (e) {
        debugPrint('Error enviando correo (no bloqueante): $e');
        // No bloqueamos el flujo principal si el correo falla
      }

      // 4. Actualizar el estado del pedido a 'en revisión' o similar
      if (!mounted) return;
      await Provider.of<OrderProvider>(context, listen: false)
          .updateOrderStatus(widget.orderId, 'en revisión');

      cart.clear();
      
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JolusColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: JolusColors.success, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Pago Reportado!',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hemos recibido tu comprobante. Tu pedido entrará en proceso de verificación (1-3 días hábiles).',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JolusColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Entendido', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JolusColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: JolusColors.error, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al reportar',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ocurrió un error al reportar tu pago: $e',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JolusColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Reintentar', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<bool> _onWillPop() async {
    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Cancelar pedido?',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: JolusColors.darkBlue),
        ),
        content: Text(
          'Si regresas ahora, el pedido se cancelará y deberás agendarlo nuevamente.',
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Mantener', style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: JolusColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Aceptar y Cancelar', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      try {
        // Usamos el OrderProvider para borrar de DB y de la UI al mismo tiempo
        await Provider.of<OrderProvider>(context, listen: false).cancelOrder(widget.orderId);
      } catch (e) {
        debugPrint('Error al cancelar pedido: $e');
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: JolusColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: JolusColors.darkBlue),
            onPressed: () async {
              final bool shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Detalles de Pago',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: JolusColors.darkBlue,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuentas Bancarias',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingBanks)
                const Center(child: CircularProgressIndicator())
              else if (_bankAccounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('No hay cuentas bancarias registradas actualmente.'),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _bankAccounts.map((bank) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _bankController.text = bank.bancoNombre;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Seleccionado: ${bank.bancoNombre}'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: JolusColors.primary,
                            ),
                          );
                        },
                        child: _buildBankCard(
                          bankName: bank.bancoNombre,
                          holderName: bank.titularNombre,
                          accountNumber: bank.numeroCuenta,
                          ruc: bank.ruc ?? 'N/A',
                          email: bank.email ?? 'N/A',
                          type: bank.tipoCuenta,
                          color: Color(int.parse(bank.colorHex.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportar Pago',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: JolusColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildReportField('Nombre Completo', 'Ej: Juan Pérez', controller: _nameController),
                    const SizedBox(height: 20),
                    _buildReportField('Número de Identificación', 'Cédula o Pasaporte', controller: _idController),
                    const SizedBox(height: 20),
                    _buildReportField('Número de Comprobante', 'Ej: 12345678', controller: _receiptNumberController),
                    const SizedBox(height: 20),
                    _buildReportField('Nombre del Banco', 'Banco emisor', controller: _bankController),
                    const SizedBox(height: 20),
                    _buildReportField('Correo Electrónico', 'usuario@ejemplo.com', controller: _emailController),
                    const SizedBox(height: 20),
                    _buildReportField('Monto Pagado', '\$ ${widget.total.toStringAsFixed(2)}', enabled: false),
                    const SizedBox(height: 24),
                    Text(
                      'Recibo de Pago',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: JolusColors.lightBlue,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _imageFile != null ? JolusColors.success : JolusColors.primary.withValues(alpha: 0.2), 
                            style: BorderStyle.solid
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _imageFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, 
                              color: _imageFile != null ? JolusColors.success : JolusColors.darkBlue, 
                              size: 32
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _imageFile != null ? 'Comprobante seleccionado' : 'Subir comprobante',
                              style: GoogleFonts.inter(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: _imageFile != null ? JolusColors.success : JolusColors.darkBlue
                              ),
                            ),
                            if (_imageFile != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _imageFile!.name,
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Soporta JPG, PNG (Máx. 5MB)',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JolusColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: JolusColors.darkBlue, width: 4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_rounded, color: JolusColors.darkBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información importante',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: JolusColors.darkBlue),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Asegúrese de que toda la información sea correcta antes de enviarla. Su pago se procesará en un plazo de 1-3 días hábiles tras la verificación.',
                            style: GoogleFonts.inter(fontSize: 11, color: JolusColors.darkBlue.withValues(alpha: 0.7), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JolusColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: JolusColors.primary.withValues(alpha: 0.4),
                  ),
                  child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Enviar Reporte de Pago',
                        style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String holderName,
    required String accountNumber,
    required String ruc,
    required String email,
    required String type,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bankName, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Icon(Icons.account_balance, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text('NOMBRE DEL TITULAR', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(holderName, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          Text('NÚMERO DE CUENTA', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(accountNumber, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RUC: $ruc', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
                  Text(email, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportField(String label, String hint, {IconData? suffixIcon, TextEditingController? controller, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: Colors.grey[400]) : null,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}
