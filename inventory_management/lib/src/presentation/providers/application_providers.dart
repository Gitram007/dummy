import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_management/src/data/datasources/local/database.dart';
import 'package:inventory_management/src/data/repositories/material_repository_impl.dart';
import 'package:inventory_management/src/data/repositories/product_material_repository_impl.dart';
import 'package:inventory_management/src/data/repositories/product_repository_impl.dart';
import 'package:inventory_management/src/domain/entities/product.dart';
import 'package:inventory_management/src/domain/entities/material.dart';
import 'package:inventory_management/src/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/src/domain/repositories/material_repository.dart';
import 'package:inventory_management/src/domain/repositories/product_material_repository.dart';
import 'package:inventory_management/src/domain/repositories/product_repository.dart';
import 'package:inventory_management/src/data/repositories/production_log_repository_impl.dart';
import 'package:inventory_management/src/domain/repositories/production_log_repository.dart';
import 'package:inventory_management/src/domain/services/report_service.dart';
import 'package:inventory_management/src/domain/services/export_service.dart';

// --- SERVICES ---
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(
    ref.watch(productionLogRepositoryProvider),
    ref.watch(productMaterialRepositoryProvider),
    ref.watch(materialRepositoryProvider),
  );
});

// --- DATABASE ---
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  // The AppDatabase constructor is singleton-like due to the nature of _openConnection
  return AppDatabase();
});

// --- DAOs ---
final productsDaoProvider = Provider<ProductsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.productsDao;
});

final materialsDaoProvider = Provider<MaterialsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.materialsDao;
});

final productMaterialsDaoProvider = Provider<ProductMaterialsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.productMaterialsDao;
});

final productionLogsDaoProvider = Provider<ProductionLogsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.productionLogsDao;
});


// --- REPOSITORIES ---
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final dao = ref.watch(productsDaoProvider);
  return ProductRepositoryImpl(dao);
});

final materialRepositoryProvider = Provider<IMaterialRepository>((ref) {
  final dao = ref.watch(materialsDaoProvider);
  return MaterialRepositoryImpl(dao);
});

final productMaterialRepositoryProvider = Provider<IProductMaterialRepository>((ref) {
  final dao = ref.watch(productMaterialsDaoProvider);
  return ProductMaterialRepositoryImpl(dao);
});

final productionLogRepositoryProvider = Provider<IProductionLogRepository>((ref) {
  final dao = ref.watch(productionLogsDaoProvider);
  return ProductionLogRepositoryImpl(dao);
});

// --- USE CASE PROVIDERS (for UI) ---

// This provider will give the UI a stream of all products.
// The UI can watch this to get live updates.
final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.watchProducts();
});

final materialsStreamProvider = StreamProvider.autoDispose<List<Material>>((ref) {
  final materialRepository = ref.watch(materialRepositoryProvider);
  return materialRepository.watchMaterials();
});

// --- MAPPING SCREEN PROVIDERS ---

final productByIdProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, id) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

final materialByIdProvider =
    FutureProvider.autoDispose.family<Material, int>((ref, id) {
  final repo = ref.watch(materialRepositoryProvider);
  return repo.getMaterialById(id);
});

final productMaterialsStreamProvider =
    StreamProvider.autoDispose.family<List<ProductMaterialMapping>, int>((ref, productId) {
  final repo = ref.watch(productMaterialRepositoryProvider);
  return repo.watchMappingsForProduct(productId);
});

final allMaterialsProvider = FutureProvider.autoDispose<List<Material>>((ref) {
  final repo = ref.watch(materialRepositoryProvider);
  return repo.getMaterials();
});
