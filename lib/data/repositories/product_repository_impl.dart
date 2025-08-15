import 'package:drift/drift.dart';
import '../../data/local/database.dart' as db;
import '../../domain/entities/add_product_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  final db.ProductsDao _productsDao;

  ProductRepositoryImpl(this._productsDao);

  Product _fromDb(db.Product dbProduct) {
    return Product(
      id: dbProduct.id,
      name: dbProduct.name,
      createdAt: dbProduct.createdAt,
    );
  }

  db.ProductsCompanion _toDbUpdate(Product product) {
    return db.ProductsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      createdAt: Value(product.createdAt),
    );
  }

  @override
  Future<int> addProduct(AddProductParams params) {
    final companion = db.ProductsCompanion.insert(
      name: params.name,
    );
    return _productsDao.insertProduct(companion);
  }

  @override
  Future<int> deleteProduct(int id) {
    return _productsDao.deleteProduct(id);
  }

  @override
  Future<List<Product>> getProducts() async {
    final dbProducts = await _productsDao.getAllProducts();
    return dbProducts.map(_fromDb).toList();
  }

  @override
  Future<bool> updateProduct(Product product) {
    final companion = _toDbUpdate(product);
    return _productsDao.updateProduct(companion);
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _productsDao.watchAllProducts().map(
            (dbProducts) => dbProducts.map(_fromDb).toList()
    );
  }

  @override
  Future<Product> getProductById(int id) async {
    final dbProduct = await _productsDao.getProduct(id);
    return _fromDb(dbProduct);
  }
}
