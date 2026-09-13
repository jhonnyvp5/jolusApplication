import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class HomeHero extends StatelessWidget {
  final VoidCallback onCatalogTap;

  const HomeHero({super.key, required this.onCatalogTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: 280, // Reducido aún más de 320 a 280 para ahorrar espacio
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F1FF), Colors.white],
        ),
      ),
      child: Stack(
        children: [
          // Imagen del fondo con curva a la derecha
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size.width * 0.5,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=600'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(140),
                ),
              ),
            ),
          ),
          
          // Capa de color para suavizar la imagen
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size.width * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(140),
                ),
              ),
            ),
          ),
          
          // Imagen de Laptop - Tamaño reducido
          Positioned(
            right: -10,
            bottom: 15,
            child: Image.network(
              'https://pngimg.com/uploads/laptop/laptop_PNG5933.png',
              height: 150,
              width: size.width * 0.55,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          
          // Contenido de texto
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo JOLUS
                Image.asset(
                  'assets/images/jolus_logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: size.width * 0.5,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: JolusColors.darkBlue,
                        height: 1.1,
                      ),
                      children: [
                        const TextSpan(text: 'Tecnología\nque impulsa\n'),
                        TextSpan(
                          text: 'tu mundo',
                          style: TextStyle(color: JolusColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: size.width * 0.4,
                  child: Text(
                    'Soluciones tecnológicas a tu medida',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: JolusColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onCatalogTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JolusColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Ver productos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Texto manuscrito "Tu aliado..." más pequeño
          Positioned(
            right: 10,
            bottom: 30,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: Text(
                  'Tu aliado\ntecnológico',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.caveat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: JolusColors.darkBlue,
                    height: 0.9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
