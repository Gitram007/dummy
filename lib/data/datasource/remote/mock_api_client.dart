import './api_client.dart';
import '../../../domain/entities/add_material_params.dart';
import '../../../domain/entities/add_product_params.dart';
import '../../../domain/entities/add_production_log_params.dart';
import '../../../domain/entities/material.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_material_mapping.dart';
import '../../../domain/entities/production_log.dart';

class MockApiClient implements ApiClient {
  // In-memory "database" for the mock client
  final List<Product> _products = [];
  final List<Material> _materials = [];
  final List<ProductMaterialMapping> _mappings = [];
  final List<ProductionLog> _logs = [];
  int _product_id_counter = 0;
  int _material_id_counter = 0;
  int _log_id_counter = 0;

  Future<void> _simulateNetworkDelay() =>
      Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<Product> addProduct(AddProductParams params) async {
    await _simulateNetworkDelay();
    final newProduct = Product(
      id: ++_product_id_counter,
      name: params.name,
      createdAt: DateTime.now(),
    );
    _products.add(newProduct);
    return newProduct;
  }

  @override
  Future<List<Product>> getProducts() async {
    await _simulateNetworkDelay();
    return List.from(_products);
  }

  // --- STUBS FOR OTHER METHODS ---

  @override
  Future<void> addMapping(ProductMaterialMapping mapping) async {
    await _simulateNetworkDelay();
    _mappings.removeWhere((m) => m.productId == mapping.productId && m.materialId == mapping.materialId);
    _mappings.add(mapping);
  }

  @override
  Future<void> addProductionLog(AddProductionLogParams params) async {
    await _simulateNetworkDelay();
    _logs.add(ProductionLog(
      id: ++_log_id_counter,
      productId: params.productId,
      quantityProduced: params.quantityProduced,
      productionDate: params.productionDate,
    ));
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _simulateNetworkDelay();
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<Product> getProduct(int id) async {
    await _simulateNetworkDelay();
    return _products.firstWhere((p) => p.id == id, orElse: () => throw Exception('Product with id $id not found'));
  }

  @override
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId) async {
    await _simulateNetworkDelay();
    return _mappings.where((m) => m.productId == productId).toList();
  }

  @override
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end) async {
    await _simulateNetworkDelay();
    return _logs.where((l) => l.productionDate.isAfter(start) && l.productionDate.isBefore(end)).toList();
  }

  @override
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end) async {
    await _simulateNetworkDelay();
    return _logs.where((l) => l.productId == productId && l.productionDate.isAfter(start) && l.productionDate.isBefore(end)).toList();
  }

  @override
  Future<void> removeMapping(int productId, int materialId) async {
    await _simulateNetworkDelay();
    _mappings.removeWhere((m) => m.productId == productId && m.materialId == materialId);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _simulateNetworkDelay();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return product;
    } else {
      throw Exception('Product with id ${product.id} not found');
    }
  }

  // --- Materials (Not fully implemented for brevity, follows same pattern) ---
  @override
  Future<Material> addMaterial(AddMaterialParams params) async {
    await _simulateNetworkDelay();
    final newMaterial = Material(
      id: ++_material_id_counter,
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
      createdAt: DateTime.now(),
    );
    _materials.add(newMaterial);
    return newMaterial;
  }

  @override
  Future<void> deleteMaterial(int id) async {
    await _simulateNetworkDelay();
    _materials.removeWhere((m) => m.id == id);
  }

  @override
  Future<Material> getMaterial(int id) async {
    await _simulateNetworkDelay();
    return _materials.firstWhere((m) => m.id == id, orElse: () => throw Exception('Material with id $id not found'));
  }

  @override
  Future<List<Material>> getMaterials() async {
    await _simulateNetworkDelay();
    return List.from(_materials);
  }

  @override
  Future<Material> updateMaterial(Material material) async {
    await _simulateNetworkDelay();
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      return material;
    } else {
      throw Exception('Material with id ${material.id} not found');
    }
  }
}
