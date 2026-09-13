import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/colors.dart';
import '../screens/service_detail_screen.dart';

class ServiceDetailCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedServiceDetailCard(service: service);
  }
}

class _AnimatedServiceDetailCard extends StatefulWidget {
  final ServiceModel service;
  const _AnimatedServiceDetailCard({required this.service});

  @override
  State<_AnimatedServiceDetailCard> createState() => _AnimatedServiceDetailCardState();
}

class _AnimatedServiceDetailCardState extends State<_AnimatedServiceDetailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: widget.service),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0)
            ..multiply(Matrix4.diagonal3Values(_isHovered ? 1.01 : 1.0, _isHovered ? 1.01 : 1.0, 1.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.05),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Hero(
                      tag: 'service_detail_image_${widget.service.id}',
                      child: Image.network(
                        widget.service.imagen ?? 'https://via.placeholder.com/400',
                        height: 150, // Reducido de 180 a 150 para que no sea tan grande
                        width: double.infinity,
                        fit: BoxFit.contain, // Cambiado a contain para que la imagen se vea completa sin cortes
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.grey[100],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Text(
                        widget.service.categoria.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: JolusColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16), // Reducido el padding para compactar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.nombre,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JolusColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.service.descripcion,
                      maxLines: 1, // Reducido a 1 línea para ahorrar espacio
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Disponible: ${widget.service.cantidad}',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.service.precio.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: JolusColors.primary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                              widget.service.id,
                              widget.service.nombre,
                              widget.service.precio,
                              widget.service.imagen ?? '',
                            );
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.service.nombre} añadido al carrito'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 1500),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JolusColors.primary,
                            foregroundColor: Colors.white,
                            elevation: _isHovered ? 4 : 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'Añadir al carrito', // Cambiado de 'Reservar' a 'Añadir al carrito'
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
