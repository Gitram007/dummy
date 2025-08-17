import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../domain/entities/add_product_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryApiImpl implements IProductRepository {
  final String _baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  @override
  Future<int> addProduct(AddProductParams params) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(params.toJson()),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['id'];
    } else {
      throw Exception('Failed to add product');
    }
  }

  @override
  Future<int> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/products/$id/'));
    if (response.statusCode == 204) {
      return id;
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/$id/'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<bool> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/${product.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update product');
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    // Not a true stream. Fetches once and closes.
    return Stream.fromFuture(getProducts());
  }
}
