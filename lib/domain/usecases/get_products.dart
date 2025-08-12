import 'package:inventory_management/src/domain/entities/product.dart';
import 'package:inventory_management/src/domain/repositories/product_repository.dart';

class GetProducts {
  final IProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}
