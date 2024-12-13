import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_data.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tables';

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey:
              "AIzaSyCpqOlhM6G4iWtjUTgm-847EC7Dz4kGqaU", // Replace with your values
          authDomain:
              "my-resturent-management-system.firebaseapp.com", // Replace with your values
          projectId:
              "my-resturent-management-system", // Replace with your values
          storageBucket:
              "my-resturent-management-system.firebasestorage.app", // Replace with your values
          messagingSenderId: "678820348376", // Replace with your values
          appId: "1:678820348376:web:1316ea314fdb71de4cf2ad",
          measurementId: "G-1YYXQPHRPY" // Replace with your values
          ),
    );
  }

  // CRUD Operations
  Future<void> saveTables(List<TableData> tables) async {
    final batch = _firestore.batch();

    for (var table in tables) {
      final docRef =
          _firestore.collection(_collection).doc(table.id.toString());
      batch.set(docRef, {
        'id': table.id,
        'capacity': table.capacity,
        'status': table.status.index,
        'items': table.items,
      });
    }

    await batch.commit();
  }

  Stream<List<TableData>> streamTables() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TableData(
          id: data['id'],
          capacity: data['capacity'],
          status: TableStatus.values[data['status']],
          items: List<String>.from(data['items']),
        );
      }).toList();
    });
  }

  Future<void> updateTable(TableData table) async {
    await _firestore.collection(_collection).doc(table.id.toString()).set({
      'id': table.id,
      'capacity': table.capacity,
      'status': table.status.index,
      'items': table.items,
    });
  }
}
