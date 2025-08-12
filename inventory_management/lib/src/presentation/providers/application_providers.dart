import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data sources
import 'package:inventory_management/src/data/datasources/local/database.dart';
import 'package:inventory_management/src/data/datasources/remote/api_client.dart';
import 'package:inventory_management/src/data/datasources/remote/mock_api_client.dart';

// Repository Implementations (Mobile)
import 'package:inventory_management/src/data/repositories/material_repository_impl.dart';
import 'package:inventory_management/src/data/repositories/product_material_repository_impl.dart';
import 'package:inventory_management/src/data/repositories/product_repository_impl.dart';
import 'package:inventory_management/src/data/repositories/production_log_repository_impl.dart';

// Repository Implementations (Web)
import 'package:inventory_management/src/data/repositories/material_repository_web_impl.dart';
import 'package:inventory_management/src/data/repositories/product_material_repository_web_impl.dart';
import 'package:inventory_management/src/data/repositories/product_repository_web_impl.dart';
import 'package:inventory_management/src/data/repositories/production_log_repository_web_impl.dart';


// Domain
import 'package:inventory_management/src/domain/entities/product.dart';
import 'package:inventory_management/src/domain/entities/material.dart';
import 'package:inventory_management/src/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/src/domain/repositories/material_repository.dart';
import 'package:inventory_management/src/domain/repositories/product_material_repository.dart';
import 'package:inventory_management/src/domain/repositories/product_repository.dart';
import 'package:inventory_management/src/domain/repositories/production_log_repository.dart';
import 'package:inventory_management/src/domain/services/report_service.dart';
import 'package:inventory_management/src/domain/services/export_service.dart';

// --- DATA SOURCE PROVIDERS ---

// Provider for the local Drift database. Only used on mobile.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  if (kIsWeb) {
    throw UnsupportedError('Drift database is not supported on web.');
  }
  return AppDatabase();
});

// Provider for the REST API client. A singleton mock instance is used.
final apiClientProvider = Provider<ApiClient>((ref) {
  return MockApiClient();
});


// --- REPOSITORY PROVIDERS (Conditional) ---

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  if (kIsWeb) {
    return ProductRepositoryWebImpl(ref.watch(apiClientProvider));
  } else {
    final dao = ref.watch(appDatabaseProvider).productsDao;
    return ProductRepositoryImpl(dao);
  }
});

final materialRepositoryProvider = Provider<IMaterialRepository>((ref) {
  if (kIsWeb) {
    return MaterialRepositoryWebImpl(ref.watch(apiClientProvider));
  } else {
    final dao = ref.watch(appDatabaseProvider).materialsDao;
    return MaterialRepositoryImpl(dao);
  }
});

final productMaterialRepositoryProvider =
    Provider<IProductMaterialRepository>((ref) {
  if (kIsWeb) {
    return ProductMaterialRepositoryWebImpl(ref.watch(apiClientProvider));
  } else {
    final dao = ref.watch(appDatabaseProvider).productMaterialsDao;
    return ProductMaterialRepositoryImpl(dao);
  }
});

final productionLogRepositoryProvider =
    Provider<IProductionLogRepository>((ref) {
  if (kIsWeb) {
    return ProductionLogRepositoryWebImpl(ref.watch(apiClientProvider));
  } else {
    final dao = ref.watch(appDatabaseProvider).productionLogsDao;
    return ProductionLogRepositoryImpl(dao);
  }
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
