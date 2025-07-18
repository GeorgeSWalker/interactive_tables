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

  final List<Map<String, dynamic>> _sampleData = List.generate(
    50,
        (index) => {
      'ID': index + 1,
      'Name': 'User Name ${index + 1}',
      'Role': (index % 3 == 0)
          ? 'Developer'
          : (index % 3 == 1)
          ? 'Designer'
          : 'Manager',
    },
  );

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
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'External Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: InteractiveTable(
                  searchController: _searchController,
                  sortable: true,
                  pagination: true,
                  rowsPerPage: 15,
                  // --- Sticky Header Configuration ---
                  stickyHeaders: true, // Enable sticky headers
                  columnWidths: const { // Provide column widths
                    'ID': 50.0,
                    'Name': 150.0,
                    'Role': 150.0,
                  },
                  // ------------------------------------
                  tableStyle: TableStyle(
                    headerColor: Colors.blueGrey[800],
                    evenRowColor: Colors.grey[850],
                    oddRowColor: Colors.grey[900],
                    headerTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  data: _sampleData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}