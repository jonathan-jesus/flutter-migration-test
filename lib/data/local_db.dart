import 'package:sqflite/sqflite.dart';

class LocalDb {
  LocalDb._privateConstructor();
  static final LocalDb instance = LocalDb._privateConstructor();
  static Database? _db;

  Future<Database> get db async {
    if (_db != null && _db!.isOpen == true) {
      return _db!;
    }
    _db = await _openDatabase();
    return _db!;
  }

  static int _dbVersion =
      1; // Always start at v1. UI interactions determine migrations.
  int get dbVersion => _dbVersion;

  int get dbMaxVersion => _migrations.length;

  Future<Database> _openDatabase() async {
    return await openDatabase(
      'local.db',
      version: _dbVersion,
      onCreate: (db, newVersion) async {
        print('Creating database...');
        for (int version = 0; version < newVersion; version++) {
          await _migrations[version + 1]!(db);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database...');
        for (int version = oldVersion; version < newVersion; version++) {
          await _migrations[version + 1]!(db);
        }
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        print('Downgrading database...');
        for (int version = oldVersion; version > newVersion; version--) {
          await _downgrades[version - 1]!(db);
        }
      },
    );
  }

  /// This function check if the version is inside the range of the migration versions
  /// and then sets the stage for the migration
  static Future<void> upgradeToNextVersion() async {
    if (_dbVersion < _migrations.length) {
      await _closeDb();
      _dbVersion++;

      // Asking for a new instance of the database to trigger a new initialization, which, in turn,
      // trigger a migration as the version will differ.
      await instance.db;
    }
  }

  /// This function check if the version is inside the range of the migration versions
  /// and then sets the stage for the migration
  static Future<void> downgradeToPreviousVersion() async {
    if (_dbVersion > 1) {
      await _closeDb();
      _dbVersion--;

      // Asking for a new instance of the database to trigger a new initialization, which, in turn,
      // trigger a migration as the version will differ.
      await instance.db;
    }
  }

  /// Normally unnecessary, but here required to force version re-check
  /// because we are simulating migrations interactively.
  static Future<void> _closeDb() async {
    if (_db?.isOpen == true) {
      await _db!.close();
      _db = null;
    }
  }

  static final Map<int, Future<void> Function(Database)> _migrations = {
    1: (db) async {
      await db.execute('''CREATE TABLE table1(
          id INTEGER PRIMARY KEY,
          col1 TEXT NULLABLE,
          col2 TEXT NULLABLE
        )''');
      await db.execute('''CREATE TABLE table2(
          id INTEGER PRIMARY KEY,
          col1 TEXT NULLABLE,
          col2 TEXT NULLABLE
        )''');
    },
    2: (db) async {
      await db.execute('ALTER TABLE table1 add col3 TEXT NULLABLE');
      await db.execute('ALTER TABLE table2 add col3 TEXT NULLABLE');
    },
    3: (db) async {
      await db.execute('ALTER TABLE table1 add col4 TEXT NULLABLE');
      await db.execute('ALTER TABLE table2 add col4 TEXT NULLABLE');
    },
  };

  static final Map<int, Future<void> Function(Database)> _downgrades = {
    1: (db) async {
      await db.execute('ALTER TABLE table1 drop col3');
      await db.execute('ALTER TABLE table2 drop col3');
    },
    2: (db) async {
      await db.execute('ALTER TABLE table1 drop col4');
      await db.execute('ALTER TABLE table2 drop col4');
    },
  };
}
