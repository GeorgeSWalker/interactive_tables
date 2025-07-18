import 'package:flutter/material.dart';

class InteractiveTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String>? headers;

  const InteractiveTable({
    super.key,
    required this.data,
    this.headers,
  });

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  late List<String> _headers;

  @override
  void initState() {
    super.initState();
    _headers = widget.headers ??
        (widget.data.isNotEmpty ? widget.data.first.keys.toList() : []);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty || _headers.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _headers
            .map(
              (header) => DataColumn(
            label: Text(
              header,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
            .toList(),
        rows: widget.data.map((row) {
          return DataRow(
            cells: _headers.map((header) {
              final value = row[header];
              return DataCell(
                Text(value?.toString() ?? ''),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}