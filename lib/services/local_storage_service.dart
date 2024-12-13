import 'package:hive_flutter/hive_flutter.dart';
import '../models/table_data.dart';

class LocalStorageService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TableDataAdapter());
    Hive.registerAdapter(TableStatusAdapter());
  }
}
