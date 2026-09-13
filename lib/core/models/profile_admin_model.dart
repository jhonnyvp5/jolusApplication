class ProfileAdminModel {
  final dynamic id;
  final String? userId;
  final String? usuarioAuditoria;
  final String? nombreApellido;
  final String? nombreUsuarioArroba;
  final String? nombreCuenta;
  final String? acercaDeMi;
  final String? direccion;
  final String? telefono;
  final String? correoElectronico;
  final String? linkFacebook;
  final String? linkInstagram;
  final String? linkWhatsapp;
  final String? urlFoto;
  final double? iva;
  final double? logistica;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  ProfileAdminModel({
    this.id,
    this.userId,
    this.usuarioAuditoria,
    this.nombreApellido,
    this.nombreUsuarioArroba,
    this.nombreCuenta,
    this.acercaDeMi,
    this.direccion,
    this.telefono,
    this.correoElectronico,
    this.linkFacebook,
    this.linkInstagram,
    this.linkWhatsapp,
    this.urlFoto,
    this.iva,
    this.logistica,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory ProfileAdminModel.fromJson(Map<String, dynamic> json) {
    return ProfileAdminModel(
      id: json['id'],
      userId: json['user_id']?.toString(),
      usuarioAuditoria: json['usuario_auditoria']?.toString(),
      nombreApellido: json['nombre_apellido']?.toString(),
      nombreUsuarioArroba: json['nombre_usuario_arroba']?.toString(),
      nombreCuenta: json['nombre_cuenta']?.toString(),
      acercaDeMi: json['acerca_de_mi']?.toString(),
      direccion: json['direccion']?.toString(),
      telefono: json['telefono']?.toString(),
      correoElectronico: json['correo_electronico']?.toString(),
      linkFacebook: json['link_facebook']?.toString(),
      linkInstagram: json['link_instagram']?.toString(),
      linkWhatsapp: json['link_whatsapp']?.toString(),
      urlFoto: json['url_foto']?.toString(),
      iva: double.tryParse(json['iva']?.toString() ?? '0') ?? 0.0,
      logistica: double.tryParse(json['logistica']?.toString() ?? '0') ?? 0.0,
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.parse(json['fecha_creacion'].toString()) : null,
      fechaModificacion: json['fecha_modificacion'] != null ? DateTime.parse(json['fecha_modificacion'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'usuario_auditoria': usuarioAuditoria,
      'nombre_apellido': nombreApellido,
      'nombre_usuario_arroba': nombreUsuarioArroba,
      'nombre_cuenta': nombreCuenta,
      'acerca_de_mi': acercaDeMi,
      'direccion': direccion,
      'telefono': telefono,
      'correo_electronico': correoElectronico,
      'link_facebook': linkFacebook,
      'link_instagram': linkInstagram,
      'link_whatsapp': linkWhatsapp,
      'url_foto': urlFoto,
      'iva': iva,
      'logistica': logistica,
    };
  }
}
