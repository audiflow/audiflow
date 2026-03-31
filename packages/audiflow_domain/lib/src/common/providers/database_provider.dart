import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';

import '../../features/download/models/download_task.dart';
import '../../features/feed/models/episode.dart';
import '../../features/feed/models/podcast_view_preference.dart';
import '../../features/feed/models/smart_playlist_groups.dart';
import '../../features/feed/models/smart_playlists.dart';
import '../../features/player/models/playback_history.dart';
import '../../features/queue/models/queue_item.dart';
import '../../features/station/models/station.dart';
import '../../features/station/models/station_episode.dart';
import '../../features/station/models/station_podcast.dart';
import '../../features/subscription/models/subscriptions.dart';
import '../../features/transcript/models/episode_chapter.dart';
import '../../features/transcript/models/episode_transcript.dart';
import '../../features/transcript/models/transcript_segment_table.dart';

/// Canonical list of all Isar collection schemas.
///
/// Both foreground and background entry points must use this list
/// to avoid dropping collections when Isar opens with a subset.
const List<CollectionSchema<dynamic>> isarSchemas = [
  SubscriptionSchema,
  EpisodeSchema,
  DownloadTaskSchema,
  PlaybackHistorySchema,
  SmartPlaylistEntitySchema,
  SmartPlaylistGroupEntitySchema,
  PodcastViewPreferenceSchema,
  QueueItemSchema,
  EpisodeTranscriptSchema,
  TranscriptSegmentSchema,
  EpisodeChapterSchema,
  StationSchema,
  StationPodcastSchema,
  StationEpisodeSchema,
];

/// Opens Isar with automatic recovery on any [IsarError].
///
/// When Isar fails to open (e.g. schema mismatch after app update,
/// corrupted files, or other internal errors), this deletes **all**
/// Isar database files matching `$name.isar*` and retries opening
/// with the full [isarSchemas] list.
///
/// This is a last-resort recovery mechanism that drops every Isar
/// collection (subscriptions, episodes, playback history, download
/// tasks, queue, smart playlists, view preferences, transcripts,
/// stations, etc. per [isarSchemas]). Subscriptions and episodes can
/// be re-synced from RSS, but other local-only state is permanently
/// lost. This trade-off is accepted to recover from corruption that
/// would otherwise prevent the app from opening its database at all.
///
/// Note: [IsarError] extends [Error] with only a `message` string and
/// no structured error codes, so narrowing the catch is not feasible.
Future<Isar> openIsarWithRecovery({
  required String directory,
  String name = 'audiflow',
  Logger? logger,
}) async {
  try {
    return await Isar.open(isarSchemas, directory: directory, name: name);
  } on IsarError catch (e, stack) {
    logger?.w(
      'Isar open failed, deleting database for recovery',
      error: e,
      stackTrace: stack,
    );
    await _deleteIsarFiles(directory: directory, name: name, logger: logger);
    return Isar.open(isarSchemas, directory: directory, name: name);
  }
}

Future<void> _deleteIsarFiles({
  required String directory,
  required String name,
  Logger? logger,
}) async {
  final dir = Directory(directory);
  if (!await dir.exists()) {
    return;
  }

  try {
    final prefix = '$name.isar';
    await for (final entity in dir.list()) {
      if (entity is! File) {
        continue;
      }

      final fileName = p.basename(entity.path);
      if (fileName.startsWith(prefix)) {
        try {
          await entity.delete();
        } on FileSystemException {
          // Ignore per-file failures; recovery will retry opening Isar.
        }
      }
    }
  } on FileSystemException catch (e, stack) {
    // Directory listing itself failed (permissions, IO). Log and let
    // the caller retry the Isar open, which will surface the real error.
    logger?.w(
      'Failed to list directory during Isar cleanup',
      error: e,
      stackTrace: stack,
    );
  }
}

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden at startup');
});
