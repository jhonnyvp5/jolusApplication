class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? subname;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.subname,
    this.phone,
    this.address,
    this.photoUrl,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'] ?? '',
      email: json['correo'] ?? json['email'] ?? '',
      name: json['nombres'] ?? json['name'],
      subname: json['apellidos'] ?? json['subname'],
      phone: json['telefono'] ?? json['phone'],
      address: json['direccion'] ?? json['address'],
      photoUrl: json['foto'] ?? json['photo_url'],
      isAdmin: json['es_admin'] == 1 || json['es_admin'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'correo': email,
      'nombres': name,
      'apellidos': subname,
      'telefono': phone,
      'direccion': address,
      'foto': photoUrl,
      'es_admin': isAdmin ? 1 : 0,
    };
  }
}
