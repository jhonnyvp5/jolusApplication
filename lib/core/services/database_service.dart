import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../models/profile_admin_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/cart_item.dart';
import '../models/bank_account_model.dart';
import '../models/social_network_model.dart';

class DatabaseService {
  final String _baseUrl = 'https://jolusApplication.orionnx.com/';

  // Helper para headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String?> _uploadToCPanel(Uint8List fileBytes, String extension) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload.php'));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        fileBytes,
        filename: 'upload.$extension',
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['url']?.toString();
      }
      return null;
    } catch (e) {
      debugPrint('Error en la subida a cPanel: $e');
      return null;
    }
  }

  // --- PRODUCTOS ---
  Future<List<ServiceModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/productos.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener productos: $e');
      return [];
    }
  }

  Future<void> addProduct(ServiceModel product) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/productos.php'),
        body: jsonEncode({...product.toJson(), 'action': 'create'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al añadir producto: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ServiceModel product) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/productos.php'),
        body: jsonEncode({...product.toJson(), 'action': 'update'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al actualizar producto: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/productos.php'),
        body: jsonEncode({'id': id, 'action': 'delete'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
      rethrow;
    }
  }

  Future<String?> uploadProductImage(Uint8List fileBytes, String extension) async {
    return await _uploadToCPanel(fileBytes, extension);
  }

  // --- USUARIOS ---
  Future<void> syncUser(UserModel user) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/usuarios.php'),
        body: jsonEncode({...user.toJson(), 'action': 'sync'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al sincronizar usuario: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/usuarios.php?user_id=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['status'] != 'error') {
          return UserModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener usuario: $e');
      return null;
    }
  }

  Future<String?> uploadUserPhoto(String userId, Uint8List fileBytes, String extension) async {
    final publicUrl = await _uploadToCPanel(fileBytes, extension);
    if (publicUrl != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/usuarios.php'),
          body: jsonEncode({'user_id': userId, 'foto': publicUrl, 'action': 'update_photo'}),
          headers: _headers,
        );
      } catch (e) {
        debugPrint('Error al actualizar foto en BD: $e');
      }
    }
    return publicUrl;
  }

  // --- CARRITO (Opcional para persistencia remota) ---
  Future<void> syncCart(String userId, List<CartItem> items) async {
    // Implementar si se desea guardar el carrito en la BD PHP
    // Por ahora se mantiene local en CartProvider para rendimiento
  }

  // --- PEDIDOS ---
  Future<String?> createOrder({
    required String userId,
    required double total,
    required List<CartItem> items,
    DateTime? fecha,
    String? direccion,
    String? metodoPago,
    String? telefono,
    String? comentario,
    String? observaciones,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/pedidos.php'),
        body: jsonEncode({
          'action': 'create',
          'user_id': userId,
          'total': total,
          'fecha': fecha?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'direccion_entrega': direccion,
          'metodo_pago': metodoPago,
          'telefono_contacto': telefono,
          'comentario': comentario,
          'observaciones': observaciones,
          'items': items.map((item) => {
            'producto_id': item.id,
            'nombre_producto': item.title,
            'cantidad': item.quantity,
            'precio_unitario': item.price,
          }).toList(),
        }),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['pedido_id']?.toString();
      }
      return null;
    } catch (e) {
      debugPrint('Error al crear pedido: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pedidos.php?user_id=$userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener pedidos del usuario: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrdersAdmin() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pedidos.php?action=all_admin'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener todos los pedidos: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/pedidos.php'),
        body: jsonEncode({'pedido_id': orderId, 'estado': status, 'action': 'update_status'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al actualizar estado del pedido: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/pedidos.php'),
        body: jsonEncode({'pedido_id': orderId, 'action': 'delete'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al eliminar pedido: $e');
      rethrow;
    }
  }

  // --- COMPROBANTES ---
  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cuentas_bancarias.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BankAccountModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener cuentas bancarias: $e');
      return [];
    }
  }

  Future<String?> uploadReceiptFile(String orderId, Uint8List fileBytes, String extension) async {
    return await _uploadToCPanel(fileBytes, extension);
  }

  Future<void> uploadPaymentReceipt(PaymentReceiptModel receipt) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/comprobantes.php'),
        body: jsonEncode({...receipt.toJson(), 'action': 'create'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al subir comprobante: $e');
      rethrow;
    }
  }

  // --- ADMIN & NOTIFICACIONES ---
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin.php?action=stats'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {};
    } catch (e) {
      debugPrint('Error al obtener estadísticas: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/notificaciones.php?user_id=$userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener notificaciones: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/notificaciones.php'),
        body: jsonEncode({'notificacion_id': notificationId, 'action': 'mark_read'}),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al marcar notificación: $e');
    }
  }

  Future<void> createNotification({String? userId, required String title, required String message, required String type, Map<String, dynamic>? data}) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/notificaciones.php'),
        body: jsonEncode({
          'user_id': userId, 
          'titulo': title, 
          'mensaje': message, 
          'tipo': type, 
          'data': data,
          'action': 'create'
        }),
        headers: _headers,
      );
    } catch (e) {
      debugPrint('Error al crear notificación: $e');
    }
  }

  Future<List<DateTime>> getReservedDates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pedidos.php?action=reserved_dates'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DateTime.parse(json['fecha'])).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener fechas reservadas: $e');
      return [];
    }
  }

  Future<ProfileAdminModel?> getAdminProfile() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin.php?action=profile'));
      if (response.statusCode == 200) {
        return ProfileAdminModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener perfil admin: $e');
      return null;
    }
  }

  // --- REDES SOCIALES ---
  Future<List<SocialNetworkModel>> getSocialNetworks() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/redes_sociales.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SocialNetworkModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener redes sociales: $e');
      return [];
    }
  }

  // --- COMPROBANTES DE PAGO (HISTORIAL) ---
  Future<Map<String, dynamic>?> getPaymentReceipt(String orderId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/comprobantes.php?pedido_id=$orderId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['status'] != 'error') {
          return data;
        } else if (data is List && data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener comprobante: $e');
      return null;
    }
  }

  // --- ANUNCIOS Y COMUNICADOS ---
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/anuncios.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('Error al obtener anuncios del servidor: $e');
    }
    // Resilient fallback with a modern placeholder announcement to guarantee UI operation
    return [
      {
        'etiqueta': 'Tecnología',
        'titulo': '¡Bienvenidos a Jolus Tecnología!',
        'contenido': 'Explora lo último en laptops, componentes de PC y periféricos gaming de alta gama con los mejores precios del mercado.',
        'imagen_url': 'https://images.unsplash.com/photo-1590650516494-0c8e4a4dd67e?q=80&w=400'
      }
    ];
  }
}
