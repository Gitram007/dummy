import 'package:inventory_management/src/data/datasources/remote/api_client.dart';
import 'package:inventory_management/src/domain/entities/add_material_params.dart';
import 'package:inventory_management/src/domain/entities/material.dart';
import 'package:inventory_management/src/domain/repositories/material_repository.dart';

class MaterialRepositoryWebImpl implements IMaterialRepository {
  final ApiClient apiClient;

  MaterialRepositoryWebImpl(this.apiClient);

  @override
  Future<int> addMaterial(AddMaterialParams params) async {
    final material = await apiClient.addMaterial(params);
    return material.id;
  }

  @override
  Future<int> deleteMaterial(int id) async {
    await apiClient.deleteMaterial(id);
    return 1;
  }

  @override
  Future<Material> getMaterialById(int id) {
    return apiClient.getMaterial(id);
  }

  @override
  Future<List<Material>> getMaterials() {
    return apiClient.getMaterials();
  }

  @override
  Future<bool> updateMaterial(Material material) async {
    await apiClient.updateMaterial(material);
    return true;
  }

  @override
  Stream<List<Material>> watchMaterials() {
    return Stream.value([]);
  }
}
