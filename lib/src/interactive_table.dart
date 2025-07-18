import 'package:flutter/material.dart';
import 'package:interactive_tables/src/table_style.dart';

class InteractiveTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String>? headers;
  final TableStyle tableStyle;

  const InteractiveTable({
    super.key,
    required this.data,
    this.headers,
    this.tableStyle = const TableStyle(),
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
        headingTextStyle: widget.tableStyle.headerTextStyle,
        dataTextStyle: widget.tableStyle.rowTextStyle,
        headingRowColor: MaterialStateProperty.all(widget.tableStyle.headerColor),
        // The main change is in the rows section below
        columns: _headers
            .map(
              (header) => DataColumn(
            label: Padding(
              padding: widget.tableStyle.cellPadding,
              child: Text(header),
            ),
          ),
        )
            .toList(),
        rows: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          final Color? rowColor = index.isEven
              ? widget.tableStyle.evenRowColor
              : widget.tableStyle.oddRowColor;

          return DataRow(
            color: MaterialStateProperty.all(rowColor),
            cells: _headers.map((header) {
              final value = row[header];
              return DataCell(
                Padding(
                  padding: widget.tableStyle.cellPadding,
                  child: Text(value?.toString() ?? ''),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}