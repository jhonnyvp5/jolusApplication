class SocialNetworkModel {
  final String id;
  final String nombre;
  final String usuario;
  final String url;
  final String tipo;
  final bool activo;
  final int orden;

  SocialNetworkModel({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.url,
    required this.tipo,
    required this.activo,
    required this.orden,
  });

  factory SocialNetworkModel.fromJson(Map<String, dynamic> json) {
    return SocialNetworkModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      usuario: json['usuario'] ?? '',
      url: json['url'] ?? '',
      tipo: json['tipo'] ?? '',
      activo: json['activo'] ?? true,
      orden: json['orden'] ?? 0,
    );
  }
}
