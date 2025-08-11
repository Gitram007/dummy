import 'package:inventory_management/src/domain/entities/add_material_params.dart';
import 'package:inventory_management/src/domain/entities/material.dart';

abstract class IMaterialRepository {
  Future<List<Material>> getMaterials();
  Stream<List<Material>> watchMaterials();
  Future<int> addMaterial(AddMaterialParams params);
  Future<bool> updateMaterial(Material material);
  Future<int> deleteMaterial(int id);
  Future<Material> getMaterialById(int id);
}
