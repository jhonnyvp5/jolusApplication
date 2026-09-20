import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/services/database_service.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/colors.dart';
import '../widgets/home_hero.dart';
import '../widgets/event_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(_updateScrollArrows);
    // Verificar estado inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  void _updateScrollArrows() {
    if (_categoryController.hasClients) {
      final canScrollLeft = _categoryController.offset > 5;
      final canScrollRight = _categoryController.offset < _categoryController.position.maxScrollExtent - 5;
      if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
        setState(() {
          _canScrollLeft = canScrollLeft;
          _canScrollRight = canScrollRight;
        });
      }
    }
  }

  void _scrollCategories(bool right) {
    final target = right 
      ? _categoryController.offset + 200 
      : _categoryController.offset - 200;
    _categoryController.animateTo(
      target.clamp(0.0, _categoryController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.removeListener(_updateScrollArrows);
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.read<NavigationProvider>();
    final dbService = DatabaseService();

    return Scaffold(
      backgroundColor: JolusColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BARRA SUPERIOR (Logo + Buscador + Notif + Carrito) - Compactada
            Container(
              padding: const EdgeInsets.only(top: 45, left: 15, right: 15, bottom: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1FF),
              ),
              child: Row(
                children: [
                  // Buscador
                  Expanded(
                    child: Container(
                      height: 45, // Reducido de 50 a 45
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  navProvider.setSearchQuery(value.trim());
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Buscar productos, marcas...',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                navProvider.setSearchQuery(_searchController.text.trim());
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: JolusColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildTopIconButton(
                    icon: Icons.notifications_rounded,
                    hasBadge: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                  ),
                  const SizedBox(width: 12),
                  _buildCartButton(context),
                ],
              ),
            ),

            // 2. HERO SECTION
            HomeHero(onCatalogTap: () => navProvider.setSelectedIndex(1)),

            const SizedBox(height: 12), // Reducido de 15

            // 3. SECCIÓN NOTICIAS Y COMUNICADOS
            _buildSectionHeader('Noticias y comunicados', () {}, showSeeAll: false),
            const SizedBox(height: 8), // Reducido de 10
            _buildNewsSlider(),
            
            const SizedBox(height: 15), // Reducido de 20

            // 4. BENEFICIOS
            _buildBenefitsSection(),
            
            const SizedBox(height: 15), // Reducido de 20

            // 5. CATEGORÍAS
            _buildSectionHeader('Categorías', () => navProvider.setSelectedIndex(1)),
            const SizedBox(height: 8), // Reducido de 10
            _buildCategoriesGrid(),
            
            const SizedBox(height: 15), // Reducido de 20

            // 6. PRODUCTOS DESTACADOS
            _buildSectionHeader('Productos destacados', () => navProvider.setSelectedIndex(1)),
            const SizedBox(height: 8), // Reducido de 10
            _buildProductsList(dbService),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIconButton({required IconData icon, bool hasBadge = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: JolusColors.primary, size: 26),
            if (hasBadge)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: JolusColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    return InkWell(
      onTap: () => context.read<NavigationProvider>().setSelectedIndex(2),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart_rounded, color: JolusColors.primary, size: 24),
            if (cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: JolusColors.error, shape: BoxShape.circle),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: JolusColors.darkBlue,
            ),
          ),
          if (showSeeAll)
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    'Ver todas',
                    style: GoogleFonts.inter(
                      color: JolusColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: JolusColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsSlider() {
    final dbService = DatabaseService();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbService.getAnnouncements(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final news = snapshot.data!;
        // Por ahora mostramos el primero, podrías implementar un PageView
        final item = news.first;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: JolusColors.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Contenido de texto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 130, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: JolusColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            (item['etiqueta'] ?? 'COMUNICADO').toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['titulo'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: JolusColors.darkBlue,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['contenido'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: JolusColors.textSecondary.withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Megáfono decorativo semi-oculto
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(Icons.campaign_rounded, color: JolusColors.primary, size: 60),
                    ),
                  ),
                  // Imagen de la derecha
                  Positioned(
                    right: 8,
                    top: 8,
                    bottom: 8,
                    width: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(item['imagen_url'] ?? 'https://images.unsplash.com/photo-1590650516494-0c8e4a4dd67e?q=80&w=400'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: JolusColors.primary, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(news.length, (index) {
                final bool isActive = index == 0; // Por ahora el primero es activo
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: isActive ? 16 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive ? JolusColors.primary : const Color(0xFFE0E0E0),
                    shape: isActive ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isActive ? BorderRadius.circular(10) : null,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {'icon': Icons.local_shipping_rounded, 'text': 'Envíos a\ntodo el país'},
      {'icon': Icons.verified_user_rounded, 'text': 'Compra\nsegura'},
      {'icon': Icons.headset_mic_rounded, 'text': 'Soporte\ntécnico experto'},
      {'icon': Icons.credit_card_rounded, 'text': 'Múltiples\nmedios de pago'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: benefits.map((b) => Expanded(
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(b['icon'] as IconData, color: JolusColors.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                b['text'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: JolusColors.darkBlue,
                  height: 1.1,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final cats = [
      {'label': 'Laptops', 'icon': Icons.laptop_mac_rounded, 'color': const Color(0xFFE3F2FD)},
      {'label': 'Celulares', 'icon': Icons.smartphone_rounded, 'color': const Color(0xFFE8F5E9)},
      {'label': 'Accesorios', 'icon': Icons.headphones_rounded, 'color': const Color(0xFFFFEBEE)},
      {'label': 'Impresoras', 'icon': Icons.print_rounded, 'color': const Color(0xFFFFF3E0)},
      {'label': 'Monitores', 'icon': Icons.monitor_rounded, 'color': const Color(0xFFF3E5F5)},
      {'label': 'Redes', 'icon': Icons.router_rounded, 'color': const Color(0xFFE0F7FA)},
      {'label': 'Soporte', 'icon': Icons.settings_rounded, 'color': const Color(0xFFEFEBE9)},
    ];

    return SizedBox(
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.builder(
            controller: _categoryController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final cat = cats[index];
              final color = cat['color'] as Color;
              return Container(
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<NavigationProvider>().setCategory(cat['label'] == 'Soporte' ? 'Soporte Técnico' : cat['label'] as String);
                        context.read<NavigationProvider>().setSelectedIndex(1);
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat['icon'] as IconData, color: JolusColors.darkBlue, size: 26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cat['label'] as String,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: JolusColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Botón Izquierda
          if (_canScrollLeft)
            Positioned(
              left: 5,
              child: _buildScrollArrow(false),
            ),
            
          // Botón Derecha
          if (_canScrollRight)
            Positioned(
              right: 5,
              child: _buildScrollArrow(true),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollArrow(bool right) {
    return GestureDetector(
      onTap: () => _scrollCategories(right),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          right ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          color: JolusColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProductsList(DatabaseService db) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.isLoading && productsProvider.products.isEmpty) {
          return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
        }
        final products = productsProvider.products;
        if (products.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: Text('No hay productos disponibles')),
          );
        }
        return SizedBox(
          height: 310,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) => EventCard(service: products[index]),
          ),
        );
      },
    );
  }
}
