import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/episode.dart';
import 'episode_favorite_repository.dart';

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
    required Isar isar,
    required StationReconcilerService reconcilerService,
  }) : _isar = isar,
       _reconcilerService = reconcilerService;

  final Isar _isar;
  final StationReconcilerService _reconcilerService;

  @override
  Future<void> toggleFavorite(int episodeId) async {
    final episode = await _isar.episodes.get(episodeId);
    if (episode == null) return;

    episode.isFavorited = !episode.isFavorited;
    episode.favoritedAt = episode.isFavorited ? DateTime.now() : null;

    await _isar.writeTxn(() => _isar.episodes.put(episode));

    // Best-effort station reconciliation.
    try {
      await _reconcilerService.onEpisodeChanged(episodeId);
    } on Exception {
      // Do not break favorite toggle if reconciliation fails.
    }
  }
}
