import 'package:flutter/material.dart';

class TableStyle {
  /// The text style for the header cells.
  final TextStyle headerTextStyle;

  /// The text style for the data rows.
  final TextStyle rowTextStyle;

  /// The padding for each cell.
  final EdgeInsets cellPadding;

  /// The background color for the header row.
  final Color? headerColor;

  /// The background color for even-numbered rows.
  final Color? evenRowColor;

  /// The background color for odd-numbered rows.
  final Color? oddRowColor;

  const TableStyle({
    this.headerTextStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.rowTextStyle = const TextStyle(),
    this.cellPadding = const EdgeInsets.all(16.0),
    this.headerColor,
    this.evenRowColor,
    this.oddRowColor,
  });
}