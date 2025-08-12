import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/domain/repositories/product_repository.dart';

class AddProduct {
  final IProductRepository repository;

  AddProduct(this.repository);

  Future<int> call(Product product) {
    return repository.addProduct(product);
  }
}
