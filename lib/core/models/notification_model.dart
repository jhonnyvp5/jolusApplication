enum NotificationType { order, product, appUpdate }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['titulo'] ?? '',
      body: json['mensaje'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      type: _parseType(json['tipo']),
      isRead: json['leido'] ?? false,
      data: json['data'],
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'pedido':
        return NotificationType.order;
      case 'producto':
        return NotificationType.product;
      case 'actualizacion':
        return NotificationType.appUpdate;
      default:
        return NotificationType.appUpdate;
    }
  }
}
