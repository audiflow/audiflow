import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../feed/models/episode.dart';
import '../datasources/local/playback_history_local_datasource.dart';
import '../models/playback_history.dart';
import 'playback_history_repository.dart';

part 'playback_history_repository_impl.g.dart';

/// Provides a singleton [PlaybackHistoryRepository] instance.
@Riverpod(keepAlive: true)
PlaybackHistoryRepository playbackHistoryRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = PlaybackHistoryLocalDatasource(isar);
  return PlaybackHistoryRepositoryImpl(datasource: datasource);
}

/// Implementation of [PlaybackHistoryRepository] using Isar database.
class PlaybackHistoryRepositoryImpl implements PlaybackHistoryRepository {
  PlaybackHistoryRepositoryImpl({
    required PlaybackHistoryLocalDatasource datasource,
  }) : _datasource = datasource;

  final PlaybackHistoryLocalDatasource _datasource;

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return _datasource.getByEpisodeId(episodeId);
  }

  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  }) {
    return _datasource.updateProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
    );
  }

  @override
  Future<void> markCompleted(int episodeId) {
    return _datasource.markCompleted(episodeId);
  }

  @override
  Future<void> markIncomplete(int episodeId) {
    return _datasource.markIncomplete(episodeId);
  }

  @override
  Future<void> incrementPlayCount(int episodeId) {
    return _datasource.incrementPlayCount(episodeId);
  }

  @override
  Future<bool> isCompleted(int episodeId) {
    return _datasource.isCompleted(episodeId);
  }

  @override
  Future<double?> getProgressPercent(int episodeId) async {
    final history = await _datasource.getByEpisodeId(episodeId);
    if (history == null) return null;
    if (history.durationMs == null || history.durationMs == 0) return null;
    return history.positionMs / history.durationMs!;
  }

  @override
  Future<PlaybackHistory?> getLastPlayed() {
    return _datasource.getLastPlayed();
  }

  @override
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return _datasource.watchInProgress(limit: limit);
  }

  @override
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) {
    return _datasource.getByPodcastId(podcastId);
  }
}
