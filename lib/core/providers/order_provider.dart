import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data = await _dbService.getUserOrders(userId);
      _orders = data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DateTime>> getReservedDates() async {
    return await _dbService.getReservedDates();
  }

  Future<String?> placeOrder({
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
    _isLoading = true;
    notifyListeners();

    try {
      final String? pedidoId = await _dbService.createOrder(
        userId: userId,
        total: total,
        items: items,
        fecha: fecha,
        direccion: direccion,
        metodoPago: metodoPago,
        telefono: telefono,
        comentario: comentario,
        observaciones: observaciones,
      );

      if (pedidoId != null) {
        // Recargar pedidos para tener la lista actualizada
        await fetchOrders(userId);
        return pedidoId;
      }
      return null;
    } catch (e) {
      debugPrint('Error al realizar el pedido: $e');
      rethrow; // Propagamos el error para que la UI lo atrape y lo muestre
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _dbService.updateOrderStatus(orderId, status);
      
      // Actualizar localmente
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = OrderModel(
          id: _orders[index].id,
          userId: _orders[index].userId,
          fecha: _orders[index].fecha,
          total: _orders[index].total,
          estado: status,
          direccionEntrega: _orders[index].direccionEntrega,
          metodoPago: _orders[index].metodoPago,
          telefonoContacto: _orders[index].telefonoContacto,
          comentario: _orders[index].comentario,
          observaciones: _orders[index].observaciones,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar estado en Provider: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      // 1. Borrar de la base de datos (DatabaseService ya maneja pedido_items y pedidos)
      await _dbService.deleteOrder(orderId);
      
      // 2. Borrar de la lista local para actualizar la UI (Historial) inmediatamente
      _orders.removeWhere((order) => order.id.toString() == orderId);
      
      notifyListeners();
      debugPrint('Pedido $orderId eliminado del sistema y de la UI.');
    } catch (e) {
      debugPrint('Error al cancelar pedido en Provider: $e');
      rethrow;
    }
  }

  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
}
