import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../domain/entities/product_material_mapping.dart';
import '../../domain/repositories/product_material_repository.dart';

class ProductMaterialRepositoryApiImpl implements IProductMaterialRepository {
  final String _baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  @override
  Future<void> addMapping(ProductMaterialMapping mapping) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/productmaterials/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mapping.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add mapping');
    }
  }

  @override
  Future<List<ProductMaterialMapping>> getMappingsForProduct(int productId) async {
    final response = await http.get(Uri.parse('$_baseUrl/productmaterials/?product_id=$productId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ProductMaterialMapping.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load mappings');
    }
  }

  @override
  Future<int> removeMapping(int productId, int materialId) async {
    // First, get the mapping ID
    final response = await http.get(Uri.parse('$_baseUrl/productmaterials/?product_id=$productId&material_id=$materialId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final int mappingId = data.first['id'];
        // Then, delete the mapping
        final deleteResponse = await http.delete(Uri.parse('$_baseUrl/productmaterials/$mappingId/'));
        if (deleteResponse.statusCode == 204) {
          return mappingId;
        } else {
          throw Exception('Failed to remove mapping');
        }
      } else {
        throw Exception('Mapping not found');
      }
    } else {
      throw Exception('Failed to get mapping');
    }
  }

  @override
  Stream<List<ProductMaterialMapping>> watchMappingsForProduct(int productId) {
    return Stream.fromFuture(getMappingsForProduct(productId));
  }
}
