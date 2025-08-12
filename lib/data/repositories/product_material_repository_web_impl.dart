import '../datasources/remote/api_client.dart';
import '../../domain/entities/product_material_mapping.dart';
import '../../domain/repositories/product_material_repository.dart';

class ProductMaterialRepositoryWebImpl implements IProductMaterialRepository {
  final ApiClient apiClient;

  ProductMaterialRepositoryWebImpl(this.apiClient);

  @override
  Future<void> addMapping(ProductMaterialMapping mapping) {
    return apiClient.addMapping(mapping);
  }

  @override
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId) {
    return apiClient.getMappingsForProduct(productId);
  }

  @override
  Future<int> removeMapping(int productId, int materialId) async {
    await apiClient.removeMapping(productId, materialId);
    return 1;
  }

  @override
  Stream<List<ProductMaterialMapping>> watchMappingsForProduct(int productId) {
    return Stream.value([]);
  }
}
