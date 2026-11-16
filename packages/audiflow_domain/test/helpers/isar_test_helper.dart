import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:isar_community/isar.dart';

/// Opens an Isar instance in a system temp directory to avoid
/// leftover `.isar-lck` files in the project root.
///
/// The collections the user state path touches are always included:
/// `UserStateStore` keeps its clock in [SyncMeta], and user state readers
/// resolve episodes, podcasts, and the old rows next to the new ones.
Future<Isar> openTestIsar(List<CollectionSchema<dynamic>> schemas) async {
  final dir = await Directory.systemTemp.createTemp('audiflow_isar_test_');
  return Isar.open(
    {
      ...schemas,
      SyncMetaSchema,
      EpisodeUserStateSchema,
      EpisodeSchema,
      SubscriptionSchema,
      PlaybackHistorySchema,
      PodcastUserStateSchema,
      PodcastViewPreferenceSchema,
      PodcastAudioPreferenceSchema,
      PodcastParentalFlagsSchema,
      SmartPlaylistUserPreferenceSchema,
      SmartPlaylistGroupUserPreferenceSchema,
    }.toList(),
    directory: dir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
}
