import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../widgets/main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  final String username;
  final bool isNewAccount;

  const WelcomeScreen({super.key, required this.username, required this.isNewAccount});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _mainController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fondo Degradado Base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFF0F5FF)],
                ),
              ),
            ),
          ),
          
          // 2. Ondas y Elementos Visuales "Galácticos"
          Positioned.fill(
            child: CustomPaint(
              painter: GalacticBackgroundPainter(),
            ),
          ),

          // 3. Contenido Principal
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 4),
                
                // Icono Central con Arco Animado
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo exterior muy tenue
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE1E9F5).withValues(alpha: 0.5), width: 1),
                      ),
                    ),
                    // Arco Giratorio
                    RotationTransition(
                      turns: _rotationController,
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: CustomPaint(
                          painter: ArcIndicatorPainter(),
                        ),
                      ),
                    ),
                    // Glow Interior
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F6FE5).withValues(alpha: 0.12),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Círculo Azul con Check
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F6FE5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                    // Destello pequeño lateral (como en la imagen)
                    Positioned(
                      left: 10,
                      top: 40,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 45),
                
                // Textos
                Text(
                  widget.isNewAccount ? '¡Excelente!' : '¡Hola de nuevo!',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    color: Colors.black45,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isNewAccount ? 'Cuenta creada' : 'Bienvenido',
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00236F),
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00236F).withValues(alpha: 0.65),
                    letterSpacing: 2.8,
                  ),
                ),
                
                const SizedBox(height: 55),
                
                // Barra de Progreso Minimalista
                Container(
                  width: 90,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E9F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F6FE5)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Footer con Icono Sync
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: _rotationController,
                      child: const Icon(Icons.sync_rounded, size: 15, color: Colors.black26),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cargando tu experiencia...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GalacticBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Ondas blancas circulares (Glows)
    paint.color = const Color(0xFFE8F0FF).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 250, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.4), 180, paint);

    // Onda Azul Inferior con curva orgánica
    final bluePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1F6FE5), Color(0xFF5A9BFF)],
      ).createShader(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));

    final path = Path();
    path.moveTo(0, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.75, size.width, size.height * 0.68);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, bluePaint);

    // Estrellas/Puntos de luz
    final starPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.85), 1.5, starPaint);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.92), 2.2, starPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.95), 1.2, starPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.9), 1.0, starPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 2.0, starPaint);
    
    // Onda Blanca sutil sobre el azul
    final whiteWavePaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.72);
    path2.quadraticBezierTo(size.width * 0.5, size.height * 0.85, size.width, size.height * 0.75);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, whiteWavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ArcIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi / 2.5;
    
    final paint = Paint()
      ..color = const Color(0xFF1F6FE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    
    // Punto al final del arco
    final double endAngle = startAngle + sweepAngle;
    final double x = size.width / 2 + (size.width / 2) * math.cos(endAngle);
    final double y = size.height / 2 + (size.height / 2) * math.sin(endAngle);
    
    canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = const Color(0xFF1F6FE5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
