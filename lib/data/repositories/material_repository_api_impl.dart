import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../domain/entities/add_material_params.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialRepositoryApiImpl implements IMaterialRepository {
  final String _baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  @override
  Future<int> addMaterial(AddMaterialParams params) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/materials/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(params.toJson()),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body)['id'];
    } else {
      throw Exception('Failed to add material');
    }
  }

  @override
  Future<int> deleteMaterial(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/materials/$id/'));
    if (response.statusCode == 204) {
      return id;
    } else {
      throw Exception('Failed to delete material');
    }
  }

  @override
  Future<Material> getMaterialById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/materials/$id/'));
    if (response.statusCode == 200) {
      return Material.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load material');
    }
  }

  @override
  Future<List<Material>> getMaterials() async {
    final response = await http.get(Uri.parse('$_baseUrl/materials/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Material.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load materials');
    }
  }

  @override
  Future<bool> updateMaterial(Material material) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/materials/${material.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(material.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update material');
    }
  }

  @override
  Stream<List<Material>> watchMaterials() {
    // Not a true stream. Fetches once and closes.
    return Stream.fromFuture(getMaterials());
  }
}
