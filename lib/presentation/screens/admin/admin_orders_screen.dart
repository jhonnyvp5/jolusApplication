import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  String _filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dbService.getAllOrdersAdmin();
      setState(() {
        _orders = data.map((json) => OrderModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar pedidos admin: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      if (!mounted) return;
      await _dbService.updateOrderStatus(orderId, newStatus);
      if (!mounted) return;
      _fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido $orderId actualizado a $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el estado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<OrderModel> filteredOrders = _filterStatus == 'Todos'
        ? _orders
        : _orders.where((o) => o.estado.toLowerCase() == _filterStatus.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        title: Text('GESTIÓN DE PEDIDOS', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: JolusColors.darkBlue,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchOrders, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Todos', 'Pendiente', 'Pagado', 'Completado', 'Cancelado'].map((status) {
          bool isSelected = _filterStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (val) => setState(() => _filterStatus = status),
              selectedColor: JolusColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor = _getStatusColor(order.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text('Pedido #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(order.fecha)} - \$${order.total.toStringAsFixed(2)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(order.estado.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.person, 'Usuario ID', order.userId),
                _infoRow(Icons.location_on, 'Dirección', order.direccionEntrega ?? 'N/A'),
                _infoRow(Icons.phone, 'Teléfono', order.telefonoContacto ?? 'N/A'),
                _infoRow(Icons.payment, 'Método', order.metodoPago ?? 'N/A'),
                const Divider(),
                const Text('Cambiar Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['pendiente', 'pagado', 'completado', 'cancelado'].map((st) {
                    return ActionChip(
                      label: Text(st),
                      onPressed: () => _updateStatus(order.id!, st),
                      backgroundColor: JolusColors.surfaceLow,
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente': return JolusColors.warning;
      case 'pagado': return JolusColors.primary;
      case 'completado': return JolusColors.success;
      case 'cancelado': return JolusColors.error;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No se encontraron pedidos', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
