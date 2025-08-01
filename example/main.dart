import 'package:flutter/material.dart';
import 'package:power_table/power_table.dart';

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
  List<Map<String, dynamic>> _selectedRows = [];

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
      title: 'Power Table Example',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Power Table Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'External Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              Text('${_selectedRows.length} rows selected'),
              const SizedBox(height: 10),
              Expanded(
                child: InteractiveTable(
                  searchController: _searchController,
                  sortable: true,
                  pagination: true,
                  rowsPerPage: 15,
                  stickyHeaders: true,
                  columnWidths: const {
                    'ID': 50.0,
                    'Name': 150.0,
                    'Role': 150.0,
                    'Select': 60.0,
                  },
                  selectable: true,
                  onSelectionChanged: (selectedRows) {
                    setState(() {
                      _selectedRows = selectedRows;
                    });
                  },
                  conditionalTextStyleBuilder: (String header, dynamic value) {
                    if (header == 'Role') {
                      if (value == 'Developer') {
                        return const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold);
                      }
                      if (value == 'Manager') {
                        return const TextStyle(color: Colors.yellowAccent);
                      }
                    }
                    return null;
                  },
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
