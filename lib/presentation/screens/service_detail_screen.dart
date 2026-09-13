import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import 'auth/login_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: JolusColors.darkBlue),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Hero(
                  tag: 'service_${service.id}',
                  child: Image.network(
                    service.imagen ?? 'https://via.placeholder.com/800',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: JolusColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.categoria.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: JolusColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '\$${service.precio.toInt()}',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: JolusColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.nombre,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: JolusColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Servicio de ${service.servicio}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: JolusColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Descripción',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: JolusColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.descripcion,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: JolusColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoRow(Icons.inventory_2_outlined, 'Disponibilidad', '${service.cantidad} unidades'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              final userProvider = context.read<UserProvider>();
              if (userProvider.isGuest) {
                _showGuestDialog(context);
                return;
              }
              
              context.read<CartProvider>().addItem(
                service.id,
                service.nombre,
                service.precio,
                service.imagen ?? '',
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Añadido al carrito'),
                  backgroundColor: JolusColors.darkBlue,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JolusColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: JolusColors.primary.withValues(alpha: 0.4),
            ),
            child: Text(
              'Añadir al Carrito',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: JolusColors.primary),
        const SizedBox(width: 12),
        Text(
          '$title:',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: JolusColors.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.inter(color: JolusColors.darkBlue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modo Invitado', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(
          'Debes iniciar sesión para añadir servicios al carrito.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JolusColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Iniciar Sesión', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
