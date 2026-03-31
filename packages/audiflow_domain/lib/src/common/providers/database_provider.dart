import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
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

/// Opens Isar with schema mismatch recovery.
///
/// On [IsarError] (e.g. collection ID mismatch after app update),
/// deletes the existing database files and retries. Data loss is
/// acceptable because subscriptions and episodes are re-synced from RSS.
Future<Isar> openIsarWithRecovery({
  required String directory,
  String name = 'audiflow',
  Logger? logger,
}) async {
  try {
    return await Isar.open(isarSchemas, directory: directory, name: name);
  } on IsarError catch (e) {
    logger?.w('Isar open failed, deleting database for recovery', error: e);
    await _deleteIsarFiles(directory: directory, name: name);
    return Isar.open(isarSchemas, directory: directory, name: name);
  }
}

Future<void> _deleteIsarFiles({
  required String directory,
  required String name,
}) async {
  final extensions = ['', '.lock'];
  for (final ext in extensions) {
    final file = File('$directory/$name.isar$ext');
    if (file.existsSync()) {
      await file.delete();
    }
  }
}

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden at startup');
});
