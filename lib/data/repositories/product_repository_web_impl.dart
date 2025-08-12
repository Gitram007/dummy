import 'package:inventory_management/src/data/datasources/remote/api_client.dart';
import 'package:inventory_management/src/domain/entities/add_product_params.dart';
import 'package:inventory_management/src/domain/entities/product.dart';
import 'package:inventory_management/src/domain/repositories/product_repository.dart';

class ProductRepositoryWebImpl implements IProductRepository {
  final ApiClient apiClient;

  ProductRepositoryWebImpl(this.apiClient);

  @override
  Future<int> addProduct(AddProductParams params) async {
    final product = await apiClient.addProduct(params);
    return product.id;
  }

  @override
  Future<int> deleteProduct(int id) async {
    await apiClient.deleteProduct(id);
    return 1; // Return 1 to indicate one row was "affected"
  }

  @override
  Future<Product> getProductById(int id) {
    return apiClient.getProduct(id);
  }

  @override
  Future<List<Product>> getProducts() {
    return apiClient.getProducts();
  }

  @override
  Future<bool> updateProduct(Product product) async {
    await apiClient.updateProduct(product);
    return true; // Assume success
  }

  @override
  Stream<List<Product>> watchProducts() {
    // REST APIs don't typically support streaming list updates out of the box.
    // A real implementation might use WebSockets or periodic polling.
    // For this mock implementation, we return an empty stream, meaning the UI
    // will not get live updates on the web.
    return Stream.value([]);
  }
}
