import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

defaultColor(double opacity) => Colors.black.withOpacity(opacity);
defaultGlassEffect(BoxDecoration decoration) => decoration.copyWith(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [defaultColor(0.4), defaultColor(0.2)],
        stops: const [0.0, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 30,
          offset: Offset(0, 5),
        ),
      ],
    );

void main() {
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
  final List<TableData> tables = List.generate(
    6,
    (index) => TableData(
      id: index + 1,
      capacity: 4,
      status: TableStatus.available,
      items: [],
    ),
  );

  TableData? selectedTable;

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      // Select table using number keys
      if (key.keyId >= LogicalKeyboardKey.digit1.keyId &&
          key.keyId <= LogicalKeyboardKey.digit6.keyId) {
        int tableNumber = key.keyId - LogicalKeyboardKey.digit1.keyId + 1;
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
        builder: (context) => MenuPage(isTakeaway: true),
      ),
    );
  }

  void _navigateToMenuPage() {
    if (selectedTable != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(table: selectedTable),
        ),
      );
    }
  }

  void _checkoutTable() {
    // Logic for checkout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: NavigationSidebar(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Table',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
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
                        return GestureDetector(
                          onTap: () => selectTable(table),
                          child: Container(
                            decoration: defaultGlassEffect(
                              BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.blueAccent, width: 2)
                                    : null,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Table ${table.id}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Capacity: ${table.capacity}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: table.items.isEmpty
                                        ? Colors.greenAccent
                                        : Colors.orangeAccent,
                                  ),
                                  child: Text(
                                    table.items.isEmpty
                                        ? 'Available'
                                        : 'Occupied',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initiateTakeaway,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Takeaway (T)'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: defaultGlassEffect(
                  BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: OrderSummary(
                  selectedTable: selectedTable,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  final TableData? table;
  final bool isTakeaway;

  const MenuPage({Key? key, this.table, this.isTakeaway = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isTakeaway ? 'Takeaway Order' : 'Table ${table?.id ?? ''} Order'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: NavigationSidebar(),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TabBarMenu(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: 12, // Placeholder for menu items
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Logic to add item to order summary
                          },
                          child: Container(
                            decoration: defaultGlassEffect(
                              BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Item $index',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'LKR 500',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TabBarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(label: 'Appetizers'),
          CategoryChip(label: 'Breakfast'),
          CategoryChip(label: 'Lunch'),
          CategoryChip(label: 'Dinner'),
          CategoryChip(label: 'Beverages'),
          CategoryChip(label: 'Dessert'),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          // Logic for filtering menu items
        },
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  final TableData? selectedTable;

  const OrderSummary({Key? key, this.selectedTable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          selectedTable == null
              ? Center(
                  child: Text(
                    'No Table Selected',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${selectedTable!.id}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      if (selectedTable!.items.isEmpty)
                        Center(
                          child: Text(
                            'No items added',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: selectedTable!.items.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(selectedTable!.items[index],
                                    style: TextStyle(color: Colors.white)),
                                trailing: Text('LKR 500',
                                    style: TextStyle(color: Colors.white70)),
                              );
                            },
                          ),
                        ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Add Items (Ctrl + A)'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Checkout (Ctrl + C)'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: defaultGlassEffect(
        BoxDecoration(color: Colors.transparent),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.home, color: Colors.white, size: 28),
              ),
              SizedBox(height: 20),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.inventory, color: Colors.white, size: 28),
              ),
              SizedBox(height: 20),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.table_chart, color: Colors.white, size: 28),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

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
}

enum TableStatus { available, occupied, unavailable }
