import 'cart_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String serviceDate;
  final String serviceTime;
  final String status;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    this.serviceDate = '',
    this.serviceTime = '',
    this.status = 'Completado',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'products': products.map((p) => p.toJson()).toList(),
    'dateTime': dateTime.toIso8601String(),
    'serviceDate': serviceDate,
    'serviceTime': serviceTime,
    'status': status,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    products: (json['products'] as List).map((p) => CartItem.fromJson(p)).toList(),
    dateTime: DateTime.parse(json['dateTime']),
    serviceDate: json['serviceDate'] ?? '',
    serviceTime: json['serviceTime'] ?? '',
    status: json['status'] ?? 'Completado',
  );
}
