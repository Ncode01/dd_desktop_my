class TableData {
  final int id;
  final int capacity;
  final TableStatus status;
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

enum TableStatus { available, occupied, unavailable }
