import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/notification_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'core/models/notification_model.dart';
import 'core/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // 1. Iniciamos los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargamos preferencias de usuario (Sesión local persistida)
  final userProvider = UserProvider();
  await userProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const JolusApp(),
    ),
  );

  // 3. Inicializamos servicios en segundo plano
  _initServices();
}

Future<void> _initServices() async {
  try {
    await initializeDateFormatting('es', null).timeout(const Duration(seconds: 2));
    await LocalNotificationService.initialize();
    debugPrint('Servicios locales inicializados con éxito');
  } catch (e) {
    debugPrint('Error en inicialización de servicios: $e');
  }
}

class JolusApp extends StatefulWidget {
  const JolusApp({super.key});

  @override
  State<JolusApp> createState() => _JolusAppState();
}

class _JolusAppState extends State<JolusApp> {
  final _appLinks = AppLinks();
  StreamSubscription? _notifSubscription;

  @override
  void initState() {
    super.initState();
    _setupDeepLinks();
    
    // Configurar notificaciones después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListener();
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    if (_notifSubscription != null) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // Iniciar escucha si hay un usuario logueado
    if (userProvider.id.isNotEmpty) {
      notificationProvider.setupRealtimeListener(userProvider.id);
      notificationProvider.fetchNotifications(userProvider.id);
    }

    _notifSubscription = notificationProvider.onNewNotification.listen((notification) {
      // 1. Mostrar SnackBar interno
      _showNotificationSnackBar(notification);
      
      // 2. Mostrar Notificación de Sistema
      LocalNotificationService.showNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.body,
      );
    });
  }

  void _showNotificationSnackBar(NotificationModel notification) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    IconData icon = Icons.notifications_active;
    switch (notification.type) {
      case NotificationType.order: icon = Icons.local_shipping_outlined; break;
      case NotificationType.product: icon = Icons.new_releases_outlined; break;
      case NotificationType.appUpdate: icon = Icons.system_update_outlined; break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: JolusColors.darkBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.amber,
          onPressed: () => navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          ),
        ),
      ),
    );
  }

  void _setupDeepLinks() async {
    _appLinks.uriLinkStream.listen((uri) => debugPrint('Deep Link detectado: $uri'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Jolus Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
