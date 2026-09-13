import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/models/social_network_model.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/services/database_service.dart';
import '../widgets/main_navigation.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInfoExpanded = false;
  bool _isSocialExpanded = false;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _subnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final DatabaseService _dbService = DatabaseService();

  List<SocialNetworkModel> _socialNetworks = [];
  bool _isLoadingSocial = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _subnameController = TextEditingController(text: user.subname);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _fetchSocialLinks();
  }

  Future<void> _fetchSocialLinks() async {
    setState(() => _isLoadingSocial = true);
    try {
      final networks = await _dbService.getSocialNetworks();

      if (mounted) {
        setState(() {
          _socialNetworks = networks;
          _isLoadingSocial = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando redes sociales: $e');
      if (mounted) setState(() => _isLoadingSocial = false);
    }
  }

  Future<void> _launchURL(String url) async {
    debugPrint('DEBUG: Intentando abrir URL original: "$url"');
    if (url == '...' || url == 'No disponible' || url.isEmpty) {
      debugPrint('DEBUG: URL inválida o vacía, abortando.');
      return;
    }
    
    String finalUrl = url.trim();
    
    if (RegExp(r'^\+?[0-9\s\-]{7,20}$').hasMatch(finalUrl) || finalUrl.contains('wa.me')) {
      if (!finalUrl.startsWith('http')) {
        final cleanNumber = finalUrl.replaceAll(RegExp(r'[^0-9]'), '');
        finalUrl = 'https://wa.me/$cleanNumber';
      }
    } 
    else if (!finalUrl.startsWith('http')) {
      if (finalUrl.contains('facebook.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.contains('instagram.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.startsWith('@')) {
        finalUrl = 'https://instagram.com/${finalUrl.substring(1)}';
      } else {
        finalUrl = 'https://$finalUrl';
      }
    }

    debugPrint('DEBUG: URL procesada para abrir: "$finalUrl"');

    final messenger = ScaffoldMessenger.of(context);
    try {
      final Uri uri = Uri.parse(finalUrl);
      bool launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        debugPrint('DEBUG: No se pudo abrir con aplicación externa, intentando modo plataforma...');
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        throw 'No se pudo lanzar la URL';
      }
    } catch (e) {
      debugPrint('ERROR: Fallo total al abrir la URL: $e');
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace. Verifica si tienes la app instalada o la URL es válida.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Subiendo imagen...'), duration: Duration(seconds: 2)),
        );
      }

      final bytes = await image.readAsBytes();
      final extension = path.extension(image.path).replaceAll('.', '');
      
      final publicUrl = await DatabaseService().uploadUserPhoto(
        userProvider.id,
        bytes,
        extension,
      );

      if (publicUrl != null && mounted) {
        await userProvider.updatePhotoUrl(publicUrl);
        messenger.showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      debugPrint('Error al cambiar foto: $e');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final photoUrl = userProvider.photoUrl;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        backgroundColor: JolusColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFFE8F1FF),
          elevation: 0,
          toolbarHeight: 75,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Consumer<UserProvider>(
            builder: (context, user, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                            ? const Icon(Icons.person, color: JolusColors.primary, size: 20)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'HOLA, ${user.name} ${user.subname}'.toUpperCase().trim(),
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: JolusColors.primary,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gestiona tu información personal',
                            style: GoogleFonts.inter(
                              color: JolusColors.textSecondary,
                              fontSize: 10,
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
            _buildHeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(width: 8),
            _buildCartButton(context),
            const SizedBox(width: 15),
          ],
        ),
        body: userProvider.isGuest
    ? _buildGuestView()
    : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
      // Perfil Header
      Center(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: JolusColors.surfaceLow,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : const NetworkImage('https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: JolusColors.darkBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${userProvider.name} ${userProvider.subname}',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: JolusColors.darkBlue,
              ),
            ),
            Text(
              _emailController.text,
              style: GoogleFonts.inter(
                color: JolusColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // Información Personal (Acordeón)
      _AnimatedCardWrapper(
        child: Column(
          children: [
            ListTile(
              onTap: () => setState(() => _isInfoExpanded = !_isInfoExpanded),
              leading: const Icon(Icons.person_outline, color: JolusColors.primary),
              title: Text(
                'Información Personal',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: JolusColors.darkBlue,
                ),
              ),
              trailing: Icon(
                _isInfoExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey[400],
              ),
            ),
            if (_isInfoExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoField('Nombres', _nameController, _isEditing),
                    const SizedBox(height: 16),
                    _buildInfoField('Apellidos', _subnameController, _isEditing),
                    const SizedBox(height: 16),
                    _buildInfoField('Correo', _emailController, _isEditing),
                    const SizedBox(height: 16),
                    _buildInfoField('Teléfono', _phoneController, _isEditing),
                    const SizedBox(height: 16),
                    _buildInfoField('Dirección', _addressController, _isEditing),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: _isEditing ? Colors.red : JolusColors.primary),
                            ),
                            child: Text(
                              _isEditing ? 'Cancelar' : 'Editar Información',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: _isEditing ? Colors.red : JolusColors.primary,
                              ),
                            ),
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                final messenger = ScaffoldMessenger.of(context);
                                await userProvider.updateProfile(
                                  name: _nameController.text,
                                  subname: _subnameController.text,
                                  email: _emailController.text,
                                  phone: _phoneController.text,
                                  address: _addressController.text,
                                );
                                if (mounted) {
                                  setState(() {
                                    _isEditing = false;
                                  });
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Cambios guardados exitosamente')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: JolusColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
              const SizedBox(height: 16),
  
              // Otros items
              _buildActionCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Mis Pedidos',
                subtitle: 'Historial de compras',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 3)),
                    (route) => false,
                  );
                },
              ),
              if (userProvider.isAdmin) ...[
                const SizedBox(height: 16),
                _buildActionCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Panel de Administración',
                  subtitle: 'Gestión de productos, pedidos y métricas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
  
              // Redes Sociales Section (Acordeón)
              _AnimatedCardWrapper(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => setState(() => _isSocialExpanded = !_isSocialExpanded),
                      leading: const Icon(Icons.share_outlined, color: JolusColors.primary),
                      title: Text(
                        'Contactanos',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: JolusColors.darkBlue,
                        ),
                      ),
                      trailing: Icon(
                        _isSocialExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[400],
                      ),
                    ),
                    if (_isSocialExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 16),
                            if (_isLoadingSocial)
                              const Center(child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ))
                            else if (_socialNetworks.isEmpty)
                              Center(child: Text('No hay redes configuradas', style: GoogleFonts.inter(color: Colors.grey)))
                            else
                              ..._socialNetworks.map((net) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildSocialTile(
                                  icon: _getIconForType(net.tipo),
                                  iconColor: _getColorForType(net.tipo),
                                  title: net.nombre,
                                  value: net.usuario,
                                  onTap: () => _launchURL(net.url),
                                ),
                              )),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(),
                            ),
                            Text(
                              'Estado de Cuenta',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Verificado',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
              const SizedBox(height: 32),
  
              // Cerrar Sesión
              TextButton.icon(
                onPressed: () async {
                  // Limpiar datos del usuario y cerrar sesión
                  await userProvider.clearUser();
                  
                  if (context.mounted) {
                    // Navegar al Login directamente
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: JolusColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 80,
                color: JolusColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¡Bienvenido!',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: JolusColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inicia sesión para acceder a tu perfil, ver tus pedidos y disfrutar de una experiencia completa.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JolusColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: JolusColors.primary),
                ),
                child: const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: JolusColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isEditing ? Colors.black87 : Colors.grey[700],
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: isEditing ? const UnderlineInputBorder() : InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return _AnimatedActionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  Widget _buildSocialTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null && value != '...' && value != 'No disponible')
              Icon(Icons.open_in_new, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: JolusColors.primary, size: 22),
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    return InkWell(
      onTap: () => context.read<NavigationProvider>().setSelectedIndex(2),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, color: JolusColors.primary, size: 20),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: JolusColors.error, shape: BoxShape.circle),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'whatsapp': return Icons.chat_bubble_outline;
      case 'instagram': return Icons.camera_alt_outlined;
      case 'facebook': return Icons.facebook_outlined;
      case 'twitter': return Icons.alternate_email;
      case 'web': return Icons.language;
      default: return Icons.link;
    }
  }

  Color _getColorForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'whatsapp': return Colors.green;
      case 'instagram': return Colors.pink;
      case 'facebook': return Colors.blue;
      case 'twitter': return Colors.black;
      case 'web': return Colors.orange;
      default: return JolusColors.primary;
    }
  }
}

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedCardWrapper({required this.child});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0)
          ..multiply(Matrix4.diagonal3Values(_isHovered ? 1.01 : 1.0, _isHovered ? 1.01 : 1.0, 1.0)),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AnimatedActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard> {
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
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0)
            ..multiply(Matrix4.diagonal3Values(_isHovered ? 1.01 : 1.0, _isHovered ? 1.01 : 1.0, 1.0)),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: JolusColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: JolusColors.primary),
            ),
            title: Text(
              widget.title,
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: JolusColors.darkBlue),
            ),
            subtitle: Text(
              widget.subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
