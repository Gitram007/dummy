import 'package:inventory_management/src/data/datasources/local/database.dart' as db;
import 'package:inventory_management/src/domain/entities/product_material_mapping.dart';
import 'package:inventory_management/src/domain/repositories/product_material_repository.dart';

class ProductMaterialRepositoryImpl implements IProductMaterialRepository {
  final db.ProductMaterialsDao _productMaterialsDao;

  ProductMaterialRepositoryImpl(this._productMaterialsDao);

  ProductMaterialMapping _fromDb(db.ProductMaterial dbMapping) {
    return ProductMaterialMapping(
      productId: dbMapping.productId,
      materialId: dbMapping.materialId,
      quantity: dbMapping.quantity,
      assignedAt: dbMapping.assignedAt,
    );
  }

  db.ProductMaterialsCompanion _toDb(ProductMaterialMapping mapping) {
    return db.ProductMaterialsCompanion(
      productId: db.Value(mapping.productId),
      materialId: db.Value(mapping.materialId),
      quantity: db.Value(mapping.quantity),
      assignedAt: db.Value(mapping.assignedAt),
    );
  }

  @override
  Future<void> addMapping(ProductMaterialMapping mapping) {
    final companion = _toDb(mapping);
    return _productMaterialsDao.addMaterialToProduct(companion);
  }

  @override
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId) async {
    final dbMappings = await _productMaterialsDao.getMaterialsForProduct(productId);
    return dbMappings.map(_fromDb).toList();
  }

  @override
  Future<int> removeMapping(int productId, int materialId) {
    return _productMaterialsDao.removeMaterialFromProduct(productId, materialId);
  }

  @override
  Stream<List<ProductMaterialMapping>> watchMappingsForProduct(int productId) {
    return _productMaterialsDao.watchMaterialsForProduct(productId).map(
      (dbMappings) => dbMappings.map(_fromDb).toList()
    );
  }
}
