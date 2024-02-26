// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class PivotTable extends StatefulWidget {
  const PivotTable({
    super.key,
    this.backgroundColor = Colors.white,
    required this.headers,
    required this.data,
    this.columnWidth = 100.0,
  });

  /// the background color
  final Color backgroundColor;

  final List<String> headers;

  final List<Map<String, dynamic>> data;

  final double columnWidth;

  @override
  State<PivotTable> createState() => _PivotTableState();
}

class _PivotTableState extends State<PivotTable> {
  bool isExpanded = false;
  bool baselineExpanded = false;
  bool ambitionExpanded = false;
  bool counterFactualExpanded = false;
  bool factualExpanded = false;
  bool actualExpanded = false;

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
