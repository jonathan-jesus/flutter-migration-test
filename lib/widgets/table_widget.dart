// NOTE: This widget is only to allow for visualiztion of the table contents.
// It is not part of what is being explained in this project.

import 'dart:typed_data';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  const TableWidget({super.key, required this.items, this.columns = const []});

  final List<Map<String, dynamic>> items;
  final List<String> columns;

  String getValue(dynamic item) {
    if (item == null) return 'NULL';
    if (item is Uint8List) return '[byte array]';
    return item.toString();
  }

  List<Widget> buildCells(
    List<dynamic> itemsSource,
    BuildContext context, [
    bool isTitle = false,
  ]) {
    if (itemsSource.isEmpty) return [];
    return <Widget>[
      for (var item in itemsSource)
        Container(
          alignment: Alignment.center,
          width: 180.0,
          height: isTitle ? 60 : 50,
          color: Colors.white,
          margin: const EdgeInsets.all(4.0),
          child: item == null
              ? const Text(
                  'NULL',
                  style: TextStyle(fontStyle: FontStyle.italic),
                )
              : Text(
                  getValue(item),
                  style: isTitle
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.bodySmall,
                ),
        ),
    ];
  }

  List<Widget> buildHeader(List<String> columns, BuildContext context) {
    if (columns.isEmpty) return [];
    return <Widget>[Row(children: buildCells(columns, context, true))];
  }

  List<Widget> buildRows(
    List<Map<String, dynamic>> maps,
    BuildContext context,
  ) {
    if (maps.isEmpty) return [];
    if (maps[0].keys.isEmpty) return [];
    return <Widget>[
      for (var map in maps)
        Row(children: buildCells([for (var col in columns) map[col]], context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...buildHeader(columns, context),
                  ...buildRows(items, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
