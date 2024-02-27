/*
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class PivotTable extends StatefulWidget {
  const PivotTable({
    super.key,
    this.backgroundColor = Colors.white,
    required this.headers,
    required this.data,
    this.columnWidth = 100.0,
    this.onRowSummarization,
  });

  /// the background color
  final Color backgroundColor;

  final List<String> headers;

  final List<Map<String, List<int>>> data;

  final double columnWidth;

  final String Function(dynamic)? onRowSummarization;

  @override
  State<PivotTable> createState() => _PivotTableState();
}

class _PivotTableState extends State<PivotTable> {
  Map<int, bool> isRowExpanded = {};

  List<TableRow> _buildRows() {
    List<TableRow> _rows = [];

    // Initialize the isRowExpanded map
    for(int i = 0; i < widget.data.length; i++){
      if(!isRowExpanded.keys.contains(i)){
        isRowExpanded[i] = false;
      }
    }

    for (Map<String, List<int>> data in widget.data) {
      List<TableRow> tableRows = [];
      for (String key in data.keys) {
        tableRows.addAll(convertToTableRows(data[key]!, isRowExpanded));
      }
      _rows.addAll(tableRows);
    }

    return _rows;
  }

  List<TableRow> convertToTableRows(List<int> data, Map<int, bool> isRowExpanded, String key) {
    List<TableRow> tableRows = [];
    int sum = 0;
    bool isTotalRow = false;

    for (int i = 0; i < data.length; i++) {
      if (isRowExpanded.containsKey(i)) {
        isTotalRow = isRowExpanded[i]!;
        if (isTotalRow) {
          tableRows.add(_createTotalRow(sum, key));
          sum = 0;
        }
      }

      String name = "";
      int? value;
      if (i < data.length) {
        name = data[i].toString(); // Assuming data[i] is a name represented as an integer
        value = data[i];
      }

      if (!isTotalRow) {
        sum += value!;
        tableRows.add(_createIndividualRow(name, value));
      }
    }

    if (!isTotalRow && sum > 0) {
      tableRows.add(_createTotalRow(sum, key));
    }

    return tableRows;
  }

  TableRow _createTotalRow(int total, String key) {
    return TableRow(
      children: [
        const TableCell(
          child: Text(
            "Total",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(
          child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        TableCell(
          child: Text(total.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _createIndividualRow(String name, int? value) {
    return TableRow(
      children: [
        TableCell(
          child: Text(name),
        ),
        TableCell(
          child: Text(value != null ? value.toString() : ""),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    TextStyle _headingRowStyle =
        _theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
    ScrollController _scrollController = ScrollController();

    return LayoutBuilder(builder: (context, constraints) {
          return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 25),
              children: [
                SingleChildScrollView(
                  key: const PageStorageKey('pivotTable'),
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  controller: _scrollController,
                  //physics: const BouncingScrollPhysics(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Table(
                          columnWidths: {
                            0: const FixedColumnWidth(40),
                            ...widget.headers.asMap().map((i, e) =>
                                MapEntry(i + 1, FixedColumnWidth(widget.columnWidth))),
                          },
                          children: [
                            //Header
                            TableRow(
                              children: [
                                const TableCell(
                                    child: SizedBox(width: 5.0)),
                                ...widget.headers
                                    .map((e) => TableCell(
                                  child: Text(
                                    e,
                                    style: _headingRowStyle,
                                  ),
                                )),
                              ],
                            ),
                            // Body
                            ..._buildRows(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
        });

  }
}
*/
