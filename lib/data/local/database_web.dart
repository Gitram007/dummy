import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'app.db',
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
    );
    return result.resolvedExecutor;
  });
}
