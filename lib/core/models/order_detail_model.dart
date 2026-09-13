class OrderDetailModel {
  final String? id;
  final String pedidoId;
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  OrderDetailModel({
    this.id,
    required this.pedidoId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) => OrderDetailModel(
    id: json['id'],
    pedidoId: json['pedido_id'],
    productoId: json['producto_id'].toString(),
    nombreProducto: json['nombre_producto'],
    cantidad: json['cantidad'],
    precioUnitario: (json['precio_unitario'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'pedido_id': pedidoId,
    'producto_id': productoId,
    'nombre_producto': nombreProducto,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
  };
}
