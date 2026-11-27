import 'package:isar_community/isar.dart';

import '../../feed/models/episode.dart';
import '../models/episode_user_state.dart';
import 'data_migration_runner.dart';

/// Fills the locator of `EpisodeUserState` rows made before it existed,
/// from their catalog episodes (M6f).
///
/// The locator is what another device that keys an episode differently
/// searches by, so a row without one could never be joined there. Rows
/// whose episode is not in the catalog stay without one; the merge fills
/// it in if another device sends it. Only rows still lacking a locator
/// are written, so the step can be interrupted and run again.
class EpisodeLocatorBackfill implements DataMigrationStep {
  const EpisodeLocatorBackfill({this.batchSize = 200});

  /// Rows written per transaction, so a large library does not hold one
  /// long write lock at launch.
  final int batchSize;

  @override
  int get version => 6;

  @override
  String get name => 'episode locator';

  @override
  Future<void> run(Isar isar) async {
    final ids = await isar.episodeUserStates
        .filter()
        .locatorGuidIsNull()
        .idProperty()
        .findAll();
    for (var start = 0; start < ids.length; start += batchSize) {
      final end = ids.length < start + batchSize
          ? ids.length
          : start + batchSize;
      final batch = ids.sublist(start, end);
      await isar.writeTxn(() async {
        final states = await isar.episodeUserStates.getAll(batch);
        final filled = <EpisodeUserState>[];
        for (final state in states) {
          // Filled meanwhile, by a merge or a local write.
          if (state == null || state.locatorGuid != null) continue;
          final episode = await isar.episodes
              .where()
              .episodeKeyEqualTo(state.episodeKey)
              .findFirst();
          if (episode == null) continue;
          filled.add(
            state
              ..locatorGuid = episode.guid
              ..locatorAudioUrl = episode.audioUrl
              ..locatorPublishedAt = episode.publishedAt,
          );
        }
        // No clock and no op: the locator is not a change, and the first
        // sync sends every row whole.
        await isar.episodeUserStates.putAll(filled);
      });
    }
  }
}
