class ServiceModel {
  final String id;
  final String nombre;
  final int cantidad;
  final String descripcion;
  final String categoria; // Basico, Premium, VIP
  final String servicio;  // Decoraciones, Buffet, etc.
  final double precio;
  final String? imagen;
  final String? productoId;
  final String? etiqueta; // Oferta, Descuento, Nuevo, etc.

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.descripcion,
    required this.categoria,
    required this.servicio,
    required this.precio,
    this.imagen,
    this.productoId,
    this.etiqueta,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'Basico',
      servicio: json['servicio'] ?? 'General',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
      imagen: json['imagen'],
      productoId: json['producto_id']?.toString(),
      etiqueta: json['etiqueta']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'cantidad': cantidad,
      'descripcion': descripcion,
      'categoria': categoria,
      'servicio': servicio,
      'precio': precio,
      'imagen': imagen,
      'etiqueta': etiqueta,
    };
    
    if (id.isNotEmpty) {
      data['id'] = id;
    }
    
    if (productoId != null) {
      data['producto_id'] = productoId;
    }
    
    return data;
  }
}
