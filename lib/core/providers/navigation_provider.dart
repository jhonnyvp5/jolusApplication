import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';

  int get selectedIndex => _selectedIndex;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    if (index != 1) _searchQuery = ''; // Limpiar búsqueda si salimos de catálogo
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _searchQuery = ''; // Limpiar búsqueda al cambiar categoría
    _selectedIndex = 1; // Always jump to Services tab when a category is selected
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _selectedCategory = 'Todos';
    _selectedIndex = 1; // Saltar al catálogo
    notifyListeners();
  }
}
