import 'package:flutter/material.dart';
import 'package:interactive_tables/src/table_style.dart';

class InteractiveTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String>? headers;
  final TableStyle tableStyle;
  final bool sortable;
  final bool searchable;
  final TextEditingController? searchController;

  const InteractiveTable({
    super.key,
    required this.data,
    this.headers,
    this.tableStyle = const TableStyle(),
    this.sortable = false,
    this.searchable = false,
    this.searchController,
  });

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  late List<String> _headers;
  late List<Map<String, dynamic>> _sourceData;
  late List<Map<String, dynamic>> _filteredData;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late TextEditingController _searchController;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.searchController != null;
    _searchController = widget.searchController ?? TextEditingController();
    _initializeState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant InteractiveTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _initializeState();
    }
    if (widget.searchController != oldWidget.searchController) {
      _searchController.removeListener(_onSearchChanged);
      _isExternalController = widget.searchController != null;
      _searchController = widget.searchController ?? TextEditingController();
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    if (!_isExternalController) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _initializeState() {
    _sourceData = List<Map<String, dynamic>>.from(widget.data);
    _filteredData = List<Map<String, dynamic>>.from(widget.data);
    _headers = widget.headers ??
        (widget.data.isNotEmpty ? widget.data.first.keys.toList() : []);
    _sortColumnIndex = null;
    _sortAscending = true;
    _onSearchChanged();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _sourceData.where((row) {
        return row.values.any((value) {
          return value.toString().toLowerCase().contains(query);
        });
      }).toList();
      if (_sortColumnIndex != null) {
        final header = _headers[_sortColumnIndex!];
        _sort((d) => d[header], _sortColumnIndex!, _sortAscending,
            reapply: true);
      }
    });
  }

  void _sort<T>(
      Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex,
      bool ascending,
      {bool reapply = false}) {
    if (!reapply) {
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });
    }
    _filteredData.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    if (reapply) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searchable && !_isExternalController)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        Expanded(
          child:
          // First, check if the original source data was empty.
          widget.data.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No data to display'),
            ),
          )
          // If not, then check if the filtered results are empty.
              : _filteredData.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No matching records found'),
            ),
          )
          // Otherwise, display the table.
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingTextStyle: widget.tableStyle.headerTextStyle,
              dataTextStyle: widget.tableStyle.rowTextStyle,
              headingRowColor: MaterialStateProperty.all(
                  widget.tableStyle.headerColor),
              columns: _headers.asMap().entries.map((entry) {
                final header = entry.value;
                return DataColumn(
                  label: Padding(
                    padding: widget.tableStyle.cellPadding,
                    child: Text(header),
                  ),
                  onSort: widget.sortable
                      ? (columnIndex, ascending) {
                    _sort<dynamic>((d) => d[header],
                        columnIndex, ascending);
                  }
                      : null,
                );
              }).toList(),
              rows: _filteredData.asMap().entries.map((entry) {
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
          ),
        ),
      ],
    );
  }
}