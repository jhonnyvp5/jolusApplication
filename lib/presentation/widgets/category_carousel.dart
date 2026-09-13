import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/theme/colors.dart';
import '../../core/providers/navigation_provider.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({super.key});

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _categories = [
    {'label': 'Buffet', 'image': 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=500'},
    {'label': 'Coctelería', 'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=500'},
    {'label': 'Entretenimiento', 'image': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=500'},
    {'label': 'Animaciones', 'image': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=500'},
    {'label': 'Decoraciones', 'image': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=500'},
    {'label': 'Mobiliario', 'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?q=80&w=500'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _categories.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(
            label: _categories[index]['label']!,
            imageUrl: _categories[index]['image']!,
            onTap: () {
              context.read<NavigationProvider>().setCategory(_categories[index]['label']!);
            },
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String label;
  final String imageUrl;
  final VoidCallback onTap;
  const CategoryCard({
    super.key, 
    required this.label, 
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          transform: Matrix4.translationValues(0.0, _isHovered ? -10.0 : 0.0, 0.0)
            ..multiply(Matrix4.diagonal3Values(_isHovered ? 1.03 : 1.0, _isHovered ? 1.03 : 1.0, 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 25 : 12,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.6),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 10.0,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isHovered)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            JolusColors.primary.withValues(alpha: 0),
                            JolusColors.primary,
                            JolusColors.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
