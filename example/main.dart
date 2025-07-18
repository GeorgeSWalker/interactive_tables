import 'package:flutter/material.dart';
import 'package:interactive_tables/interactive_tables.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Table Example',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Interactive Table Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // This is our external search field
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'External Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              // The table now takes up the remaining space
              Expanded(
                child: InteractiveTable(
                  // We pass the controller here
                  searchController: _searchController,
                  sortable: true,
                  tableStyle: TableStyle(
                    headerColor: Colors.blueGrey[800],
                    evenRowColor: Colors.grey[850],
                    oddRowColor: Colors.grey[900],
                    headerTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    rowTextStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    cellPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                  data: const [
                    {'ID': 1, 'Name': 'John Doe', 'Age': 30, 'Role': 'Developer'},
                    {'ID': 2, 'Name': 'Jane Smith', 'Age': 25, 'Role': 'Designer'},
                    {'ID': 3, 'Name': 'Peter Jones', 'Age': 42, 'Role': 'Manager'},
                    {'ID': 4, 'Name': 'Lisa Williams', 'Age': 35, 'Role': 'Product Owner'},
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}