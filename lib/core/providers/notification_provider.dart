import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();

  // Stream para notificar a la UI sobre nuevas notificaciones entrantes
  final _newNotificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get onNewNotification => _newNotificationController.stream;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Timer? _pollingTimer;

  Future<void> fetchNotifications(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _dbService.getNotifications(userId);
      
      final newNotifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      
      // Verificar si hay nuevas notificaciones para disparar el stream
      for (var newNotif in newNotifications) {
        if (!_notifications.any((n) => n.id == newNotif.id)) {
          _newNotificationController.add(newNotif);
        }
      }

      _notifications = newNotifications;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dbService.markNotificationAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          createdAt: _notifications[index].createdAt,
          type: _notifications[index].type,
          isRead: true,
          data: _notifications[index].data,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void setupRealtimeListener(String userId) {
    // Como MySQL no es tiempo real nativo sin sockets, usamos polling corto o 
    // confiamos en las acciones del usuario. Aquí implementamos un polling de 30s.
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications(userId);
    });
  }

  void clearNotifications() {
    _notifications = [];
    _pollingTimer?.cancel();
    _pollingTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _newNotificationController.close();
    super.dispose();
  }
}
