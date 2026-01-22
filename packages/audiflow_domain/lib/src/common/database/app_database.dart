import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/subscription/models/subscriptions.dart';

part 'app_database.g.dart';

/// Main database class for Audiflow
///
/// Uses Drift with SQLite for local data storage.
@DriftDatabase(tables: [Subscriptions])
class AppDatabase extends _$AppDatabase {
  /// Creates the database instance with lazy initialization
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migration from v1 to v2: add Subscriptions table
      if (from < 2) {
        await m.createTable(subscriptions);
      }
    },
  );

  /// Opens database connection with background isolate for I/O
  ///
  /// Database file is created at: {app_documents}/audiflow.db
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'audiflow.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
