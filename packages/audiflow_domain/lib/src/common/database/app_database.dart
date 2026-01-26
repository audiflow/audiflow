import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/feed/models/episode.dart';
import '../../features/feed/models/seasons.dart';
import '../../features/player/models/playback_history.dart';
import '../../features/subscription/models/subscriptions.dart';

part 'app_database.g.dart';

/// Main database class for Audiflow
///
/// Uses Drift with SQLite for local data storage.
@DriftDatabase(tables: [Subscriptions, Episodes, PlaybackHistories, Seasons])
class AppDatabase extends _$AppDatabase {
  /// Creates the database instance with lazy initialization
  AppDatabase() : super(_openConnection());

  /// Creates a test database with in-memory storage.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migration from v1 to v2: add Subscriptions table
      if (2 <= to && from < 2) {
        await m.createTable(subscriptions);
      }
      // Migration from v2 to v3: add Episodes table
      if (3 <= to && from < 3) {
        await m.createTable(episodes);
      }
      // Migration from v3 to v4: add PlaybackHistories table
      if (4 <= to && from < 4) {
        await m.createTable(playbackHistories);
      }
      // Migration from v4 to v5: add Seasons table
      if (5 <= to && from < 5) {
        await m.createTable(seasons);
      }
      // Migration from v5 to v6: add thumbnail_url column to Seasons table
      if (6 <= to && from < 6) {
        await m.addColumn(seasons, seasons.thumbnailUrl);
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
