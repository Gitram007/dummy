import 'package:inventory_management/domain/entities/product.dart';
import 'package:inventory_management/domain/repositories/product_repository.dart';

class GetProducts {
  final IProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}
