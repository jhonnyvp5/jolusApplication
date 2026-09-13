import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/service_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  List<ServiceModel> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _dbService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando productos admin: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showProductForm([ServiceModel? product]) {
    final bool isEditing = product != null;
    final nameController = TextEditingController(text: product?.nombre);
    final priceController = TextEditingController(text: product?.precio.toString());
    final stockController = TextEditingController(text: product?.cantidad.toString());
    final descController = TextEditingController(text: product?.descripcion);
    String selectedCategory = product?.categoria ?? 'Basico';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'EDITAR PRODUCTO' : 'NUEVO PRODUCTO',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Basico', 'Premium', 'VIP'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => selectedCategory = val!,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: JolusColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    final newProduct = ServiceModel(
                      id: product?.id ?? '',
                      nombre: nameController.text,
                      precio: double.tryParse(priceController.text) ?? 0.0,
                      cantidad: int.tryParse(stockController.text) ?? 0,
                      descripcion: descController.text,
                      categoria: selectedCategory,
                      servicio: 'General',
                      imagen: product?.imagen,
                    );

                    if (isEditing) {
                      await _dbService.updateProduct(newProduct);
                    } else {
                      await _dbService.addProduct(newProduct);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                    _fetchProducts();
                  },
                  child: Text(isEditing ? 'ACTUALIZAR' : 'GUARDAR', style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteProduct(id);
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        title: Text('GESTIÓN DE PRODUCTOS', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: JolusColors.darkBlue,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: JolusColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: JolusColors.surfaceLow, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.inventory_2_outlined, color: JolusColors.primary),
                          ),
                          title: Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${product.precio.toStringAsFixed(2)} - Stock: ${product.cantidad}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showProductForm(product)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteProduct(product.id)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No hay productos registrados', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
