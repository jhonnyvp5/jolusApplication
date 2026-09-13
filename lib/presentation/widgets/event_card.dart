import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/colors.dart';

class EventCard extends StatelessWidget {
  final ServiceModel service;

  const EventCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final isGuest = context.watch<UserProvider>().isGuest;
    
    final double discount = service.nombre.contains('Laptop') ? 15 : (service.nombre.contains('iPhone') ? 10 : 0);
    final double oldPrice = service.precio / (1 - (discount / 100));

    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor de Imagen
              Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JolusColors.background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Hero(
                    tag: 'product_${service.id}',
                    child: service.imagen != null && service.imagen!.isNotEmpty
                      ? Image.network(service.imagen!, fit: BoxFit.contain)
                      : const Icon(Icons.image_not_supported_outlined, size: 30, color: Colors.grey),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: JolusColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10, color: JolusColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${service.precio.toStringAsFixed(0)}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: JolusColors.primary,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '\$${oldPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Botón Agregar
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          cart.addItem(
                            service.id,
                            service.nombre,
                            service.precio,
                            service.imagen ?? '',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${service.nombre} agregado al carrito'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: JolusColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JolusColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          disabledBackgroundColor: Colors.grey.shade200,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.shopping_cart_rounded, size: 14),
                            SizedBox(width: 6),
                            Text('Agregar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          
          // Badge Descuento
          if (discount > 0)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: JolusColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${discount.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          
          // Favorito
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border_rounded, size: 16, color: JolusColors.darkBlue),
            ),
          ),
        ],
      ),
    );
  }
}
