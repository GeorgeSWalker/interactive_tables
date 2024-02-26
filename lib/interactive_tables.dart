library interactive_tables;

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

typedef onRowDeleteCallback2 = void Function(List<int> rowsIndexes);

typedef onTextEditCallback = void Function(
    int row, int column, String newValue);

typedef onRowAddCallback = void Function();

typedef onTextEditCompleteCallback = void Function(
    int row, int column, String newValue);

typedef formFieldName = String Function(int row, int column);

class InteractiveTable extends StatefulWidget {
  const InteractiveTable({
    super.key,
    required this.cols,
    required this.colWidths,
    required this.data,
    this.tableBoarderColor = Colors.grey,
    this.tableBoarderWidth = 1.0,
    this.defaultVerticalAlignment = TableCellVerticalAlignment.middle,
    this.headerRowBackgroundColor = Colors.white,
    this.headerRowTextColor = Colors.black,
    this.bottomRowBackgroundColor = Colors.white,
    required this.bottomRowText,
    this.onTextEdit,
    this.onTextEditComplete,
    this.onRowDeleteCallback,
    this.onRowAdd,
    this.editableCells = false,
    this.firstCellEditable = false,
    this.formFieldName,
    this.textDirection = TextDirection.ltr,
    this.tableBorder = const TableBorder(
      horizontalInside: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      verticalInside: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      top: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      bottom: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      left: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      right: BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
    ),
    this.allowSorting = false,
    this.allowFiltering = false,
  });

  /// This list contains the column headers
  /// The column headers are strings
  /// The column headers are displayed in the first row of the table
  /// The column headers are not editable
  /// The column headers are not selectable
  /// The column headers are not deletable
  /// The column headers are not draggable
  /// The column headers are not droppable
  final List<String> cols;

  /// This map contains the column indices and the column widths
  /// The column indices are integers
  /// The column widths are TableColumnWidths
  /// The column widths are used to set the width of the columns
  ///
  /// Example:
  /// colWidths: <int, TableColumnWidth>{
  ///  0: IntrinsicColumnWidth(),
  ///  1: FlexColumnWidth(),
  ///  2: FlexColumnWidth(),
  ///  },
  ///
  /// This example sets the width of the first column to the width of the
  /// contents of the column. The width of the second and third columns
  /// are set to the width of the remaining space divided by the number
  final Map<String, TableColumnWidth> colWidths;

  /// This list contains the rows of the table that are displayed to the user
  /// The rows are lists of strings that are populated from the dataList on initState
  /// The rows are editable
  /// The rows are selectable
  /// The rows are deletable
  ///
  /// Example:
  /// dataList: [
  /// ['row1', 'row1', 'row1'],
  /// ['row2', 'row2', 'row2'],
  /// ['row3', 'row3', 'row3'],
  /// ],
  ///
  /// This example creates a table with three rows. Each row has three columns.
  /// The first column of each row is a checkbox. The remaining columns are editable.
  /// The first row is the header row. The remaining rows are data rows.
  /// The first column of the header row is empty. The remaining columns of the header row
  /// are the column headers. The first column of the data rows are checkboxes.
  final List<Map<String, dynamic>> data;

  /// This color is used to set the color of the table boarder lines
  ///
  /// Example:
  /// tableBoarderColor: Colors.grey,
  final Color tableBoarderColor;

  /// This double is used to set the width of the table boarder lines
  ///
  /// Example:
  /// tableBoarderWidth: 1.0,
  final double tableBoarderWidth;

  /// This TableCellVerticalAlignment is used to set the vertical alignment of the cells
  ///
  /// Example:
  /// defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  final TableCellVerticalAlignment defaultVerticalAlignment;

  /// This color is used to set the background color of the header row
  ///
  /// Example:
  /// headerRowBackgroundColor: Colors.white,
  final Color headerRowBackgroundColor;

  /// This color is used to set the text color of the header row
  ///
  /// Example:
  /// headerRowTextColor: Colors.black,
  final Color headerRowTextColor;

  /// This color is used to set the background color of the bottom row
  ///
  /// Example:
  /// bottomRowBackgroundColor: Colors.white,
  final Color bottomRowBackgroundColor;

  /// This string is used to set the text of the bottom row
  ///
  /// Example:
  /// bottomRowText: 'Total',
  final String bottomRowText;

  /// This function is used to set the callback for when the user edits a cell
  /// The function takes three parameters:
  /// row: the row index of the cell that was edited
  /// column: the column index of the cell that was edited
  /// newValue: the new value of the cell that was edited
  ///
  /// Example:
  /// onTextEdit: (int row, int column, String newValue) {
  ///   print('row: $row, column: $column, newValue: $newValue');
  /// },
  final onTextEditCallback? onTextEdit;

  /// This function is used to set the callback for when the user completes editing a cell
  /// The function takes three parameters:
  /// row: the row index of the cell that was edited
  /// column: the column index of the cell that was edited
  /// newValue: the new value of the cell that was edited
  ///
  /// Example:
  /// onTextEditComplete: (int row, int column, String newValue) {
  ///  print('row: $row, column: $column, newValue: $newValue');
  ///  },
  final onTextEditCompleteCallback? onTextEditComplete;

