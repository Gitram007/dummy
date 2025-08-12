import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management/domain/entities/material.dart';
import 'package:inventory_management/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/domain/entities/production_log.dart';
import 'package:inventory_management/domain/repositories/material_repository.dart';
import 'package:inventory_management/domain/repositories/product_material_repository.dart';
import 'package:inventory_management/domain/repositories/production_log_repository.dart';
import 'package:inventory_management/domain/services/report_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'report_service_test.mocks.dart';

@GenerateMocks([
  IProductionLogRepository,
  IProductMaterialRepository,
  IMaterialRepository
])
void main() {
  late MockIProductionLogRepository mockProductionLogRepository;
  late MockIProductMaterialRepository mockProductMaterialRepository;
  late MockIMaterialRepository mockMaterialRepository;
  late ReportService reportService;

  setUp(() {
    mockProductionLogRepository = MockIProductionLogRepository();
    mockProductMaterialRepository = MockIProductMaterialRepository();
    mockMaterialRepository = MockIMaterialRepository();
    reportService = ReportService(
      mockProductionLogRepository,
      mockProductMaterialRepository,
      mockMaterialRepository,
    );
  });

  group('ReportService', () {
    test('getMaterialUsageForProduct calculates usage correctly', () async {
      // Arrange
      final productId = 1;
      final startDate = DateTime(2023, 1, 1);
      final endDate = DateTime(2023, 1, 31);

      final productionLogsForProduct = [
        ProductionLog(id: 1, productId: 1, quantityProduced: 10, productionDate: DateTime(2023, 1, 10)),
        ProductionLog(id: 2, productId: 1, quantityProduced: 5, productionDate: DateTime(2023, 1, 15)),
      ];

      final materialMappings = [
        ProductMaterialMapping(productId: 1, materialId: 101, quantity: 2.5, assignedAt: DateTime.now()),
        ProductMaterialMapping(productId: 1, materialId: 102, quantity: 1.0, assignedAt: DateTime.now()),
      ];

      final allMaterials = [
        Material(id: 101, name: 'Screw', description: 'A screw', createdAt: DateTime.now()),
        Material(id: 102, name: 'Plate', description: 'A plate', createdAt: DateTime.now()),
      ];

      when(mockProductionLogRepository.getProductionLogsForProduct(productId, startDate, endDate))
          .thenAnswer((_) async => productionLogsForProduct);
      when(mockProductMaterialRepository.getMappingsForProduct(productId))
          .thenAnswer((_) async => materialMappings);
      when(mockMaterialRepository.getMaterials())
          .thenAnswer((_) async => allMaterials);

      // Act
      final result = await reportService.getMaterialUsageForProduct(
        productId: productId,
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      // Total produced for product 1 is 10 + 5 = 15
      // Expected usage for Screw (id 101) = 15 * 2.5 = 37.5
      // Expected usage for Plate (id 102) = 15 * 1.0 = 15.0
      expect(result.length, 2);
      expect(result[allMaterials[0]], 37.5); // Screw
      expect(result[allMaterials[1]], 15.0); // Plate
    });
  });
}
