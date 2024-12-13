import 'package:hive_flutter/hive_flutter.dart';
import '../models/table_data.dart';

class Repository {
  static const String _boxName = 'tables';
  late Box<TableData> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<TableData>(_boxName);
  }

  Future<void> saveTables(List<TableData> tables) async {
    await _box.clear();
    for (var table in tables) {
      await _box.put(table.id.toString(), table);
    }
  }

  Future<void> updateTable(TableData table) async {
    await _box.put(table.id.toString(), table);
  }

  Stream<List<TableData>> streamTables() async* {
    yield _box.values.toList();
    yield* _box.watch().map((_) => _box.values.toList());
  }

  Future<void> dispose() async {
    await _box.close();
  }
}
