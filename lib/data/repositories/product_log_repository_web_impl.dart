import 'package:inventory_management/src/data/datasources/remote/api_client.dart';
import 'package:inventory_management/src/domain/entities/add_production_log_params.dart';
import 'package:inventory_management/src/domain/entities/production_log.dart';
import 'package:inventory_management/src/domain/repositories/production_log_repository.dart';

class ProductionLogRepositoryWebImpl implements IProductionLogRepository {
  final ApiClient apiClient;

  ProductionLogRepositoryWebImpl(this.apiClient);

  @override
  Future<void> addProductionLog(AddProductionLogParams params) {
    return apiClient.addProductionLog(params);
  }

  @override
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end) {
    return apiClient.getProductionLogs(start, end);
  }

  @override
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end) {
    return apiClient.getProductionLogsForProduct(productId, start, end);
  }
}
