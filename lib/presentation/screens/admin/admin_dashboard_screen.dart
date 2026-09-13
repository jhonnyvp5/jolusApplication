import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/colors.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final stats = await _dbService.getAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        title: Text(
          'PANEL ADMINISTRATIVO',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: JolusColors.darkBlue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Ventas',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              _buildMainStats(),
              const SizedBox(height: 24),
              _buildStatusSummary(),
              const SizedBox(height: 32),
              Text(
                'Acciones Rápidas',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Productos',
                      color: JolusColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Pedidos',
                      color: JolusColors.warning,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Productos Más Vendidos',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JolusColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              _buildTopProducts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    final double totalSales = double.tryParse(_stats['totalSales']?.toString() ?? '0') ?? 0.0;
    final int totalOrders = int.tryParse(_stats['totalOrders']?.toString() ?? '0') ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Ventas Totales',
            value: '\$${totalSales.toStringAsFixed(2)}',
            icon: Icons.monetization_on_outlined,
            color: JolusColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Pedidos',
            value: totalOrders.toString(),
            icon: Icons.shopping_cart_outlined,
            color: JolusColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummary() {
    final Map<String, dynamic> statusCount = _stats['statusCount'] is Map 
        ? Map<String, dynamic>.from(_stats['statusCount']) 
        : {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Estados',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem('Pendiente', statusCount['pendiente'] ?? 0, JolusColors.warning),
              _buildStatusItem('Pagado', statusCount['pagado'] ?? 0, JolusColors.primary),
              _buildStatusItem('Completado', statusCount['completado'] ?? 0, JolusColors.success),
              _buildStatusItem('Cancelado', statusCount['cancelado'] ?? 0, JolusColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: JolusColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final dynamic rawTop = _stats['topProducts'];
    final List<dynamic> topProducts = (rawTop is List) ? rawTop : [];

    if (topProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No hay datos de ventas aún',
            style: GoogleFonts.inter(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topProducts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final Map<String, dynamic> item = Map<String, dynamic>.from(topProducts[index] ?? {});
          final String name = item['nombre'] ?? item['name'] ?? 'Producto desconocido';
          final int count = int.tryParse(item['total']?.toString() ?? item['cantidad']?.toString() ?? item['count']?.toString() ?? '0') ?? 0;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: JolusColors.surfaceLow,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: JolusColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            trailing: Text(
              '$count vendidos',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
            ),
          );
        },
      ),
    );
  }
}