import 'package:flutter/material.dart';
import 'package:interactive_tables/src/table_style.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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
  final bool stickyHeaders;
  final Map<String, double>? columnWidths;

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
    this.stickyHeaders = false,
    this.columnWidths,
  }) : assert(!stickyHeaders || columnWidths != null,
  'columnWidths must be provided when stickyHeaders is true.');

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

  // For linked horizontal scrolling
  late LinkedScrollControllerGroup _scrollControllerGroup;
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;


  @override
  void initState() {
    super.initState();
    _isExternalController = widget.searchController != null;
    _searchController = widget.searchController ?? TextEditingController();

    _scrollControllerGroup = LinkedScrollControllerGroup();
    _headerScrollController = _scrollControllerGroup.addAndGet();
    _bodyScrollController = _scrollControllerGroup.addAndGet();

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
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
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
    _currentPage = 0;
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
    final query = _searchController.text.toLowerCase();
    _filteredData = _sourceData.where((row) {
      return row.values.any((value) {
        return value.toString().toLowerCase().contains(query);
      });
    }).toList();

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

    if (widget.pagination) {
      final startIndex = _currentPage * widget.rowsPerPage;
      final endIndex = min(startIndex + widget.rowsPerPage, _filteredData.length);
      _paginatedData = _filteredData.sublist(startIndex, endIndex);
    } else {
      _paginatedData = List.from(_filteredData);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickyHeaders) {
      return _buildStickyHeaderTable();
    }
    return _buildRegularTable();
  }

  Widget _buildStickyHeaderTable() {
    final int totalRows = _filteredData.length;
    final int totalPages = (totalRows / widget.rowsPerPage).ceil();
    final columnWidths = _headers
        .asMap()
        .map((key, value) => MapEntry(key, FixedColumnWidth(widget.columnWidths![value]!)));

    return Column(
      children: [
        if (widget.searchable && !_isExternalController)
          _buildSearchBar(),
        // Sticky Header
        SingleChildScrollView(
          controller: _headerScrollController,
          scrollDirection: Axis.horizontal,
          child: Table(
            columnWidths: columnWidths,
            children: [
              _buildHeaderRow(),
            ],
          ),
        ),
        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              controller: _bodyScrollController,
              scrollDirection: Axis.horizontal,
              child: Table(
                columnWidths: columnWidths,
                children: _buildDataRows(),
              ),
            ),
          ),
        ),
        if (widget.pagination && totalPages > 1)
          _buildPaginationControls(totalPages),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: widget.tableStyle.headerColor),
      children: _headers.asMap().entries.map((entry) {
        final index = entry.key;
        final header = entry.value;
        return InkWell(
          onTap: widget.sortable ? () => _sort(index) : null,
          child: Padding(
            padding: widget.tableStyle.cellPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(header, style: widget.tableStyle.headerTextStyle),
                if (widget.sortable && _sortColumnIndex == index)
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: widget.tableStyle.headerTextStyle.fontSize,
                    color: widget.tableStyle.headerTextStyle.color,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TableRow> _buildDataRows() {
    return _paginatedData.asMap().entries.map((entry) {
      final index = entry.key;
      final rowData = entry.value;
      final Color? rowColor = index.isEven
          ? widget.tableStyle.evenRowColor
          : widget.tableStyle.oddRowColor;
      return TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: _headers.map((header) {
          return Padding(
            padding: widget.tableStyle.cellPadding,
            child: Text(
              rowData[header]?.toString() ?? '',
              style: widget.tableStyle.rowTextStyle,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildRegularTable() {
    final int totalRows = _filteredData.length;
    final int totalPages = (totalRows / widget.rowsPerPage).ceil();

    return Column(
      children: [
        if (widget.searchable && !_isExternalController)
          _buildSearchBar(),
        Expanded(
          child: widget.data.isEmpty
              ? _buildEmptyState('No data to display')
              : _filteredData.isEmpty
              ? _buildEmptyState('No matching records found')
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingTextStyle: widget.tableStyle.headerTextStyle,
              dataTextStyle: widget.tableStyle.rowTextStyle,
              headingRowColor: WidgetStateProperty.all(widget.tableStyle.headerColor),
              columns: _headers.asMap().entries.map((entry) {
                final index = entry.key;
                final header = entry.value;
                return DataColumn(
                  label: Text(header),
                  onSort: widget.sortable ? (columnIndex, ascending) => _sort(index) : null,
                );
              }).toList(),
              rows: _paginatedData.map((row) {
                return DataRow(
                  cells: _headers.map((header) {
                    return DataCell(Text(row[header]?.toString() ?? ''));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
        if (widget.pagination && totalPages > 1)
          _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
          ),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message),
      ),
    );
  }
}