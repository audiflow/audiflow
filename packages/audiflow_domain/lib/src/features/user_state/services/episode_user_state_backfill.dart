import 'package:isar_community/isar.dart';

import '../../feed/models/episode.dart';
import '../../player/models/playback_history.dart';
import 'data_migration_runner.dart';
import 'episode_user_state_access.dart';
import 'user_state_store.dart';

/// Copies playback history and favorites of keyed episodes into
/// `EpisodeUserState` (M3).
///
/// Episodes whose podcast has no key yet are skipped; they are copied the
/// moment the podcast gets its key (`assignStableKeys`). Every copy skips
/// an episode whose new row already holds that state, so the step can be
/// interrupted and run again.
class EpisodeUserStateBackfill implements DataMigrationStep {
  const EpisodeUserStateBackfill({this.batchSize = 200});

  /// Episodes copied per transaction, so a large library does not hold one
  /// long write lock at launch.
  final int batchSize;

  @override
  int get version => 1;

  @override
  String get name => 'episode user state';

  @override
  Future<void> run(Isar isar) async {
    final store = UserStateStore(isar);
    final access = EpisodeUserStateAccess(isar);
    final historyEpisodeIds = await isar.playbackHistorys
        .where()
        .episodeIdProperty()
        .findAll();
    final favoriteIds = await isar.episodes
        .filter()
        .isFavoritedEqualTo(true)
        .idProperty()
        .findAll();
    final ids = {...historyEpisodeIds, ...favoriteIds}.toList()..sort();
    for (var start = 0; start < ids.length; start += batchSize) {
      final end = ids.length < start + batchSize
          ? ids.length
          : start + batchSize;
      final batch = ids.sublist(start, end);
      await store.write((txn) async {
        // Read inside the write so a key assigned meanwhile is seen.
        final episodes = await isar.episodes.getAll(batch);
        for (final episode in episodes) {
          if (episode == null) continue;
          await access.copyLegacy(episode, txn);
        }
      });
    }
  }
}
