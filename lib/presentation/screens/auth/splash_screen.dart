import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/user_provider.dart';
import 'login_screen.dart';
import '../../widgets/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _checkSession();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint('Error solicitando permisos: $e');
    }
  }

  Future<void> _checkSession() async {
    try {
      // Dar tiempo mínimo para ver la animación
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;

      // Obtenemos el userProvider actual de forma segura para comprobar la sesión persistida
      final userProvider = context.read<UserProvider>();
      debugPrint('DEBUG: Sesión local actual ID: ${userProvider.id}');
      
      if (!mounted) return;

      if (userProvider.id.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error en SplashScreen: $e');
      // En caso de error, intentamos ir al Login de todos modos
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF001D3D),
              Color(0xFF000814),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Orbits with glowing dots
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildOrbit(radius: 130, rotation: _controller.value * 2 * math.pi, dots: 3, opacity: 0.15),
                    _buildOrbit(radius: 180, rotation: -_controller.value * 1.5 * math.pi, dots: 2, opacity: 0.1),
                    _buildOrbit(radius: 240, rotation: _controller.value * 0.8 * math.pi, dots: 4, opacity: 0.08),
                  ],
                );
              },
            ),
            
            // Main Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Logo Card
                Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: JolusColors.primary.withValues(alpha: 0.5),
                        blurRadius: 60,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/jolus_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.business,
                        size: 120,
                        color: Color(0xFF00236F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Brand Name
                Text(
                  'Jolus Services',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'PREMIUM EVENT MANAGEMENT',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                
                const SizedBox(height: 120),
                
                // Custom Glowing Progress Bar
                Container(
                  width: 280,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          // Simular progreso suave
                          double progress = (_controller.value * 2.5).clamp(0.0, 1.0);
                          return Container(
                            width: 280 * progress,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [JolusColors.primary, Colors.white],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: JolusColors.primary.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Loading text with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync, size: 18, color: Colors.white60),
                    const SizedBox(width: 12),
                    Text(
                      'Cargando experiencia premium...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbit({
    required double radius, 
    required double rotation, 
    int dots = 0,
    required double opacity,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: List.generate(dots, (index) {
            final double angle = (index * 2 * math.pi) / dots;
            return Positioned(
              left: radius + radius * math.cos(angle) - 4,
              top: radius + radius * math.sin(angle) - 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: JolusColors.primary,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
