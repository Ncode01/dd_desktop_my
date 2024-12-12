import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dd/main.dart';
import 'package:dd/models/table_data.dart';
import 'package:dd/widgets/order_summary.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure this import is present

void main() {
  // Mock SharedPreferences before any tests run
  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // Mock initial values
  });

  group('RestaurantManagementApp Widget Tests', () {
    testWidgets('App initializes correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle(); // Wait for any async operations

      // Verify the title is displayed
      expect(find.text('Tables'), findsOneWidget);

      // Verify all tables are displayed using Keys
      for (int i = 1; i <= 6; i++) {
        expect(find.byKey(Key('table_${i}_container')), findsOneWidget);
      }

      // Verify 'Start Takeaway Order' button is present using Key
      expect(find.byKey(Key('start_takeaway_button')), findsOneWidget);

      // Verify OrderSummary shows 'No Table Selected' using Key
      expect(find.byKey(Key('no_table_selected_text')), findsOneWidget);
    });

    testWidgets('Select a table and verify selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Select Table 1 using Key
      await tester.tap(find.byKey(Key('table_1_container')));
      await tester.pumpAndSettle();

      // Verify Table 1 is highlighted by checking the status icon
      final statusIconFinder = find.descendant(
        of: find.byKey(Key('table_1_container')),
        matching: find.byIcon(Icons.check_circle),
      );
      expect(statusIconFinder, findsOneWidget);

      // Verify OrderSummary displays Table 1 using Key
      expect(find.byKey(Key('order_summary_table_id')), findsOneWidget);
      expect(find.byKey(Key('order_summary_table_id')).evaluate().single.widget,
          isA<Text>().having((w) => w.data, 'text', 'Table 1'));
    });

    testWidgets('Add item to a table and verify update',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Select Table 1 using Key
      await tester.tap(find.byKey(Key('table_1_container')));
      await tester.pumpAndSettle();

      // Tap 'Add Items (Ctrl + A)' button
      await tester.tap(find.byKey(Key('add_items_button')));
      await tester.pumpAndSettle();

      // **New Step:** Verify that MenuPage is displayed
      expect(find.text('Menu'), findsOneWidget);

      // Add 'Appetizer 0' to cart using Key
      await tester.tap(find.byKey(Key('appetizer_0_button')));
      await tester.pumpAndSettle();

      // Confirm order by tapping 'Confirm Order (Enter)' button using Key
      await tester.tap(find.byKey(Key('confirm_order_button')));
      await tester.pumpAndSettle();

      // Verify 'Appetizer 0' is added in OrderSummary using Key
      expect(find.byKey(Key('order_item_Appetizer 0')), findsOneWidget);

      // Verify Table 1 status icon changed to 'Occupied' (Icons.schedule)
      final statusIconFinder = find.descendant(
        of: find.byKey(Key('table_1_container')),
        matching: find.byIcon(Icons.schedule),
      );
      expect(statusIconFinder, findsOneWidget);
    });

    testWidgets('Checkout table and verify status reset',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Select Table 1
      await tester.tap(find.byKey(Key('table_1_container')));
      await tester.pumpAndSettle();

      // Add an item to Table 1
      await tester.tap(find.byKey(Key('add_items_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('appetizer_0_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('confirm_order_button')));
      await tester.pumpAndSettle();

      // Verify Table 1 status is 'Occupied' (Icons.schedule)
      expect(
          find.descendant(
              of: find.byKey(Key('table_1_container')),
              matching: find.byIcon(Icons.schedule)),
          findsOneWidget);

      // Checkout Table 1 by tapping 'Checkout (Ctrl + C)' button
      await tester.tap(find.byKey(Key('checkout_button')));
      await tester.pumpAndSettle();

      // Verify Table 1 status is 'Available' (Icons.check_circle)
      expect(
          find.descendant(
              of: find.byKey(Key('table_1_container')),
              matching: find.byIcon(Icons.check_circle)),
          findsOneWidget);

      // Verify items are cleared from OrderSummary
      expect(find.byKey(Key('order_item_Appetizer 0')), findsNothing);
    });

    testWidgets('Start takeaway order and verify navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Tap 'Start Takeaway Order (T)' button
      await tester.tap(find.byKey(Key('start_takeaway_button')));
      await tester.pumpAndSettle();

      // Verify navigation to Takeaway Order MenuPage
      expect(find.text('Takeaway Order'), findsOneWidget);

      // **New Step:** Select 'Beverages' category to display beverage items
      final beveragesChip = find.byKey(Key('beverages_chip'));
      expect(beveragesChip, findsOneWidget);

      // Scroll to the 'Beverages' chip if it's not visible
      await tester.scrollUntilVisible(
        beveragesChip,
        500.0,
        scrollable: find.descendant(
          of: find.byKey(Key('category_scrollable')),
          matching: find.byType(Scrollable),
        ), // Updated to find the actual Scrollable within the SingleChildScrollView
      );
      await tester.tap(beveragesChip);
      await tester.pumpAndSettle();

      // Add 'Beverage 1' to cart using Key
      await tester.tap(find.byKey(Key('beverage_1_button')));
      await tester.pumpAndSettle();

      // Confirm order by tapping 'Confirm Order (Enter)' button using Key
      await tester.tap(find.byKey(Key('confirm_order_button')));
      await tester.pumpAndSettle();

      // Since it's a takeaway, no table should be selected
      expect(find.byKey(Key('no_table_selected_text')), findsOneWidget);
    });

    testWidgets('Verify keyboard shortcuts work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Simulate pressing 'Digit2' key to select Table 2
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();

      // Verify Table 2 is selected by checking the status icon
      final statusIconFinder = find.descendant(
        of: find.byKey(Key('table_2_container')),
        matching: find.byIcon(Icons.check_circle),
      );
      expect(statusIconFinder, findsOneWidget);

      // Simulate pressing 'Ctrl + A' to add items
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA); // Add KeyUp for 'A'
      await tester.sendKeyUpEvent(
          LogicalKeyboardKey.controlLeft); // Add KeyUp for Control

      // Verify navigation to MenuPage
      expect(find.text('Table 2 Order'), findsOneWidget);

      // **New Step:** Select 'Dessert' category before tapping 'dessert_3_button'
      final dessertChip = find.byKey(Key('dessert_chip'));
      expect(dessertChip, findsOneWidget);

      await tester.scrollUntilVisible(
        dessertChip,
        500.0,
        scrollable: find.descendant(
          of: find.byKey(Key('category_scrollable')),
          matching: find.byType(Scrollable),
        ), // Updated to find the actual Scrollable within the SingleChildScrollView
      );

      await tester.tap(dessertChip);
      await tester.pumpAndSettle();

      // Simulate adding 'Dessert 3' using Key
      await tester.tap(find.byKey(Key('dessert_3_button')));
      await tester.pumpAndSettle();

      // Confirm order
      await tester.tap(find.byKey(Key('confirm_order_button')));
      await tester.pumpAndSettle();

      // Verify 'Dessert 3' is added to OrderSummary using Key
      expect(find.byKey(Key('order_item_Dessert 3')), findsOneWidget);

      // Simulate pressing 'Ctrl + C' to checkout
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC); // Add KeyUp for 'C'
      await tester.sendKeyUpEvent(
          LogicalKeyboardKey.controlLeft); // Add KeyUp for Control

      // Verify Table 2 status is 'Available' (Icons.check_circle)
      expect(
          find.descendant(
              of: find.byKey(Key('table_2_container')),
              matching: find.byIcon(Icons.check_circle)),
          findsOneWidget);

      // Verify 'Dessert 3' is cleared from OrderSummary
      expect(find.byKey(Key('order_item_Dessert 3')), findsNothing);
    });

    testWidgets('Verify OrderSummary displays correctly when no table selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Initially, no table is selected
      expect(find.byKey(Key('no_table_selected_text')), findsOneWidget);
      expect(find.byKey(Key('order_summary_title')),
          findsNothing); // Corrected expectation
    });

    testWidgets('Verify OrderSummary displays items correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();

      // Select Table 3
      await tester.tap(find.byKey(Key('table_3_container')));
      await tester.pumpAndSettle();

      // Add items to Table 3
      await tester.tap(find.byKey(Key('add_items_button')));
      await tester.pumpAndSettle();

      // **Select 'Lunch' category before adding items**
      final lunchChip = find.byKey(Key('lunch_chip'));
      expect(lunchChip, findsOneWidget);
      await tester.tap(lunchChip);
      await tester.pumpAndSettle();

      // Scroll to the 'Lunch 2' button if it's not visible
      await tester.scrollUntilVisible(
        find.byKey(Key('lunch_2_button')),
        500.0,
        scrollable: find.descendant(
          of: find.byKey(Key('category_scrollable')),
          matching: find.byType(Scrollable),
        ), // Updated to find the actual Scrollable within the SingleChildScrollView
      );

      // Add 'Lunch 2' to cart using Key
      await tester.tap(find.byKey(Key('lunch_2_button')));
      await tester.pumpAndSettle();

      // Verify 'Lunch 2' is added in OrderSummary using Key
      expect(find.byKey(Key('order_item_Lunch 2')), findsOneWidget);

      // Verify Table 3 status icon changed to 'Occupied' (Icons.schedule)
      final statusIconFinder = find.descendant(
        of: find.byKey(Key('table_3_container')),
        matching: find.byIcon(Icons.schedule),
      );
      expect(statusIconFinder, findsOneWidget);
    });

    testWidgets('Verify navigation sidebar buttons exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(RestaurantManagementApp());
      await tester.pumpAndSettle();
      // Verify Home, Inventory, Table Chart, and Settings buttons exist using Keys      expect(find.byKey(Key('home_button')), findsOneWidget);      expect(find.byKey(Key('inventory_button')), findsOneWidget);      expect(find.byKey(Key('table_chart_button')), findsOneWidget);      expect(find.byKey(Key('settings_button')), findsOneWidget);    });

      // Add more test cases as needed to cover additional functionalities
    });
  });
}
