import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Main database class for Audiflow
///
/// Uses Drift with SQLite for local data storage.
/// Tables will be added as features are implemented.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  /// Creates the database instance with lazy initialization
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
