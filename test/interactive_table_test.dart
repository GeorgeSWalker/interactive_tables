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
}