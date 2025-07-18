# Power Table

A powerful and flexible Flutter package for creating feature-rich, interactive data tables.

This package provides a simple way to generate tables from your data, with built-in support for sorting, searching, pagination, sticky headers, row selection, and conditional styling. It's designed to be easy to use for simple tables, while also being highly customizable for more complex scenarios.

## Documentation

* [**API Reference**](https://pub.dev/documentation/power_table/latest/) - The complete, auto-generated API reference for all classes and methods. (Note: This link will work after you publish to pub.dev).
* **Feature Guide** - A detailed guide on how to use all the features (coming soon).
* **Styling Guide** - A guide on how to customize the look and feel of your table (coming soon).

## Features

* **Dynamic Table Generation**: Automatically generate columns and rows from a `List` of `Map`s.
* **Customizable Styling**: Control the look and feel of your table.
* **Automatic Sorting**: Enable sorting on any column.
* **Built-in & External Search**: Filter your data in real-time.
* **Pagination**: Break your data into manageable pages.
* **Sticky Headers**: Keep your column headers visible.
* **Row Selection**: Allow users to select rows.
* **Conditional Formatting**: Dynamically style individual cells.

## Getting Started

To get started, add the `power_table` package to your `pubspec.yaml` file.

```yaml
dependencies:
  power_table: ^0.0.1 # Replace with the latest version
```

Then, run `flutter pub get` in your terminal.

## Usage

Import the package into your Dart file:

```dart
import 'package:power_table/power_table.dart';
```

### Basic Example

Here's a simple example of how to create a basic table:

```dart
InteractiveTable(
  data: const [
    {'ID': 1, 'Name': 'John Doe', 'Role': 'Developer'},
    {'ID': 2, 'Name': 'Jane Smith', 'Role': 'Designer'},
  ],
)
```

### Full Example with All Features

Here is a more advanced example demonstrating how to use all the features together:

```dart
InteractiveTable(
  // Data and Headers
  data: _sampleData,
  headers: const ['ID', 'Name', 'Role'],

  // Styling
  tableStyle: TableStyle(
    headerColor: Colors.blueGrey[800],
    evenRowColor: Colors.grey[850],
    oddRowColor: Colors.grey[900],
    headerTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    rowTextStyle: const TextStyle(color: Colors.white70),
    cellPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  ),

  // Features
  sortable: true,
  searchController: _searchController, // Provide an external controller
  pagination: true,
  rowsPerPage: 15,

  // Sticky Headers
  stickyHeaders: true,
  columnWidths: const {
    'ID': 50.0,
    'Name': 150.0,
    'Role': 150.0,
    'Select': 60.0, // Don't forget width for the select column
  },

  // Row Selection
  selectable: true,
  onSelectionChanged: (selectedRows) {
    setState(() {
      _selectedRows = selectedRows;
    });
  },

  // Conditional Formatting
  conditionalTextStyleBuilder: (String header, dynamic value) {
    if (header == 'Role') {
      if (value == 'Developer') {
        return const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold);
      }
      if (value == 'Manager') {
        return const TextStyle(color: Colors.yellowAccent);
      }
    }
    return null; // Use default style for all other cases
  },
)
```

## Additional Information

If you encounter any issues or have a feature request, please file an issue on the [GitHub repository](https://github.com/georgeswalker/power_table). We welcome contributions! Feel free to fork the repository and submit a pull request.
