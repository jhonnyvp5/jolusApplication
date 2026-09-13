class PaymentReceiptModel {
  final String? id;
  final String orderId;
  final String userId;
  final double amount;
  final String receiptUrl;
  final String? receiptNumber;
  final String? fullName;
  final String? cedula;
  final String? bankName;
  final String? email;
  final DateTime paymentDate;
  final String status;

  PaymentReceiptModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.receiptUrl,
    this.receiptNumber,
    this.fullName,
    this.cedula,
    this.bankName,
    this.email,
    required this.paymentDate,
    this.status = 'pendiente',
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceiptModel(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      amount: double.tryParse(json['monto']?.toString() ?? '0') ?? 0.0,
      receiptUrl: json['url_comprobante'] ?? '',
      receiptNumber: json['numero_comprobante']?.toString(),
      fullName: json['nombre_completo'],
      cedula: json['cedula']?.toString(),
      bankName: json['nombre_banco'],
      email: json['correo'],
      paymentDate: json['fecha_pago'] != null 
          ? DateTime.parse(json['fecha_pago']) 
          : DateTime.now(),
      status: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'monto': amount,
      'url_comprobante': receiptUrl,
      'numero_comprobante': receiptNumber,
      'nombre_completo': fullName,
      'cedula': cedula,
      'nombre_banco': bankName,
      'correo': email,
      'fecha_pago': paymentDate.toIso8601String(),
      'estado': status,
    };
  }
}
