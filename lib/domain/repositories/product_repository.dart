import '../entities/add_product_params.dart';
import '../entities/product.dart';

abstract class IProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> watchProducts();
  Future<int> addProduct(AddProductParams params);
  Future<bool> updateProduct(Product product);
  Future<int> deleteProduct(int id);
  Future<Product> getProductById(int id);
}
