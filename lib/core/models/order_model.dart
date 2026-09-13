class OrderModel {
  final String? id;
  final String userId;
  final DateTime fecha;
  final double total;
  final String estado;
  final String? direccionEntrega;
  final String? metodoPago;
  final String? telefonoContacto;
  final String? comentario;
  final String? observaciones;

  OrderModel({
    this.id,
    required this.userId,
    required this.fecha,
    required this.total,
    this.estado = 'pendiente',
    this.direccionEntrega,
    this.metodoPago,
    this.telefonoContacto,
    this.comentario,
    this.observaciones,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id']?.toString(),
    userId: json['user_id']?.toString() ?? '',
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    estado: json['estado'] ?? 'pendiente',
    direccionEntrega: json['direccion_entrega'],
    metodoPago: json['metodo_pago'],
    telefonoContacto: json['telefono_contacto'],
    comentario: json['comentario'],
    observaciones: json['observaciones'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'fecha': fecha.toIso8601String(),
    'total': total,
    'estado': estado,
    'direccion_entrega': direccionEntrega,
    'metodo_pago': metodoPago,
    'telefono_contacto': telefonoContacto,
    'comentario': comentario,
    'observaciones': observaciones,
  };
}
