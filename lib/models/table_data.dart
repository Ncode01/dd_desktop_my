import 'package:hive/hive.dart';

part 'table_data.g.dart';

@HiveType(typeId: 0)
class TableData {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int capacity;
  @HiveField(2)
  final TableStatus status;
  @HiveField(3)
  final List<String> items;

  TableData({
    required this.id,
    required this.capacity,
    required this.status,
    required this.items,
  });

  TableData copyWith({
    int? id,
    int? capacity,
    TableStatus? status,
    List<String>? items,
  }) {
    return TableData(
      id: id ?? this.id,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

@HiveType(typeId: 1)
enum TableStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  occupied,
  @HiveField(2)
  unavailable
}
