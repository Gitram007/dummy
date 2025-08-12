import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// Define tables
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Materials extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ProductMaterial')
class ProductMaterials extends Table {
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get materialId => integer().references(Materials, #id, onDelete: KeyAction.cascade)();
  RealColumn get quantity => real()();
  DateTimeColumn get assignedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productId, materialId};
}

@DataClassName('ProductionLog')
class ProductionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  RealColumn get quantityProduced => real()();
  DateTimeColumn get productionDate => dateTime()();
}

@DriftDatabase(
    tables: [Products, Materials, ProductMaterials, ProductionLogs],
    daos: [ProductsDao, MaterialsDao, ProductMaterialsDao, ProductionLogsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// DAOs
@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(AppDatabase db) : super(db);

  Future<List<Product>> getAllProducts() => select(products).get();
  Stream<List<Product>> watchAllProducts() => select(products).watch();
  Future<int> insertProduct(ProductsCompanion product) =>
      into(products).insert(product);
  Future<bool> updateProduct(ProductsCompanion product) =>
      update(products).replace(product);
  Future<int> deleteProduct(int id) =>
      (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  Future<Product> getProduct(int id) =>
      (select(products)..where((tbl) => tbl.id.equals(id))).getSingle();
}

@DriftAccessor(tables: [Materials])
class MaterialsDao extends DatabaseAccessor<AppDatabase>
    with _$MaterialsDaoMixin {
  MaterialsDao(AppDatabase db) : super(db);

  Future<List<Material>> getAllMaterials() => select(materials).get();
  Stream<List<Material>> watchAllMaterials() => select(materials).watch();
  Future<int> insertMaterial(MaterialsCompanion material) =>
      into(materials).insert(material);
  Future<bool> updateMaterial(MaterialsCompanion material) =>
      update(materials).replace(material);
  Future<int> deleteMaterial(int id) =>
      (delete(materials)..where((tbl) => tbl.id.equals(id))).go();
  Future<Material> getMaterial(int id) =>
      (select(materials)..where((tbl) => tbl.id.equals(id))).getSingle();
}

@DriftAccessor(tables: [ProductMaterials])
class ProductMaterialsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductMaterialsDaoMixin {
  ProductMaterialsDao(AppDatabase db) : super(db);

  Future<List<ProductMaterial>> getMaterialsForProduct(int productId) {
    return (select(productMaterials)
      ..where((tbl) => tbl.productId.equals(productId)))
        .get();
  }

  Stream<List<ProductMaterial>> watchMaterialsForProduct(int productId) {
    return (select(productMaterials)
      ..where((tbl) => tbl.productId.equals(productId)))
        .watch();
  }

  Future<void> addMaterialToProduct(ProductMaterialsCompanion entry) {
    return into(productMaterials).insert(entry, mode: InsertMode.replace);
  }

  Future<int> removeMaterialFromProduct(int productId, int materialId) {
    return (delete(productMaterials)
      ..where((tbl) =>
      tbl.productId.equals(productId) & tbl.materialId.equals(materialId)))
        .go();
  }
}

@DriftAccessor(tables: [ProductionLogs])
class ProductionLogsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductionLogsDaoMixin {
  ProductionLogsDao(AppDatabase db) : super(db);

  Future<void> addProductionLog(ProductionLogsCompanion log) =>
      into(productionLogs).insert(log);

  Future<List<ProductionLog>> getProductionLogsInDateRange(
      DateTime start, DateTime end) {
    return (select(productionLogs)
      ..where((tbl) =>
          tbl.productionDate.isBetween(Variable(start), Variable(end))))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
