import 'package:inventory_management/domain/entities/add_material_params.dart';
import 'package:inventory_management/domain/entities/add_product_params.dart';
import 'package:inventory_management/domain/entities/add_production_log_params.dart';
import 'package:inventory_management/domain/entities/material.dart';
import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/domain/entities/production_log.dart';

abstract class ApiClient {
  // Product endpoints
  Future<List<Product>> getProducts();
  Future<Product> getProduct(int id);
  Future<Product> addProduct(AddProductParams params);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);

  // Material endpoints
  Future<List<Material>> getMaterials();
  Future<Material> getMaterial(int id);
  Future<Material> addMaterial(AddMaterialParams params);
  Future<Material> updateMaterial(Material material);
  Future<void> deleteMaterial(int id);

  // Product-Material Mapping endpoints
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId);
  Future<void> addMapping(ProductMaterialMapping mapping);
  Future<void> removeMapping(int productId, int materialId);

  // Production Log endpoints
  Future<void> addProductionLog(AddProductionLogParams params);
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end);
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end);
}
