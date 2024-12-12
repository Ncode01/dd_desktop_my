import 'package:flutter/material.dart';
import '../models/table_data.dart';
import '../pages/menu_page.dart';

class OrderSummary extends StatelessWidget {
  final TableData? selectedTable;
  final VoidCallback onCheckout;
  final Function(String) onAddItem; // Add this callback

  const OrderSummary({
    Key? key,
    this.selectedTable,
    required this.onCheckout,
    required this.onAddItem, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed unnecessary Padding
      child: selectedTable == null
          ? Center(
              child: Text(
                'No Table Selected',
                key: Key('no_table_selected_text'), // Assign Key
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  key: Key(
                      'order_summary_title'), // Ensure this key is unique and correctly assigned
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Table ${selectedTable!.id}',
                  key: Key('order_summary_table_id'), // Assign Key
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: selectedTable!.items.isEmpty
                      ? Center(
                          child: Text(
                            'No items added',
                            key: Key('no_items_added_text'), // Assign Key
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: selectedTable!.items.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                selectedTable!.items[index],
                                key: Key(
                                    'order_item_${selectedTable!.items[index]}'), // Assign Key
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                'LKR 500',
                                key: Key(
                                    'order_item_price_${selectedTable!.items[index]}'), // Assign Key
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: Key('add_items_button'), // Assign Key
                        onPressed: () {
                          if (selectedTable != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuPage(
                                  table: selectedTable,
                                  onItemSelected: onAddItem, // Use the callback
                                ),
                              ),
                            );
                          }
                        },
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
                        key: Key('checkout_button'), // Assign Key
                        onPressed: onCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Checkout (Ctrl + C)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
