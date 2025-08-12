import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  final IProductRepository repository;

  AddProduct(this.repository);

  Future<int> call(Product product) {
    return repository.addProduct(product);
  }
}
