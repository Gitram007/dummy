import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../entities/add_product_params.dart';

class AddProduct {
  final IProductRepository repository;

  AddProduct(this.repository);

  Future<int> call(Product product) {
    final params = AddProductParams(
      name: product.name,
      description: product.description,
    );
    return repository.addProduct(params);
  }
}
