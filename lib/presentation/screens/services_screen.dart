import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/services/database_service.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../widgets/filter_chip.dart';
import '../widgets/service_detail_card.dart';
import 'notifications_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ScrollController _categoryController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(_updateScrollArrows);
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
    _categoryController.removeListener(_updateScrollArrows);
    _categoryController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Todos', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFFF5F5F5)},
    {'label': 'Laptops', 'icon': Icons.laptop_mac_rounded, 'color': const Color(0xFFE3F2FD)},
    {'label': 'Celulares', 'icon': Icons.smartphone_rounded, 'color': const Color(0xFFE8F5E9)},
    {'label': 'Accesorios', 'icon': Icons.headphones_rounded, 'color': const Color(0xFFFFEBEE)},
    {'label': 'Impresoras', 'icon': Icons.print_rounded, 'color': const Color(0xFFFFF3E0)},
    {'label': 'Monitores', 'icon': Icons.monitor_rounded, 'color': const Color(0xFFF3E5F5)},
    {'label': 'Redes', 'icon': Icons.router_rounded, 'color': const Color(0xFFE0F7FA)},
    {'label': 'Soporte', 'icon': Icons.settings_rounded, 'color': const Color(0xFFEFEBE9)},
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final selectedService = navProvider.selectedCategory;

    return Scaffold(
      backgroundColor: JolusColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 70,
            titleSpacing: 0,
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
                                color: JolusColors.primary,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '¿Qué servicio necesitas hoy?',
                              style: GoogleFonts.inter(
                                color: Colors.grey[500],
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
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final cartCount = cart.itemCount;
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: JolusColors.primary),
                        if (cartCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: JolusColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$cartCount',
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
                    onPressed: () => context.read<NavigationProvider>().setSelectedIndex(2),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Catálogo de Servicios',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00236F),
                  ),
                ),
                const SizedBox(height: 24),
                // Categorías mejoradas con el mismo diseño del Home
                SizedBox(
                  height: 125,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ListView.builder(
                        controller: _categoryController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final label = cat['label'] as String;
                          final color = cat['color'] as Color;
                          final internalName = label == 'Soporte' ? 'Soporte Técnico' : label;
                          final isSelected = selectedService == internalName;

                          return Container(
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => navProvider.setCategory(internalName),
                                  borderRadius: BorderRadius.circular(22),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: isSelected ? color : Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected 
                                            ? color.withValues(alpha: 0.6)
                                            : color.withValues(alpha: 0.3),
                                          blurRadius: isSelected ? 15 : 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isSelected ? JolusColors.primary : color.withValues(alpha: 0.5),
                                        width: isSelected ? 2 : 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : color.withValues(alpha: 0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          cat['icon'] as IconData, 
                                          color: isSelected ? JolusColors.primary : JolusColors.darkBlue, 
                                          size: 26
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  label,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                    color: isSelected ? JolusColors.primary : JolusColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      if (_canScrollLeft)
                        Positioned(
                          left: -5,
                          child: _buildScrollArrow(false),
                        ),
                        
                      if (_canScrollRight)
                        Positioned(
                          right: -5,
                          child: _buildScrollArrow(true),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Lista de Productos en Tiempo Real (vía ProductsProvider)
                Consumer<ProductsProvider>(
                  builder: (context, productsProvider, child) {
                    if (productsProvider.isLoading && productsProvider.products.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: JolusColors.primary),
                        ),
                      );
                    }

                    final allProducts = productsProvider.products;
                    final searchQuery = navProvider.searchQuery;

                    var filteredProducts = selectedService == 'Todos'
                        ? allProducts
                        : allProducts.where((p) => 
                            p.servicio.toLowerCase() == selectedService.toLowerCase()
                          ).toList();

                    if (searchQuery.isNotEmpty) {
                      filteredProducts = filteredProducts.where((p) => 
                        p.nombre.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        p.descripcion.toLowerCase().contains(searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            searchQuery.isNotEmpty 
                              ? 'No se encontraron productos para "$searchQuery"'
                              : 'No hay productos disponibles en esta sección.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.grey)),
                        ),
                      );
                    }

                    return Column(
                      children: filteredProducts.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ServiceDetailCard(
                          service: product,
                        ),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ]),
            ),
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
}
