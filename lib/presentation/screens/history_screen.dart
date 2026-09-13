import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/order_model.dart';
import '../../core/services/database_service.dart';
import 'notifications_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Filtrar los pedidos localmente
    final orders = orderProvider.orders.where((order) {
      final status = order.estado.toLowerCase();
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Completados') return status == 'completado';
      if (_selectedFilter == 'Pendientes') return status == 'pendiente' || status == 'en revisión';
      if (_selectedFilter == 'Anulados') return status == 'anulado' || status == 'cancelado';
      return true;
    }).toList();

    final double totalSpent = orderProvider.orders
        .where((o) => o.estado.toLowerCase() == 'completado')
        .fold(0, (sum, item) => sum + item.total);

    final int completedCount = orderProvider.orders.where((o) => o.estado.toLowerCase() == 'completado').length;
    final int pendingCount = orderProvider.orders.where((o) {
      final status = o.estado.toLowerCase();
      return status == 'pendiente' || status == 'en revisión';
    }).length;
    final int cancelledCount = orderProvider.orders.where((o) => o.estado.toLowerCase() == 'anulado' || o.estado.toLowerCase() == 'cancelado').length;

    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: JolusColors.surfaceLow,
                    backgroundImage: userProvider.photoUrl != null 
                        ? NetworkImage(userProvider.photoUrl!) 
                        : null,
                    child: userProvider.photoUrl == null 
                        ? const Icon(Icons.person, color: JolusColors.primary, size: 24) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'HOLA, ${userProvider.name} ${userProvider.subname}'.toUpperCase().trim(),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            color: JolusColors.darkBlue,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Revisa tu historial de pedidos',
                          style: GoogleFonts.inter(
                            color: JolusColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              final unreadCount = notifProvider.unreadCount;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: JolusColors.primary),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userProvider.isGuest
          ? _buildGuestView()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard('Total Invertido', '\$${totalSpent.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  _buildStatCard('Completados', '$completedCount', color: Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard('Pendientes', '$pendingCount', color: Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard('Anulados', '$cancelledCount', color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Anulados'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // History List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Todos' 
                                ? 'Aún no tienes pedidos registrados.'
                                : 'No hay pedidos con el estado "$_selectedFilter".',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: orders.map((order) {
                        final String displayId = order.id ?? '---';
                        
                        // Determinar color por estado
                        Color statusColor = Colors.orange;
                        final statusLower = order.estado.toLowerCase();
                        if (statusLower == 'completado') statusColor = Colors.green;
                        if (statusLower == 'anulado' || statusLower == 'cancelado') statusColor = Colors.red;
                        if (statusLower == 'en revisión') statusColor = Colors.blue;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildHistoryItem(
                            order: order,
                            title: 'Pedido #$displayId',
                            date: "${order.fecha.day}/${order.fecha.month}/${order.fecha.year}",
                            price: '\$${order.total.toStringAsFixed(2)}',
                            status: order.estado,
                            statusColor: statusColor,
                            icon: Icons.shopping_bag_outlined,
                            actionText: 'Ver detalles >',
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: JolusColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 80,
                color: JolusColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Historial Reservado',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: JolusColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inicia sesión para llevar un control de tus compras, ver estados de envío y descargar tus comprobantes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JolusColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: JolusColors.primary),
                ),
                child: const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: JolusColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color ?? JolusColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? JolusColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? JolusColors.primary : Colors.grey.withValues(alpha: 0.2)),
          boxShadow: isSelected ? [
            BoxShadow(color: JolusColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) async {
    final dbService = DatabaseService();
    Map<String, dynamic>? receiptData;
    if (order.id != null) {
      receiptData = await dbService.getPaymentReceipt(order.id!);
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detalles del Pedido',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID del Pedido:', '#${order.id}'),
                _buildDetailRow('Fecha:', "${order.fecha.day}/${order.fecha.month}/${order.fecha.year} ${order.fecha.hour}:${order.fecha.minute.toString().padLeft(2, '0')}"),
                _buildDetailRow(
                  'Estado:', 
                  order.estado.toUpperCase(), 
                  valueColor: order.estado.toLowerCase() == 'completado' 
                    ? Colors.green 
                    : (order.estado.toLowerCase() == 'anulado' || order.estado.toLowerCase() == 'cancelado' 
                        ? Colors.red 
                        : (order.estado.toLowerCase() == 'en revisión' ? Colors.blue : Colors.orange)),
                ),
                const Divider(height: 32),
                _buildDetailRow('Método de Pago:', order.metodoPago ?? 'No especificado'),
                _buildDetailRow('Dirección:', order.direccionEntrega ?? 'No especificada'),
                _buildDetailRow('Teléfono:', order.telefonoContacto ?? 'No especificado'),
                if (order.comentario != null && order.comentario!.isNotEmpty)
                  _buildDetailRow('Comentario:', order.comentario!),
                if (order.observaciones != null && order.observaciones!.isNotEmpty)
                  _buildDetailRow('Observaciones:', order.observaciones!),
                const Divider(height: 32),
                if (receiptData != null && receiptData['url_comprobante'] != null) ...[
                  Text(
                    'DATOS DEL COMPROBANTE:',
                    style: GoogleFonts.inter(
                      fontSize: 12, 
                      color: JolusColors.primary, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Banco:', receiptData['nombre_banco'] ?? 'No especificado'),
                  _buildDetailRow('Nro. Referencia:', receiptData['numero_comprobante'] ?? 'No especificado'),
                  _buildDetailRow('Titular:', receiptData['nombre_completo'] ?? 'No especificado'),
                  const SizedBox(height: 12),
                  Text(
                    'Imagen del Comprobante (Toca para ampliar):',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              InteractiveViewer(
                                child: Image.network(
                                  receiptData!['url_comprobante'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          receiptData['url_comprobante'],
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const SizedBox(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, color: Colors.grey),
                                Text('Error al cargar comprobante', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL:',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: JolusColors.primary),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: JolusColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: JolusColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: valueColor ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required OrderModel order,
    required String title,
    required String date,
    required String price,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JolusColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JolusColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: JolusColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: JolusColors.primary,
                ),
              ),
              InkWell(
                onTap: () => _showOrderDetails(context, order),
                child: Text(
                  actionText,
                  style: GoogleFonts.inter(
                    color: JolusColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
