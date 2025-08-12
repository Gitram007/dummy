import 'package:drift/drift.dart';
import '../local/database.dart' as db;
import '../../domain/entities/add_material_params.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialRepositoryImpl implements IMaterialRepository {
  final db.MaterialsDao _materialsDao;

  MaterialRepositoryImpl(this._materialsDao);

  Material _fromDb(db.Material dbMaterial) {
    return Material(
      id: dbMaterial.id,
      name: dbMaterial.name,
      description: dbMaterial.description,
      createdAt: dbMaterial.createdAt,
    );
  }

  db.MaterialsCompanion _toDbUpdate(Material material) {
    return db.MaterialsCompanion(
      id: Value(material.id),
      name: Value(material.name),
      description: Value(material.description),
      createdAt: Value(material.createdAt),
    );
  }

  @override
  Future<int> addMaterial(AddMaterialParams params) {
    final companion = db.MaterialsCompanion.insert(
      name: params.name,
      description: Value(params.description),
    );
    return _materialsDao.insertMaterial(companion);
  }

  @override
  Future<int> deleteMaterial(int id) {
    return _materialsDao.deleteMaterial(id);
  }

  @override
  Future<List<Material>> getMaterials() async {
    final dbMaterials = await _materialsDao.getAllMaterials();
    return dbMaterials.map(_fromDb).toList();
  }

  @override
  Future<bool> updateMaterial(Material material) {
    final companion = _toDbUpdate(material);
    return _materialsDao.updateMaterial(companion);
  }

  @override
  Stream<List<Material>> watchMaterials() {
    return _materialsDao.watchAllMaterials().map(
            (dbMaterials) => dbMaterials.map(_fromDb).toList()
    );
  }

  @override
  Future<Material> getMaterialById(int id) async {
    final dbMaterial = await _materialsDao.getMaterial(id);
    return _fromDb(dbMaterial);
  }
}
