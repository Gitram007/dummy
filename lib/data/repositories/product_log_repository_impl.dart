import 'package:inventory_management/src/data/datasources/local/database.dart' as db;
import 'package:inventory_management/src/domain/entities/add_production_log_params.dart';
import 'package:inventory_management/src/domain/entities/production_log.dart';
import 'package:inventory_management/src/domain/repositories/production_log_repository.dart';

class ProductionLogRepositoryImpl implements IProductionLogRepository {
  final db.ProductionLogsDao _dao;

  ProductionLogRepositoryImpl(this._dao);

  ProductionLog _fromDb(db.ProductionLog dbLog) {
    return ProductionLog(
      id: dbLog.id,
      productId: dbLog.productId,
      quantityProduced: dbLog.quantityProduced,
      productionDate: dbLog.productionDate,
    );
  }

  @override
  Future<void> addProductionLog(AddProductionLogParams params) {
    final companion = db.ProductionLogsCompanion.insert(
      productId: params.productId,
      quantityProduced: params.quantityProduced,
      productionDate: params.productionDate,
    );
    return _dao.addProductionLog(companion);
  }

  @override
  Future<List<ProductionLog>> getProductionLogs(DateTime start, DateTime end) async {
    final dbLogs = await _dao.getProductionLogsInDateRange(start, end);
    return dbLogs.map(_fromDb).toList();
  }

  @override
  Future<List<ProductionLog>> getProductionLogsForProduct(int productId, DateTime start, DateTime end) async {
    final dbLogs = await _dao.getProductionLogsForProductInDateRange(productId, start, end);
    return dbLogs.map(_fromDb).toList();
  }
}
