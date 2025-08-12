import '../entities/product_material_mapping.dart';

abstract class IProductMaterialRepository {
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId);
  Stream<List<ProductMaterialMapping>> watchMappingsForProduct(int productId);
  Future<void> addMapping(ProductMaterialMapping mapping);
  Future<int> removeMapping(int productId, int materialId);
}
