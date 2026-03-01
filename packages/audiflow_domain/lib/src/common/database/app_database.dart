import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/download/models/download_status.dart';
import '../../features/download/models/download_task.dart';
import '../../features/feed/models/episode.dart';
import '../../features/feed/models/podcast_view_preference.dart';
import '../../features/feed/models/smart_playlist_groups.dart';
import '../../features/feed/models/smart_playlists.dart';
import '../../features/player/models/playback_history.dart';
import '../../features/queue/models/queue_item.dart';
import '../../features/subscription/models/subscriptions.dart';
import '../../features/transcript/models/episode_chapter.dart';
import '../../features/transcript/models/episode_transcript.dart';
import '../../features/transcript/models/transcript_segment_table.dart';

part 'app_database.g.dart';

/// Main database class for Audiflow
///
/// Uses Drift with SQLite for local data storage.
@DriftDatabase(
  tables: [
    Subscriptions,
    Episodes,
    PlaybackHistories,
    SmartPlaylists,
    SmartPlaylistGroups,
    PodcastViewPreferences,
    DownloadTasks,
    QueueItems,
    EpisodeTranscripts,
    TranscriptSegments,
    EpisodeChapters,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database instance with lazy initialization
  AppDatabase() : super(_openConnection());

  /// Creates a test database with in-memory storage.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 17;

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
        await m.createTable(smartPlaylists);
      }
      // Migration from v5 to v6: add thumbnail_url column to Seasons table
      if (6 <= to && from < 6) {
        await m.addColumn(smartPlaylists, smartPlaylists.thumbnailUrl);
      }
      // Migration from v6 to v7: add PodcastViewPreferences table
      if (7 <= to && from < 7) {
        await m.createTable(podcastViewPreferences);
      }
      // Migration from v7 to v8: add season sort columns to PodcastViewPreferences
      if (8 <= to && from < 8) {
        await m.addColumn(
          podcastViewPreferences,
          podcastViewPreferences.seasonSortField,
        );
        await m.addColumn(
          podcastViewPreferences,
          podcastViewPreferences.seasonSortOrder,
        );
      }
      // Migration from v8 to v9: add DownloadTasks table
      if (9 <= to && from < 9) {
        await m.createTable(downloadTasks);
      }
      // Migration from v9 to v10: add QueueItems table
      if (10 <= to && from < 10) {
        await m.createTable(queueItems);
      }
      // Migration from v10 to v11: add yearGrouped column
      if (11 <= to && from < 11) {
        await m.addColumn(smartPlaylists, smartPlaylists.yearGrouped);
      }
      // Migration from v11 to v12: add selectedPlaylistId column
      if (12 <= to && from < 12) {
        await m.addColumn(
          podcastViewPreferences,
          podcastViewPreferences.selectedPlaylistId,
        );
      }
      // Migration from v12 to v13: add new columns to SmartPlaylists
      if (13 <= to && from < 13) {
        await m.addColumn(smartPlaylists, smartPlaylists.contentType);
        await m.addColumn(smartPlaylists, smartPlaylists.yearHeaderMode);
        await m.addColumn(smartPlaylists, smartPlaylists.episodeYearHeaders);
        // Migrate yearGrouped data
        await customStatement(
          "UPDATE seasons"
          " SET year_header_mode = 'firstEpisode'"
          " WHERE year_grouped = 1",
        );
      }
      // Migration from v13 to v14: create SmartPlaylistGroups table
      if (14 <= to && from < 14) {
        await m.createTable(smartPlaylistGroups);
      }
      // Migration from v14 to v15: add cached metadata columns
      if (15 <= to && from < 15) {
        await m.addColumn(
          smartPlaylistGroups,
          smartPlaylistGroups.earliestDate,
        );
        await m.addColumn(smartPlaylistGroups, smartPlaylistGroups.latestDate);
        await m.addColumn(
          smartPlaylistGroups,
          smartPlaylistGroups.totalDurationMs,
        );
      }
      // Migration from v15 to v16: add episodeYearHeaders to groups
      if (16 <= to && from < 16) {
        await m.addColumn(
          smartPlaylistGroups,
          smartPlaylistGroups.episodeYearHeaders,
        );
      }
      // Migration from v16 to v17: add transcript and chapter tables
      if (17 <= to && from < 17) {
        await m.createTable(episodeTranscripts);
        await m.createTable(transcriptSegments);
        await m.createTable(episodeChapters);
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

/// Extension to convert between Drift model and domain status.
extension DownloadTaskStatusX on DownloadTask {
  /// Get the status as a typed enum.
  DownloadStatus get downloadStatus => DownloadStatus.fromDbValue(status);

  /// Calculate download progress (0.0 to 1.0), or null if unknown.
  double? get progress {
    if (totalBytes == null || totalBytes == 0) return null;
    return downloadedBytes / totalBytes!;
  }
}
