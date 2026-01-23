import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/episode_local_datasource.dart';
import 'episode_repository.dart';

part 'episode_repository_impl.g.dart';

/// Provides a singleton [EpisodeRepository] instance.
@Riverpod(keepAlive: true)
EpisodeRepository episodeRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final datasource = EpisodeLocalDatasource(db);
  return EpisodeRepositoryImpl(datasource: datasource);
}

/// Implementation of [EpisodeRepository] using Drift database.
class EpisodeRepositoryImpl implements EpisodeRepository {
  EpisodeRepositoryImpl({required EpisodeLocalDatasource datasource})
    : _datasource = datasource;

  final EpisodeLocalDatasource _datasource;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) {
    return _datasource.getByPodcastId(podcastId);
  }

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    return _datasource.watchByPodcastId(podcastId);
  }

  @override
  Future<Episode?> getById(int id) {
    return _datasource.getById(id);
  }

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) {
    return _datasource.getByAudioUrl(audioUrl);
  }

  @override
  Future<void> upsertEpisodes(List<EpisodesCompanion> episodes) {
    return _datasource.upsertAll(episodes);
  }

  @override
  Future<void> upsertFromFeedItems(int podcastId, List<PodcastItem> items) {
    final companions = items
        .where((item) => item.guid != null && item.enclosureUrl != null)
        .map(
          (item) => EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: item.guid!,
            title: item.title,
            description: Value(item.description),
            audioUrl: item.enclosureUrl!,
            durationMs: Value(item.duration?.inMilliseconds),
            publishedAt: Value(item.publishDate),
            imageUrl: Value(item.primaryImage?.url),
            episodeNumber: Value(item.episodeNumber),
            seasonNumber: Value(item.seasonNumber),
          ),
        )
        .toList();

    return _datasource.upsertAll(companions);
  }
}
