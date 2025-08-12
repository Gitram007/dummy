import 'package:inventory_management/src/domain/entities/material.dart';
import 'package:inventory_management/src/domain/repositories/material_repository.dart';
import 'package:inventory_management/src/domain/repositories/product_material_repository.dart';
import 'package:inventory_management/src/domain/repositories/production_log_repository.dart';

class ReportService {
  final IProductionLogRepository _productionLogRepository;
  final IProductMaterialRepository _productMaterialRepository;
  final IMaterialRepository _materialRepository;

  ReportService(
      this._productionLogRepository,
      this._productMaterialRepository,
      this._materialRepository,
      );

  Future<Map<Material, double>> getMaterialUsageForProduct({
    required int productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Get all production logs for the product in the date range
    final logs = await _productionLogRepository.getProductionLogs(startDate, endDate);
    final productLogs = logs.where((log) => log.productId == productId);

    if (productLogs.isEmpty) {
      return {};
    }

    // 2. Calculate total quantity produced
    final totalProduced = productLogs.fold<double>(0.0, (sum, log) => sum + log.quantityProduced);

    // 3. Get the product's material recipe
    final recipe = await _productMaterialRepository.getMappingsForProduct(productId);

    if (recipe.isEmpty) {
      return {};
    }

    // 4. Get all material details
    final allMaterials = await _materialRepository.getMaterials();
    final materialMap = {for (var m in allMaterials) m.id: m};

    // 5. Calculate total usage for each material
    final usageReport = <Material, double>{};
    for (final mapping in recipe) {
      final material = materialMap[mapping.materialId];
      if (material != null) {
        final totalUsage = mapping.quantity * totalProduced;
        usageReport[material] = (usageReport[material] ?? 0) + totalUsage;
      }
    }

    return usageReport;
  }

  Future<Map<Material, double>> getOverallMaterialUsage({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Get all production logs for the date range
    final logs = await _productionLogRepository.getProductionLogs(startDate, endDate);
    if (logs.isEmpty) {
      return {};
    }

    // 2. Group logs by product
    final Map<int, double> totalProducedByProduct = {};
    for (final log in logs) {
      totalProducedByProduct[log.productId] =
          (totalProducedByProduct[log.productId] ?? 0) + log.quantityProduced;
    }

    // 3. Get all material details and recipes
    final allMaterials = await _materialRepository.getMaterials();
    final materialMap = {for (var m in allMaterials) m.id: m};

    final overallUsageReport = <Material, double>{};

    // 4. For each product that was produced, calculate its material usage
    for (final entry in totalProducedByProduct.entries) {
      final productId = entry.key;
      final totalProduced = entry.value;

      final recipe = await _productMaterialRepository.getMappingsForProduct(productId);

      for (final mapping in recipe) {
        final material = materialMap[mapping.materialId];
        if (material != null) {
          final totalUsage = mapping.quantity * totalProduced;
          overallUsageReport[material] = (overallUsageReport[material] ?? 0) + totalUsage;
        }
      }
    }

    return overallUsageReport;
  }
}
