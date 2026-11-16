import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/episode.dart';
import 'episode_favorite_repository.dart';
import '../../user_state/services/episode_user_state_access.dart';
import '../../user_state/services/user_state_store.dart';

part 'episode_favorite_repository_impl.g.dart';

@Riverpod(keepAlive: true)
EpisodeFavoriteRepository episodeFavoriteRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final reconcilerService = ref.watch(stationReconcilerServiceProvider);
  return EpisodeFavoriteRepositoryImpl(
    isar: isar,
    reconcilerService: reconcilerService,
  );
}

class EpisodeFavoriteRepositoryImpl implements EpisodeFavoriteRepository {
  EpisodeFavoriteRepositoryImpl({
    required this._isar,
    required this._reconcilerService,
  });

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  final StationReconcilerService _reconcilerService;

  @override
  Future<void> toggleFavorite(int episodeId) async {
    // Read inside the transaction: a snapshot taken outside it could be
    // stale by the time it is put back, undoing a feed refresh or the
    // stable key assigned in between.
    final found = await _store.write((txn) async {
      final episode = await _isar.episodes.get(episodeId);
      if (episode == null) return false;
      final access = EpisodeUserStateAccess(_isar);
      final favorited = !await access.isFavorited(episode);
      // The old fields keep being written for one release (rollback).
      episode
        ..isFavorited = favorited
        ..favoritedAt = favorited ? DateTime.now() : null;
      await _isar.episodes.put(episode);
      await access.saveFavorite(episode, txn);
      return true;
    });
    if (!found) return;

    // Best-effort station reconciliation.
    try {
      await _reconcilerService.onEpisodeChanged(episodeId);
    } on Exception {
      // Do not break favorite toggle if reconciliation fails.
    }
  }
}
