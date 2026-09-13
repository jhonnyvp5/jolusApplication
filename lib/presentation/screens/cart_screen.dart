import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/notification_provider.dart';
import 'checkout_screen.dart';
import 'notifications_screen.dart';
import 'auth/login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFF4F6FC),
                    backgroundImage: userProvider.photoUrl != null 
                        ? NetworkImage(userProvider.photoUrl!) 
                        : null,
                    child: userProvider.photoUrl == null 
                        ? const Icon(Icons.person, color: Color(0xFF1F6FE5), size: 24) 
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
                            color: JolusColors.darkBlue,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Revisa tu carrito de compras',
                          style: GoogleFonts.inter(
                            color: JolusColors.textSecondary,
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
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            tooltip: 'Vaciar carrito',
            onPressed: cart.items.isEmpty ? null : () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('¿Vaciar carrito?', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    content: const Text('¿Estás seguro de que deseas eliminar todos los servicios del carrito?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancelar', style: GoogleFonts.manrope(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Vaciar', style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              final unreadCount = notifProvider.unreadCount;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: JolusColors.darkBlue),
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
        ],
      ),
      body: cart.items.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Tu carrito está vacío', style: GoogleFonts.manrope(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<NavigationProvider>().setSelectedIndex(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JolusColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ir a explorar'),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: cart.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mi Carrito',
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: JolusColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Revisa tus servicios seleccionados para agendar.',
                            style: GoogleFonts.inter(
                              color: JolusColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    final item = cart.items.values.toList()[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCartItem(
                        id: item.id,
                        title: item.title,
                        subtitle: 'Servicio Jolus', 
                        price: item.price.toStringAsFixed(2),
                        quantity: item.quantity,
                        imageUrl: item.imageUrl,
                        cart: cart,
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutPanel(context, cart),
            ],
          ),
    );
  }

  Widget _buildCartItem({
    required String id, 
    required String title, 
    required String subtitle, 
    required String price, 
    required int quantity, 
    required String imageUrl,
    required CartProvider cart,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl, 
              width: 70, 
              height: 70, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15, color: JolusColors.darkBlue)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => cart.removeItem(id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.removeSingleItem(id),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.remove, size: 16, color: JolusColors.primary),
                            ),
                          ),
                          Text('$quantity', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: JolusColors.darkBlue)),
                          GestureDetector(
                            onTap: () => cart.addItem(id, title, double.parse(price), imageUrl),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.add, size: 16, color: JolusColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('\$$price', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: JolusColors.primary, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Estimado',
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: JolusColors.darkBlue),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final userProvider = context.read<UserProvider>();
                  if (userProvider.isGuest) {
                    _showGuestDialog(context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JolusColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Continuar a la Reserva',
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acción Requerida', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(
          'Debes iniciar sesión para realizar una reserva.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