  /// This function is used to set the callback for when the user deletes a row
  /// The function takes one parameter:
  /// rowsIndexes: a list of integers that are the indexes of the rows that were deleted
  ///
  /// Example:
  /// onRowDeleteCallback: (List<int> rowsIndexes) {
  /// print('rows deleted: $rowsIndexes');
  /// },
  final onRowDeleteCallback2? onRowDeleteCallback;

  /// This function is used to set the callback for when the user adds a row
  /// The function takes no parameters
  ///
  /// Example:
  /// onRowAdd: () {
  ///  print('row added');
  ///  },
  final onRowAddCallback? onRowAdd;

  final bool editableCells;

  /// This bool is used to set if the first cell is editable or not
  /// TODO: find a better way for this
  final bool firstCellEditable;

  final TextDirection textDirection;

  final TableBorder tableBorder;

  final bool allowSorting;

  final bool allowFiltering;

  final String Function(int row, int column)? formFieldName;

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  /// This list contains the rows of the table that are displayed
  /// The rows are lists of strings that are populated from the dataList
  /// on initState.
  List<Map<String, dynamic>> _dataList = [];

  List<Map<String, dynamic>> _filteredDataList = [];

  /// This list contains the rows that are selected by the user
  /// The rows are lists of strings
  static final List<Map<String, dynamic>> _selectedDataList = [];

  /// This function is used to check if a row is in the selected list
  /// It takes a list of strings (a row) as a parameter
  /// It returns true if the row is in the selected list
  /// It returns false if the row is not in the selected list
  bool isInSelectedList(Map<String, dynamic> data) => _selectedDataList.contains(data);

  int sortedColumnIndex = -1;
  bool sortAscending = true;

  late int count;

  @override
  void initState() {
    _dataList.addAll(widget.data);
    _filteredDataList.addAll(widget.data);
    count = widget.data.length;
    super.initState();
  }

  /*@override
  void didUpdateWidget(covariant InteractiveTable oldWidget) {
    if (oldWidget.data != widget.data) {
      _dataList.clear();
      _dataList.addAll(widget.data);
      count = widget.data.length;
    }
    super.didUpdateWidget(oldWidget);
  }*/

  @override
  void dispose() {
    _dataList.clear();
    _selectedDataList.clear();
    count = 0;
    super.dispose();
  }

  /// This function is used to create the bottom row of
  /// the table to match the length of the columns
  /// and to add the add button
  /// The add button calls the _onRowAdd function
  /// The add button is in the first column
  ///
  /// returns: a TableRow widget
  TableRow _getBottomRows(ThemeData theme) {
    int numberOfCols = widget.cols.length;

    List<TableCell> cells = [
      TableCell(
        child: IconButton(
          icon: const Icon(Icons.add),
          tooltip: widget.bottomRowText,
          isSelected: false,
          onPressed: () {
            setState(() {
              if (widget.onRowAdd != null) {
                widget.onRowAdd!();
                _dataList = widget.data.toList();
                _filteredDataList = widget.data.toList();
              }
            });
          },
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.bottomRowText,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: widget.headerRowTextColor,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ];

    for (int i = 1; i < numberOfCols; i++) {
      cells.add(TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(),
        ),
      ));
    }
    return TableRow(
      decoration: BoxDecoration(
        color: widget.bottomRowBackgroundColor,
      ),
      children: cells,
    );
  }

  List<String> getUniqueItemsInColumn(int columnIndex) {
    List<String> uniqueItems = [];
    for (Map<String, dynamic> row in _dataList) {
      if (!uniqueItems.contains(row[widget.cols[columnIndex]].toString())) {
        uniqueItems.add(row[widget.cols[columnIndex]].toString());
      }
    }
    return uniqueItems;
  }

