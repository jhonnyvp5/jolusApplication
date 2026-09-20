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
    String? imagenUrl = json['imagen'];
    
    if (imagenUrl != null && imagenUrl.isNotEmpty) {
      // Normalizar la URL de la imagen
      imagenUrl = imagenUrl.replaceAll('\\', '/');
      
      // Si la URL viene como http://, forzar https:// para evitar problemas de Cleartext Traffic en Android
      if (imagenUrl.startsWith('http://')) {
        imagenUrl = imagenUrl.replaceFirst('http://', 'https://');
      }
      
      if (!imagenUrl.startsWith('http')) {
        // Si es una ruta relativa, construir la URL completa
        // Basado en DatabaseService, el dominio es jolusapplication.orionnx.com
        if (imagenUrl.startsWith('/')) {
          imagenUrl = 'https://jolusapplication.orionnx.com$imagenUrl';
        } else {
          // Si no empieza con /, asumimos que está en la carpeta de imágenes o raíz
          // Ajustamos para que no incluya /api/ si ya no se usa
          imagenUrl = 'https://jolusapplication.orionnx.com/$imagenUrl';
        }
      }
      
      // Codificar espacios si existen
      if (imagenUrl.contains(' ')) {
        imagenUrl = Uri.encodeFull(imagenUrl);
      }
    }

    return ServiceModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'Basico',
      servicio: json['servicio'] ?? 'General',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
      imagen: imagenUrl,
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
