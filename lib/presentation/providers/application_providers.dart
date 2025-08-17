import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Implementations (API)
import '../../data/repositories/material_repository_api_impl.dart';
import '../../data/repositories/product_material_repository_api_impl.dart';
import '../../data/repositories/product_repository_api_impl.dart';
import '../../data/repositories/production_log_repository_api_impl.dart';

// Domain
import '../../domain/entities/product.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/product_material_mapping.dart';
import '../../domain/repositories/material_repository.dart';
import '../../domain/repositories/product_material_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/production_log_repository.dart';
import '../../domain/services/report_service.dart';
import '../../domain/services/export_service.dart';

// --- REPOSITORY PROVIDERS ---

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepositoryApiImpl();
});

final materialRepositoryProvider = Provider<IMaterialRepository>((ref) {
  return MaterialRepositoryApiImpl();
});

final productMaterialRepositoryProvider =
    Provider<IProductMaterialRepository>((ref) {
  return ProductMaterialRepositoryApiImpl();
});

final productionLogRepositoryProvider =
    Provider<IProductionLogRepository>((ref) {
  return ProductionLogRepositoryApiImpl();
});


// --- SERVICE PROVIDERS ---

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


// --- UI-FACING PROVIDERS ---

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

final materialsStreamProvider = StreamProvider.autoDispose<List<Material>>((ref) {
  return ref.watch(materialRepositoryProvider).watchMaterials();
});

final productByIdProvider =
FutureProvider.autoDispose.family<Product, int>((ref, id) {
  return ref.watch(productRepositoryProvider).getProductById(id);
});

final materialByIdProvider =
FutureProvider.autoDispose.family<Material, int>((ref, id) {
  return ref.watch(materialRepositoryProvider).getMaterialById(id);
});

final productMaterialsStreamProvider =
StreamProvider.autoDispose.family<List<ProductMaterialMapping>, int>((ref, productId) {
  return ref.watch(productMaterialRepositoryProvider).watchMappingsForProduct(productId);
});

final allMaterialsProvider = FutureProvider.autoDispose<List<Material>>((ref) {
  return ref.watch(materialRepositoryProvider).getMaterials();
});
