import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/theme/colors.dart';
import '../screens/home_screen.dart';
import '../screens/services_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != 0) {
        context.read<NavigationProvider>().setSelectedIndex(widget.initialIndex);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ServicesScreen(),
    const CartScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final cartProvider = context.watch<CartProvider>();
    final int cartItemsCount = cartProvider.itemCount;

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 75 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_rounded, 'Inicio', navProvider),
                _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_rounded, 'Categorías', navProvider),
                _buildNavItem(2, Icons.shopping_cart_rounded, Icons.shopping_cart_rounded, 'Carrito', navProvider, badgeCount: cartItemsCount),
                _buildNavItem(3, Icons.history_rounded, Icons.history_rounded, 'Historial', navProvider),
                _buildNavItem(4, Icons.person_rounded, Icons.person_rounded, 'Perfil', navProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    final navProvider = context.read<NavigationProvider>();
    final userProvider = context.read<UserProvider>();
    final orderProvider = context.read<OrderProvider>();

    navProvider.setSelectedIndex(index);

    if (index == 3 && userProvider.id.isNotEmpty) {
      orderProvider.fetchOrders(userProvider.id);
    }
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label, NavigationProvider provider, {int badgeCount = 0}) {
    final isSelected = provider.selectedIndex == index;
    final color = isSelected ? JolusColors.primary : JolusColors.textLight;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 26,
                  color: color,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
