import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String _id = '';
  String _name = 'Invitado';
  String _subname = '';
  String _email = '';
  String? _photoUrl;
  String _phone = '';
  String _address = '';
  bool _isAdmin = false;

  final DatabaseService _dbService = DatabaseService();

  UserProvider() {
    loadUser();
  }

  // Getters
  String get id => _id;
  String get name => _name;
  String get subname => _subname;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  String get phone => _phone;
  String get address => _address;
  bool get isAdmin => _isAdmin;
  bool get isGuest => _id.isEmpty;

  /// Carga los datos del usuario desde el almacenamiento local persistente
  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _id = prefs.getString('user_id') ?? '';
      _name = prefs.getString('user_name') ?? 'Invitado';
      _subname = prefs.getString('user_subname') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _photoUrl = prefs.getString('user_photo_url');
      _phone = prefs.getString('user_phone') ?? '';
      _address = prefs.getString('user_address') ?? '';
      _isAdmin = prefs.getBool('user_is_admin') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar datos locales del usuario: $e');
    }
  }

  /// Establece el usuario después de un login o registro exitoso
  Future<void> setUser({
    required String id,
    required String name,
    required String email,
    String? subname,
    String? photoUrl,
    String? phone,
    String? address,
    bool? isAdmin,
  }) async {
    _id = id;
    _name = name;
    _email = email;
    _photoUrl = photoUrl;
    _subname = subname ?? '';
    _phone = phone ?? '';
    _address = address ?? '';
    _isAdmin = isAdmin ?? false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _id);
    await prefs.setString('user_name', _name);
    await prefs.setString('user_subname', _subname);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phone);
    await prefs.setString('user_address', _address);
    await prefs.setBool('user_is_admin', _isAdmin);

    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      await prefs.setString('user_photo_url', _photoUrl!);
    } else {
      await prefs.remove('user_photo_url');
    }

    notifyListeners();
  }

  /// Refresca los datos del usuario desde el servidor
  Future<void> refreshUser() async {
    if (_id.isEmpty) return;
    try {
      final userModel = await _dbService.getUser(_id);
      if (userModel != null) {
        await setUser(
          id: userModel.id,
          name: userModel.name ?? _name,
          email: userModel.email,
          subname: userModel.subname,
          photoUrl: userModel.photoUrl,
          phone: userModel.phone,
          address: userModel.address,
          isAdmin: userModel.isAdmin,
        );
      }
    } catch (e) {
      debugPrint('Error al refrescar datos del usuario: $e');
    }
  }

  /// Actualiza los datos de perfil y los sincroniza con el backend
  Future<void> updateProfile({
    required String name,
    required String subname,
    required String email,
    required String phone,
    required String address,
  }) async {
    _name = name;
    _subname = subname;
    _email = email;
    _phone = phone;
    _address = address;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('user_subname', _subname);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phone);
    await prefs.setString('user_address', _address);

    if (_id.isNotEmpty) {
      try {
        await _dbService.syncUser(UserModel(
          id: _id,
          email: _email,
          name: _name,
          subname: _subname,
          photoUrl: _photoUrl,
          phone: _phone,
          address: _address,
          isAdmin: _isAdmin,
        ));
      } catch (e) {
        debugPrint('Error sincronizando perfil con el servidor: $e');
      }
    }

    notifyListeners();
  }

  /// Actualiza la URL de la foto y sincroniza con el servidor
  Future<void> updatePhotoUrl(String photoUrl) async {
    _photoUrl = photoUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_url', photoUrl);

    if (_id.isNotEmpty) {
      try {
        // En lugar de syncUser completo, usamos la acción específica de actualización de foto si estuviera disponible,
        // pero por ahora usamos el modelo completo para mantener consistencia.
        await _dbService.syncUser(UserModel(
          id: _id,
          email: _email,
          name: _name,
          subname: _subname,
          photoUrl: _photoUrl,
          phone: _phone,
          address: _address,
          isAdmin: _isAdmin,
        ));
      } catch (e) {
        debugPrint('Error sincronizando foto con el servidor: $e');
      }
    }
    notifyListeners();
  }

  /// Limpia los datos de la sesión (Cerrar sesión)
  Future<void> clearUser() async {
    _id = '';
    _name = 'Invitado';
    _subname = '';
    _email = '';
    _photoUrl = null;
    _phone = '';
    _address = '';
    _isAdmin = false;

    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'user_id', 'user_name', 'user_subname', 'user_email', 
      'user_photo_url', 'user_phone', 'user_address', 'user_is_admin'
    ];
    for (var key in keys) {
      await prefs.remove(key);
    }
    notifyListeners();
  }
}
