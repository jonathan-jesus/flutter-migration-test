import 'package:flutter/material.dart';
import 'package:sqflite_migration_test/data/db_helper.dart';
import 'package:sqflite_migration_test/widgets/table_widget.dart';
import 'package:sqflite_migration_test/data/local_db.dart' as local_db;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Migration Test',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> table1Items = [];
  List<String> table1Columns = [];
  List<Map<String, dynamic>> table2Items = [];
  List<String> table2Columns = [];
  int dbVersion = local_db.LocalDb.instance.dbVersion;
  final int dbMaxVersion = local_db.LocalDb.instance.dbMaxVersion;

  Future<void> fetchTable1Data() async {
    var items = await DbHelper().fetchTableData('table1');
    var columns = items.isNotEmpty
        ? items.first.keys.toList().cast<String>()
        : await DbHelper().listColumns('table1');
    setState(() {
      table1Items = items;
      table1Columns = columns;
    });
  }

  Future<void> fetchTable2Data() async {
    var items = await DbHelper().fetchTableData('table2');
    var columns = items.isNotEmpty
        ? items.first.keys.toList().cast<String>()
        : await DbHelper().listColumns('table2');
    setState(() {
      table2Items = items;
      table2Columns = columns;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshAllTables();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //Button handlers
  Future<void> _onAddPressed() async {
    if (_tabController.index == 0) {
      await DbHelper().insertRandomRow('table1');
      await fetchTable1Data();
    } else if (_tabController.index == 1) {
      await DbHelper().insertRandomRow('table2');
      await fetchTable2Data();
    }
  }

  Future<void> _onCleanPressed() async {
    await DbHelper().truncateTables();
    await _refreshAllTables();
  }

  Future<bool> _showConfirmationDialog({required String message}) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text('Warning!'),
              ],
            ),
            content: Text(message),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              OutlinedButton(
                child: const Text('Proceed'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onDowngradePressed() async {
    bool dialogResult = await _showConfirmationDialog(
      message:
          'Current version: $dbVersion\n'
          'Downgrading to: ${dbVersion - 1}\n'
          'Applying this migration will cause loss of data.',
    );

    if (dialogResult == true) {
      await local_db.LocalDb.downgradeToPreviousVersion();
      await _refreshAllTables();
    }
  }

  Future<void> _onUpgradePressed() async {
    bool dialogResult = await _showConfirmationDialog(
      message:
          'Current version: $dbVersion\n'
          'Upgrading to: ${dbVersion + 1}',
    );

    if (dialogResult == true) {
      await local_db.LocalDb.upgradeToNextVersion();
      await _refreshAllTables();
    }
  }

  Future<void> _refreshAllTables() async {
    await fetchTable1Data();
    await fetchTable2Data();
    setState(() => dbVersion = local_db.LocalDb.instance.dbVersion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('SQFlite Migration Test'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('v$dbVersion')),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar.secondary(
            isScrollable: true,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Table1'),
              Tab(text: 'Table2'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                TableWidget(items: table1Items, columns: table1Columns),
                TableWidget(items: table2Items, columns: table2Columns),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton.filled(
              icon: Icon(Icons.add),
              onPressed: () => _onAddPressed(),
            ),
            const SizedBox(height: 10, width: 20),
            IconButton.filled(
              icon: Icon(Icons.cleaning_services),
              onPressed: () => _onCleanPressed(),
            ),
            const SizedBox(height: 10, width: 20),
            IconButton.filled(
              icon: Icon(Icons.arrow_downward),
              onPressed: dbVersion > 1 ? () => _onDowngradePressed() : null,
            ),
            IconButton.filled(
              icon: Icon(Icons.arrow_upward),
              onPressed: dbVersion < dbMaxVersion
                  ? () => _onUpgradePressed()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
