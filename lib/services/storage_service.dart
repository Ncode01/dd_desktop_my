import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/table_data.dart';

class StorageService {
  static const String tableKey = 'tables';

  static Future<void> saveTables(List<TableData> tables) async {
    final prefs = await SharedPreferences.getInstance();
    final tablesJson = tables
        .map((table) => {
              'id': table.id,
              'capacity': table.capacity,
              'status': table.status.index,
              'items': table.items,
            })
        .toList();
    await prefs.setString(tableKey, jsonEncode(tablesJson));
  }

  static Future<List<TableData>> loadTables() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tablesString = prefs.getString(tableKey);
    if (tablesString == null) return [];

    final List<dynamic> tablesJson = jsonDecode(tablesString);
    return tablesJson
        .map((json) => TableData(
              id: json['id'],
              capacity: json['capacity'],
              status: TableStatus.values[json['status']],
              items: List<String>.from(json['items']),
            ))
        .toList();
  }
}
