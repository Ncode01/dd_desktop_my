import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/table_data.dart';

// Include defaultGlassEffect function
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

// Include TabBarMenu widget
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
      key: Key('category_scrollable'), // Assign a unique Key
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

// Include CategoryChip widget
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
        key: Key('${label.toLowerCase()}_chip'), // Assign Key
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

class MenuPage extends StatefulWidget {
  final TableData? table;
  final bool isTakeaway;
  final Function(String) onItemSelected;

  const MenuPage({
    Key? key,
    this.table,
    this.isTakeaway = false,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = 'Appetizers';
  final Map<String, List<String>> menuItems = {
    'Appetizers': List.generate(5, (index) => 'Appetizer $index'),
    'Breakfast': List.generate(5, (index) => 'Breakfast $index'),
    'Lunch': List.generate(5, (index) => 'Lunch $index'),
    'Dinner': List.generate(5, (index) => 'Dinner $index'),
    'Beverages': List.generate(5, (index) => 'Beverage $index'),
    'Dessert': List.generate(5, (index) => 'Dessert $index'),
  };

  final List<String> cartItems = [];

  void _addItemToCart(String item) {
    setState(() {
      cartItems.add(item);
    });
  }

  void _checkoutCart() {
    for (var item in cartItems) {
      widget.onItemSelected(item);
    }
    Navigator.pop(context);
  }

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
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _checkoutCart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTakeaway
            ? 'Takeaway Order'
            : 'Table ${widget.table?.id ?? ''} Order'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _checkoutCart,
          ),
        ],
      ),
      body: Row(
        children: [
          _buildNavigationSidebar(),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                // Menu Items
                Expanded(
                  flex: 3,
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
                              child: TabBarMenu(
                                selectedCategory: selectedCategory,
                                onCategorySelected: (category) {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: true, // Add this line
                            physics:
                                NeverScrollableScrollPhysics(), // Add this line
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                            ),
                            itemCount: menuItems[selectedCategory]!.length,
                            itemBuilder: (context, index) {
                              final item = menuItems[selectedCategory]![index];
                              return GestureDetector(
                                key: Key(
                                    '${item.toLowerCase().replaceAll(' ', '_')}_button'), // Ensure this Key is correctly assigned
                                onTap: () {
                                  _addItemToCart(item);
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
                                        item,
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
                // Cart Section
                Container(
                  width: 300, // Fixed width for the cart
                  padding: const EdgeInsets.all(16.0),
                  decoration: defaultGlassEffect(
                    BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: cartItems.isEmpty
                            ? Center(
                                child: Text(
                                  'No items in cart',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return ListTile(
                                    title: Text(
                                      item,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Text(
                                      'LKR 500',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        key: Key(
                            'confirm_order_button'), // Ensure this key is correctly assigned
                        onPressed: _checkoutCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Confirm Order (Enter)'),
                      ),
                    ],
                  ),
                ),
              ],
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
