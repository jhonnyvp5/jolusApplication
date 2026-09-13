class BankAccountModel {
  final String id;
  final String bancoNombre;
  final String titularNombre;
  final String numeroCuenta;
  final String? ruc;
  final String? email;
  final String tipoCuenta;
  final String colorHex;

  BankAccountModel({
    required this.id,
    required this.bancoNombre,
    required this.titularNombre,
    required this.numeroCuenta,
    this.ruc,
    this.email,
    required this.tipoCuenta,
    required this.colorHex,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      bancoNombre: json['banco_nombre'],
      titularNombre: json['titular_nombre'],
      numeroCuenta: json['numero_cuenta'],
      ruc: json['ruc'],
      email: json['email'],
      tipoCuenta: json['tipo_cuenta'] ?? 'Corriente',
      colorHex: json['color_hex'] ?? '#002266',
    );
  }
}
