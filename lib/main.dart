import 'package:flutter/material.dart';
import 'models/table_data.dart';
import 'package:flutter/services.dart';
import 'pages/menu_page.dart';
import 'widgets/order_summary.dart';
import 'services/local_storage_service.dart';
import 'services/repository.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await LocalStorageService.initialize();

  runApp(RestaurantManagementApp());
}

class RestaurantManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Repository _repository = Repository();
  final List<TableData> tables = [];
  StreamSubscription<List<TableData>>? _tablesSubscription;
  TableData? selectedTable;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  Future<void> _initializeRepository() async {
    await _repository.initialize();
    _subscribeToTables();
  }

  @override
  void dispose() {
    _tablesSubscription?.cancel();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _subscribeToTables() {
    _tablesSubscription = _repository.streamTables().listen((updatedTables) {
      setState(() {
        tables.clear();
        tables.addAll(updatedTables);
      });
    }, onError: (error) {
      print('Error streaming tables: $error');
      // Initialize with default tables if there's an error
      if (tables.isEmpty) {
        tables.addAll(List.generate(
          6,
          (index) => TableData(
            id: index + 1,
            capacity: 4,
            status: TableStatus.available,
            items: [],
          ),
        ));
        _repository.saveTables(tables);
      }
    });
  }

  void _saveTablesData() {
    _repository.saveTables(tables);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      // Update key handling for number keys
      Map<LogicalKeyboardKey, int> keyToTableNumber = {
        LogicalKeyboardKey.digit1: 1,
        LogicalKeyboardKey.digit2: 2,
        LogicalKeyboardKey.digit3: 3,
        LogicalKeyboardKey.digit4: 4,
        LogicalKeyboardKey.digit5: 5,
        LogicalKeyboardKey.digit6: 6,
      };

      if (keyToTableNumber.containsKey(key)) {
        int tableNumber = keyToTableNumber[key]!;
        if (tableNumber <= tables.length) {
          setState(() {
            selectedTable = tables[tableNumber - 1];
          });
        }
      }

      // Shortcut for takeaway
      if (key == LogicalKeyboardKey.keyT) {
        _initiateTakeaway();
      }

      // Shortcut for add items
      if (key == LogicalKeyboardKey.keyA && event.isControlPressed) {
        _navigateToMenuPage();
      }

      // Shortcut for checkout
      if (key == LogicalKeyboardKey.keyC && event.isControlPressed) {
        _checkoutTable();
      }

      // Open menu on Enter key press
      if (key == LogicalKeyboardKey.enter && selectedTable != null) {
        _navigateToMenuPage();
      }
    }
  }

  void selectTable(TableData table) {
    setState(() {
      selectedTable = table;
    });
  }

  void _initiateTakeaway() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MenuPage(isTakeaway: true, onItemSelected: _addItemToTable),
      ),
    );
  }

  void _addItemToTable(String item) {
    if (selectedTable != null) {
      setState(() {
        int tableIndex = tables.indexWhere((t) => t.id == selectedTable!.id);
        if (tableIndex != -1) {
          TableData updatedTable = tables[tableIndex].copyWith(
            items: List.from(tables[tableIndex].items)..add(item),
            status: TableStatus.occupied,
          );
          tables[tableIndex] = updatedTable;
          selectedTable = updatedTable;
          _repository.updateTable(updatedTable);
        }
      });
    }
  }

  void _navigateToMenuPage() {
    if (selectedTable != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(
            table: selectedTable,
            isTakeaway: false,
            onItemSelected: _addItemToTable,
          ),
        ),
      ).then((_) {
        setState(() {}); // Refresh the state after returning from the menu page
      });
    }
  }

  void _checkoutTable() {
    if (selectedTable != null) {
      int tableIndex = tables.indexWhere((t) => t.id == selectedTable!.id);
      if (tableIndex != -1) {
        TableData updatedTable = tables[tableIndex].copyWith(
          items: [],
          status: TableStatus.available,
        );
        setState(() {
          tables[tableIndex] = updatedTable;
          selectedTable = updatedTable;
        });
        _repository.updateTable(updatedTable);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationSidebar(),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Tables',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Table Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final isSelected = selectedTable?.id == table.id;

                        // Determine the background color based on status
                        Color backgroundColor;
                        IconData statusIcon;
                        if (table.status == TableStatus.available) {
                          backgroundColor = Colors.green.withOpacity(0.7);
                          statusIcon = Icons.check_circle;
                        } else if (table.status == TableStatus.occupied) {
                          backgroundColor = Colors.red.withOpacity(0.7);
                          statusIcon = Icons.schedule;
                        } else {
                          backgroundColor = Colors.grey.withOpacity(0.7);
                          statusIcon = Icons.close;
                        }

                        return GestureDetector(
                          onTap: () => selectTable(table),
                          child: Container(
                            key: Key(
                                'table_${table.id}_container'), // Assign Key
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: backgroundColor,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.blueAccent, width: 3)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'Table ${table.id}',
                                    key: Key(
                                        'table_${table.id}_text'), // Assign Key
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    statusIcon,
                                    color: Colors.white,
                                    size: 32,
                                    key: Key(
                                        'table_${table.id}_status_icon'), // Assign Key
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Additional Buttons (if any)
                  ElevatedButton(
                    key: Key('start_takeaway_button'), // Assign Key
                    onPressed: _initiateTakeaway,
                    child: Text('Start Takeaway Order (T)'),
                  ),
                ],
              ),
            ),
          ),
          // Adjusted OrderSummary container
          Container(
            width: 300, // Fixed width for consistency
            padding: const EdgeInsets.all(16.0),
            child: OrderSummary(
              selectedTable: selectedTable,
              onCheckout: _checkoutTable, // Pass the checkout method
              onAddItem: _addItemToTable, // Add this parameter
            ),
          ),
        ],
      ),
    );
  }

  // Define NavigationSidebar internally
  Widget _buildNavigationSidebar() {
    return Container(
      width: 60,
      decoration: defaultGlassEffect(
        BoxDecoration(color: Colors.transparent),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              IconButton(
                key: Key('home_button'), // Assign Key
                onPressed: () {},
                icon: Icon(Icons.home, color: Colors.white, size: 28),
              ),
              SizedBox(height: 20),
              IconButton(
                key: Key('inventory_button'), // Assign Key
                onPressed: () {},
                icon: Icon(Icons.inventory, color: Colors.white, size: 28),
              ),
              SizedBox(height: 20),
              IconButton(
                key: Key('table_chart_button'), // Assign Key
                onPressed: () {},
                icon: Icon(Icons.table_chart, color: Colors.white, size: 28),
              ),
            ],
          ),
          IconButton(
            key: Key('settings_button'), // Assign Key
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// Add the defaultGlassEffect function here
BoxDecoration defaultGlassEffect(BoxDecoration decoration) {
  return decoration.copyWith(
    color: Colors.white.withOpacity(0.1),
    backgroundBlendMode: BlendMode.overlay,
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );
}

class TabBarMenu extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const TabBarMenu({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Appetizers',
      'Breakfast',
      'Lunch',
      'Dinner',
      'Beverages',
      'Dessert'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return CategoryChip(
            label: category,
            isSelected: category == selectedCategory,
            onSelected: () => onCategorySelected(category),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
        onPressed: onSelected,
        backgroundColor:
            isSelected ? Colors.white : Colors.grey.withOpacity(0.2),
      ),
    );
  }
}
