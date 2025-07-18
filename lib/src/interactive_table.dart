import 'package:flutter/material.dart';
import 'package:interactive_tables/src/table_style.dart';
import 'dart:math';

class InteractiveTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String>? headers;
  final TableStyle tableStyle;
  final bool sortable;
  final bool searchable;
  final TextEditingController? searchController;
  final bool pagination;
  final int rowsPerPage;

  const InteractiveTable({
    super.key,
    required this.data,
    this.headers,
    this.tableStyle = const TableStyle(),
    this.sortable = false,
    this.searchable = false,
    this.searchController,
    this.pagination = false,
    this.rowsPerPage = 10,
  });

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  late List<String> _headers;
  late List<Map<String, dynamic>> _sourceData;
  late List<Map<String, dynamic>> _filteredData;
  late List<Map<String, dynamic>> _paginatedData;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late TextEditingController _searchController;
  bool _isExternalController = false;
  int _currentPage = 0;

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
    _headers = widget.headers ??
        (widget.data.isNotEmpty ? widget.data.first.keys.toList() : []);
    _sortColumnIndex = null;
    _sortAscending = true;
    _currentPage = 0;
    _updateDataView();
  }

  void _onSearchChanged() {
    _currentPage = 0; // Reset to first page on search
    _updateDataView();
  }

  void _sort(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumnIndex = columnIndex;
      _sortAscending = true;
    }
    _updateDataView();
  }

  void _changePage(int newPage) {
    _currentPage = newPage;
    _updateDataView();
  }

  void _updateDataView() {
    // 1. Filter
    final query = _searchController.text.toLowerCase();
    _filteredData = _sourceData.where((row) {
      return row.values.any((value) {
        return value.toString().toLowerCase().contains(query);
      });
    }).toList();

    // 2. Sort
    if (_sortColumnIndex != null) {
      final header = _headers[_sortColumnIndex!];
      final getField = (Map<String, dynamic> d) => d[header];
      _filteredData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    }

    // 3. Paginate
    if (widget.pagination) {
      final startIndex = _currentPage * widget.rowsPerPage;
      final endIndex = min(startIndex + widget.rowsPerPage, _filteredData.length);
      _paginatedData = _filteredData.sublist(startIndex, endIndex);
    } else {
      _paginatedData = List.from(_filteredData);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int totalRows = _filteredData.length;
    final int totalPages = (totalRows / widget.rowsPerPage).ceil();

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
          child: widget.data.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No data to display'),
            ),
          )
              : _filteredData.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No matching records found'),
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingTextStyle: widget.tableStyle.headerTextStyle,
              dataTextStyle: widget.tableStyle.rowTextStyle,
              headingRowColor: WidgetStateProperty.all(
                  widget.tableStyle.headerColor),
              columns: _headers.asMap().entries.map((entry) {
                final index = entry.key;
                final header = entry.value;
                return DataColumn(
                  label: Padding(
                    padding: widget.tableStyle.cellPadding,
                    child: Text(header),
                  ),
                  onSort: widget.sortable
                      ? (columnIndex, ascending) => _sort(index)
                      : null,
                );
              }).toList(),
              rows: _paginatedData.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final Color? rowColor = index.isEven
                    ? widget.tableStyle.evenRowColor
                    : widget.tableStyle.oddRowColor;

                return DataRow(
                  color: WidgetStateProperty.all(rowColor),
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
        if (widget.pagination && totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0
                      ? () => _changePage(_currentPage - 1)
                      : null,
                ),
                Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages - 1
                      ? () => _changePage(_currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}