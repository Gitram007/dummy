import '../entities/add_production_log_params.dart';
import '../entities/production_log.dart';

abstract class IProductionLogRepository {
  Future<void> addProductionLog(AddProductionLogParams params);
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end);
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end);
}
