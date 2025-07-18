import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_tables/interactive_tables.dart';

void main() {
  const testData = [
    {'ID': 1, 'Name': 'Alice', 'Age': 28},
    {'ID': 2, 'Name': 'Bob', 'Age': 34},
  ];

  // A helper function to wrap the widget in a MaterialApp and Scaffold
  Widget createTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('InteractiveTable displays headers and rows correctly',
          (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(createTestApp(
          const InteractiveTable(data: testData),
        ));

        // Verify that the column headers are present.
        expect(find.text('ID'), findsOneWidget);
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Age'), findsOneWidget);

        // Verify that the cell data is present.
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('28'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('34'), findsOneWidget);
      });

  testWidgets('InteractiveTable displays message when data is empty',
          (WidgetTester tester) async {
        // Build the widget with empty data.
        await tester.pumpWidget(createTestApp(
          const InteractiveTable(data: []),
        ));

        // Verify that the "No data to display" message is shown.
        expect(find.text('No data to display'), findsOneWidget);

        // Verify that no DataCells are rendered.
        expect(find.byType(DataCell), findsNothing);
      });

  testWidgets('InteractiveTable sorts data when a column header is tapped',
          (WidgetTester tester) async {
        // Build the widget with sortable enabled.
        await tester.pumpWidget(createTestApp(
          const InteractiveTable(
            data: testData,
            sortable: true,
          ),
        ));

        // Tap the 'Name' header to sort ascending.
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle(); // Use pumpAndSettle to wait for animations

        // Get the y-coordinates of the Text widgets.
        final aliceLocationAsc = tester.getTopLeft(find.text('Alice'));
        final bobLocationAsc = tester.getTopLeft(find.text('Bob'));

        // Verify that Alice is visually above Bob in the list.
        expect(aliceLocationAsc.dy, lessThan(bobLocationAsc.dy));

        // Tap the 'Name' header again to sort descending.
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle(); // Wait for animations again

        // Get the new y-coordinates.
        final aliceLocationDesc = tester.getTopLeft(find.text('Alice'));
        final bobLocationDesc = tester.getTopLeft(find.text('Bob'));

        // Verify that Bob is now visually above Alice in the list.
        expect(bobLocationDesc.dy, lessThan(aliceLocationDesc.dy));
      });

  testWidgets('InteractiveTable filters with internal search bar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          const InteractiveTable(
            data: testData,
            searchable: true, // Enable internal search
          ),
        ));

        // Enter 'Alice' into the internal search field.
        await tester.enterText(find.byType(TextField), 'Alice');
        await tester.pumpAndSettle();

        // Create specific finders that only look for text inside the DataTable.
        final findAliceInTable =
        find.descendant(of: find.byType(DataTable), matching: find.text('Alice'));
        final findBobInTable =
        find.descendant(of: find.byType(DataTable), matching: find.text('Bob'));

        // Now, only Alice should be visible inside the table.
        expect(findAliceInTable, findsOneWidget);
        expect(findBobInTable, findsNothing);
      });

  testWidgets('InteractiveTable filters with external controller',
          (WidgetTester tester) async {
        final searchController = TextEditingController();

        await tester.pumpWidget(createTestApp(
          InteractiveTable(
            data: testData,
            searchController: searchController, // Provide external controller
          ),
        ));

        // Initially, both should be visible.
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        // No internal TextField should be created.
        expect(find.byType(TextField), findsNothing);

        // Programmatically set the text on the external controller.
        searchController.text = 'Bob';
        await tester.pumpAndSettle();

        // Now, only Bob should be visible.
        expect(find.text('Alice'), findsNothing);
        expect(find.text('Bob'), findsOneWidget);

        searchController.dispose();
      });
}