import 'dart:async';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/database_service.dart';

class ProductsProvider with ChangeNotifier {
  List<ServiceModel> _products = [];
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();
  Timer? _refreshTimer;

  List<ServiceModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    // Solo mostramos loading si la lista actual está vacía para evitar parpadeos molestos en la UI
    final bool firstLoad = _products.isEmpty;
    if (firstLoad) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _dbService.getProducts();
      _products = data;
    } catch (e) {
      debugPrint('Error cargando productos en ProductsProvider: $e');
    } finally {
      if (firstLoad) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    // Polling inteligente cada 10 segundos para simular actualizaciones inmediatas (tiempo real)
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchProducts();
    });
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