  List<CheckboxListTile> filterList(int columnIndex, BuildContext context){
    List<CheckboxListTile> list = [
      CheckboxListTile(
        key: const ValueKey('Select All'),
        title: const Text('Select All'),
          value: _filteredDataList.length == _dataList.length,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _filteredDataList.clear();
                _filteredDataList.addAll(_dataList);
              } else {
                _filteredDataList.clear();
              }
            });
            Navigator.pop(context);
          },
      ),
    ];

    List<String> uniqueItems = getUniqueItemsInColumn(columnIndex);
    for(String item in uniqueItems){
      list.add(CheckboxListTile(
        key: ValueKey(item),
        title: Text(item),
        value: _filteredDataList.any((element) => element[widget.cols[columnIndex]].toString() == item),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _filteredDataList.addAll(_dataList.where((element) => element[widget.cols[columnIndex]].toString() == item).toList());
            } else {
              _filteredDataList.removeWhere((element) => element[widget.cols[columnIndex]].toString() == item);
            }
          });
          Navigator.pop(context);
        },
      ));
    }

    return list;
  }

  /// This function is used to create the header row of the table
  /// The header row is the first row of the table
  /// The header row is a list of strings
  /// The header row is populated from the cols list
  TableRow headerRow(ThemeData theme) => TableRow(
    decoration: BoxDecoration(
      color: widget.headerRowBackgroundColor,
    ),
    children: [
      TableCell(
        child: Checkbox(
          value: _selectedDataList.length == _dataList.length,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedDataList.addAll(_dataList);
              } else {
                _selectedDataList.clear();
              }
            });
          },
        )
      ),
      ...widget.cols.map((e) {
        return TableCell(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (widget.allowSorting) {
                    sortAscending = sortedColumnIndex == widget.cols.indexOf(e) ? !sortAscending : true;
                    sortedColumnIndex = widget.cols.indexOf(e);
                    List<Map<String, dynamic>> sortedList = List<Map<String, dynamic>>.from(_filteredDataList);
                    sortedList.sort((a, b) {
                      if (a[e] is String) {
                        return sortAscending
                            ? a[e].compareTo(b[e])
                            : b[e].compareTo(a[e]);
                      } else {
                        return sortAscending
                            ? a[e].compareTo(b[e])
                            : b[e].compareTo(a[e]);
                      }
                    });
                    setState(() {
                      _filteredDataList = sortedList.toList();
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: widget.headerRowTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (widget.allowSorting)
                      ? Icon(
                          sortedColumnIndex == widget.cols.indexOf(e)
                              ? sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward
                              : null,
                        )
                          : Container(),
                    ],
                  ),
                ),
              ),
              (widget.allowFiltering)
              ? PopupMenuButton(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: 'Filter Column',
                  constraints: const BoxConstraints(
                    minHeight: 500,
                    minWidth: 500,
                    maxWidth: 500,
                    maxHeight: 500,
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: SizedBox(
                          height: 450,
                          width: 450,
                          child: Card(
                            child: ListView(
                              children: filterList(widget.cols.indexOf(e), context)
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                )
              : Container(),
            ],
          ),
        );
      }),
    ],
  );

  /// This function is used to create the data rows of the table
  /// The data rows are the remaining rows of the table
  /// The data rows are lists of strings
  /// The data rows are populated from the dataList
  List<TableRow> dataRows(ThemeData theme, List<Map<String, dynamic>> dataList) {
    List<TableRow> rows = [];
    int index = 0;

    for(Map<String, dynamic> rowEntry in dataList){
      List<TableCell> cells = [
        TableCell(
          child: Checkbox(
            value: isInSelectedList(rowEntry),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedDataList.add(rowEntry);
                } else {
                  _selectedDataList.remove(rowEntry);
                }
              });
            }
          ),
        ),
      ];
      for(String col in widget.cols){
        cells.add(TableCell(
          child: (widget.editableCells == false)
            ? Text(
              key: ValueKey(rowEntry[col]),
              rowEntry[col].toString(),
          )
          : (widget.firstCellEditable == false && widget.cols.indexOf(col) == 0)
            ? Text(
              key: ValueKey(rowEntry[col]),
              rowEntry[col].toString(),
          )
          : FormBuilderTextField(
              key: ValueKey(rowEntry[col]),
              name: getFormFieldName(index, widget.cols.indexOf(col)),
              initialValue: rowEntry[col].toString(),
            ),
        ));
      }
      rows.add(TableRow(
        key: ObjectKey(rowEntry),
        children: cells,
      ));
      index++;
    }
    return rows;
  }

  /// This function is used to get the column widths
  Map<int, TableColumnWidth> getColumnWidths() {
    Map<int, TableColumnWidth> columnWidths = {
      0: const FixedColumnWidth(50),
    };
    for (int i = 0; i < widget.cols.length; i++) {
      columnWidths[i + 1] = widget.colWidths[widget.cols[i]]!;
    }
    return columnWidths;
  }

  String getFormFieldName(int row, int column) {
    if (widget.formFieldName != null) {
      return widget.formFieldName!(row, column);
    }
    return 'row$row${widget.cols[column]}';
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Column(
        children: [
          Row(
            children: [
              (_selectedDataList.isNotEmpty)
                  ? IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () {
                  setState(() {
                   /* if (widget.onRowDeleteCallback != null) {
                      widget.onRowDeleteCallback!(_selectedDataList
                          .map((e) => _dataList.indexOf(e))
                          .toList());
                    }
                    _dataList
                        .removeWhere((element) => isInSelectedList(element));
                    _selectedDataList.clear();*/
                  });
                },
              )
                  : Container(),
            ],
          ),
          Table(
            border: widget.tableBorder,
            textDirection: widget.textDirection,
            columnWidths: getColumnWidths(),
            defaultVerticalAlignment: widget.defaultVerticalAlignment,
            children: [
              headerRow(_theme),
              ...dataRows(_theme, _filteredDataList),
              _getBottomRows(_theme),
            ],
          ),
        ],
    );
  }
}

