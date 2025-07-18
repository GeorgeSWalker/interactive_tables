import 'package:flutter/material.dart';
import 'package:interactive_tables/src/table_style.dart';

class InteractiveTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String>? headers;
  final TableStyle tableStyle;
  final bool sortable;

  const InteractiveTable({
    super.key,
    required this.data,
    this.headers,
    this.tableStyle = const TableStyle(),
    this.sortable = false,
  });

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  late List<String> _headers;
  late List<Map<String, dynamic>> _data;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(covariant InteractiveTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data passed to the widget changes, we need to re-initialize.
    if (widget.data != oldWidget.data) {
      _initializeState();
    }
  }

  // Helper to initialize or re-initialize state
  void _initializeState() {
    _data = List<Map<String, dynamic>>.from(widget.data);
    _headers = widget.headers ??
        (widget.data.isNotEmpty ? widget.data.first.keys.toList() : []);
    // Reset sorting
    _sortColumnIndex = null;
    _sortAscending = true;
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    // The sorting logic is now cleanly inside setState
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _data.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty || _headers.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        headingTextStyle: widget.tableStyle.headerTextStyle,
        dataTextStyle: widget.tableStyle.rowTextStyle,
        headingRowColor:
        MaterialStateProperty.all(widget.tableStyle.headerColor),
        columns: _headers.asMap().entries.map((entry) {
          final header = entry.value;
          return DataColumn(
            label: Padding(
              padding: widget.tableStyle.cellPadding,
              child: Text(header),
            ),
            onSort: widget.sortable
                ? (columnIndex, ascending) {
              _sort<dynamic>(
                      (d) => d[header], columnIndex, ascending);
            }
                : null,
          );
        }).toList(),
        rows: _data.asMap().entries.map((entry) {
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