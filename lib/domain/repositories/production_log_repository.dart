import 'package:inventory_management/src/domain/entities/add_production_log_params.dart';
import 'package:inventory_management/src/domain/entities/production_log.dart';

abstract class IProductionLogRepository {
  Future<void> addProductionLog(AddProductionLogParams params);
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end);
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end);
}
