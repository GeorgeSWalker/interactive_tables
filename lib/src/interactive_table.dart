import 'package:flutter/material.dart';
import 'table_style.dart'; // Corrected import
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'dart:math';

/// A typedef for a function that returns a [TextStyle] based on a cell's content.
///
/// This is used for conditional formatting.
/// The function receives the column `header` and the cell `value`.
/// It should return a [TextStyle] to apply, or `null` to use the default style.
typedef ConditionalTextStyleBuilder = TextStyle? Function(String header, dynamic value);

/// A powerful and flexible data table widget for Flutter.
///
/// It supports sorting, searching, pagination, sticky headers, row selection,
/// and conditional styling right out of the box.
class InteractiveTable extends StatefulWidget {
  /// The data to display in the table.
  ///
  /// This is a list of maps, where each map represents a row.
  /// The keys of the map correspond to the column headers.
  final List<Map<String, dynamic>> data;

  /// An optional list of strings to use as column headers.
  ///
  /// If this is `null`, the headers will be generated from the keys
  /// of the first map in the `data` list.
  final List<String>? headers;

  /// The visual styling for the table.
  ///
  /// See [TableStyle] for more details on customization options.
  final TableStyle tableStyle;

  /// Enables or disables sorting for all columns.
  ///
  /// When `true`, users can tap on column headers to sort the data.
  final bool sortable;

  /// Enables or disables the built-in search functionality.
  ///
  /// When `true` and no `searchController` is provided, a search bar
  /// will be displayed above the table.
  final bool searchable;

  /// An optional `TextEditingController` to control the search from outside the widget.
  ///
  /// If you provide your own controller, the built-in search bar will not be shown.
  /// This allows you to create custom search UI.
  final TextEditingController? searchController;

  /// Enables or disables pagination.
  ///
  /// When `true`, the data will be split into pages.
  final bool pagination;

  /// The number of rows to display per page when pagination is enabled.
  final int rowsPerPage;

  /// Enables or disables sticky headers.
  ///
  /// When `true`, the column headers will remain visible at the top
  /// as the user scrolls vertically.
  ///
  /// **NOTE:** When `stickyHeaders` is `true`, you **must** also provide `columnWidths`.
  final bool stickyHeaders;

  /// A map defining the width for each column.
  ///
  /// The keys should match the column headers. This is **required** when `stickyHeaders` is `true`
  /// to ensure proper alignment.
  final Map<String, double>? columnWidths;

  /// Enables or disables row selection.
  ///
  /// When `true`, a checkbox will appear on each row, and the `onSelectionChanged`
  /// callback will be triggered when the selection changes.
  final bool selectable;

  /// A callback that is triggered when the set of selected rows changes.
  ///
  /// It receives a list of the currently selected rows.
  final ValueChanged<List<Map<String, dynamic>>>? onSelectionChanged;

  /// A function to build a custom [TextStyle] for a cell based on its content.
  ///
  /// This allows for powerful conditional formatting, like changing the color
  /// of a cell based on its value.
  final ConditionalTextStyleBuilder? conditionalTextStyleBuilder;

  /// Creates a new [InteractiveTable] widget.
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
    this.selectable = false,
    this.onSelectionChanged,
    this.conditionalTextStyleBuilder,
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

  late LinkedScrollControllerGroup _scrollControllerGroup;
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;

  final Set<Map<String, dynamic>> _selectedRows = {};


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
    if (widget.conditionalTextStyleBuilder != oldWidget.conditionalTextStyleBuilder) {
      setState(() {});
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
    _headers = widget.headers != null
        ? List<String>.from(widget.headers!)
        : (widget.data.isNotEmpty ? widget.data.first.keys.toList() : []);

    if (widget.selectable && widget.stickyHeaders && !_headers.contains('Select')) {
      _headers.insert(0, 'Select');
    }

    _sortColumnIndex = null;
    _sortAscending = true;
    _currentPage = 0;
    _selectedRows.clear();
    _updateDataView();
  }

  void _onSearchChanged() {
    _currentPage = 0;
    _updateDataView();
  }

  void _sort(int columnIndex) {
    if (widget.stickyHeaders && widget.selectable && columnIndex == 0) return;

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

  void _toggleRowSelection(Map<String, dynamic> rowData, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedRows.add(rowData);
      } else {
        _selectedRows.remove(rowData);
      }
    });
    widget.onSelectionChanged?.call(_selectedRows.toList());
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

  Widget _buildCellText(String header, dynamic value) {
    final conditionalStyle = widget.conditionalTextStyleBuilder?.call(header, value);
    final finalStyle = conditionalStyle ?? widget.tableStyle.rowTextStyle;

    return Text(
      value?.toString() ?? '',
      style: finalStyle,
    );
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

    final customWidths = Map<String, double>.from(widget.columnWidths ?? {});
    if (widget.selectable) {
      customWidths.putIfAbsent('Select', () => 60.0);
    }

    final columnWidths = _headers
        .asMap()
        .map((key, value) => MapEntry(key, FixedColumnWidth(customWidths[value]!)));

    return Column(
      children: [
        if (widget.searchable && !_isExternalController)
          _buildSearchBar(),
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

        if (header == 'Select') {
          return const Padding(
            padding: EdgeInsets.zero,
            child: SizedBox.shrink(),
          );
        }

        return InkWell(
          onTap: widget.sortable ? () => _sort(index) : null,
          child: Padding(
            padding: widget.tableStyle.cellPadding,
            child: Row(
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
          if (header == 'Select') {
            return TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Checkbox(
                value: _selectedRows.contains(rowData),
                onChanged: (isSelected) => _toggleRowSelection(rowData, isSelected),
              ),
            );
          }
          return Padding(
            padding: widget.tableStyle.cellPadding,
            child: _buildCellText(header, rowData[header]),
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
                final isSelected = _selectedRows.contains(row);
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: widget.selectable
                      ? (isSelected) => _toggleRowSelection(row, isSelected)
                      : null,
                  cells: _headers.map((header) {
                    return DataCell(_buildCellText(header, row[header]));
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
            'Page ${(_currentPage + 1).toString()} of ${totalPages.toString()}',
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
