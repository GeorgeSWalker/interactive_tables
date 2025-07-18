import 'package:flutter/material.dart';

/// Defines the visual appearance of the [InteractiveTable].
///
/// An instance of this class can be passed to the `tableStyle` property
/// of an [InteractiveTable] to customize its look and feel.
class TableStyle {
  /// The text style for the header cells.
  final TextStyle headerTextStyle;

  /// The text style for the data rows.
  /// This style acts as the base style for all cells.
  /// It can be overridden by conditional formatting.
  final TextStyle rowTextStyle;

  /// The padding for each cell in the table.
  final EdgeInsets cellPadding;

  /// The background color for the header row.
  final Color? headerColor;

  /// The background color for even-numbered data rows.
  ///
  /// This is used for creating a "zebra-striped" effect.
  final Color? evenRowColor;

  /// The background color for odd-numbered data rows.
  ///
  /// This is used for creating a "zebra-striped" effect.
  final Color? oddRowColor;

  /// Creates a new [TableStyle].
  ///
  /// All properties have default values, so you only need to specify
  /// the ones you want to change.
  const TableStyle({
    this.headerTextStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.rowTextStyle = const TextStyle(),
    this.cellPadding = const EdgeInsets.all(16.0),
    this.headerColor,
    this.evenRowColor,
    this.oddRowColor,
  });
}
