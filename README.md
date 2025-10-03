# SQFlite Migration Test

This is a Flutter app built to demonstrate SQLite database migrations in a mobile project using the sqflite package.

It allows you to:

• View the contents of two sample tables.

• Insert random rows for quick testing.

• Upgrade or downgrade the database schema through predefined migration steps.

• See migrations happen live, with both data changes and schema changes reflected immediately.

# 🎯 Purpose

This project is not meant to be a production-ready database solution.
It was created as a learning and teaching tool to help developers understand:

How to structure migrations in SQLite.

How onCreate, onUpgrade, and onDowngrade work in sqflite.

How to keep track of schema versions.

What happens to data when migrating up or down between versions.

# 📂 Project Structure

lib/main.dart – App entry point and UI for interacting with migrations.

lib/local_db/local_db.dart – Database logic.

lib/local_db/dh_helper.dart – Database helpers.

lib/utils/common.dart – Utility functions (e.g., random string generator).

lib/widgets/table_widget.dart – Utility widget to visualize table contents.

# 📖 How migrations are defined

Migrations are stored in maps keyed by version number inside local_db.dart:

\_migrations: Defines how to upgrade schema step by step.

\_downgrades: Defines how to rollback schema changes.

Example:

static final Map<int, Future<void> Function(Database)> \_migrations = {
1: (db) async {
//version 1 schema  
 await db.execute('CREATE TABLE sometable...');
},
2: (db) async {
//version 2 schema  
 //change somthing or create new tables
},
};

# ⚠️ Disclaimer

This project is for educational purposes only, not for production use.

# License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
