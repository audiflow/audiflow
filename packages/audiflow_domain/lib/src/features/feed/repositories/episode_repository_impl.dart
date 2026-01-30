import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/episode_local_datasource.dart';
import '../models/smart_playlist_episode_extractor.dart';
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
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    SmartPlaylistEpisodeExtractor? extractor,
  }) {
    final companions = items
        .where((item) => item.guid != null && item.enclosureUrl != null)
        .map((item) {
          // Apply extraction if extractor is provided
          int? seasonNumber = item.seasonNumber;
          int? episodeNumber = item.episodeNumber;

          if (extractor != null) {
            final episodeData = _PodcastItemEpisodeData(item);
            final extracted = extractor.extract(episodeData);
            if (extracted.hasValues) {
              seasonNumber = extracted.seasonNumber ?? seasonNumber;
              episodeNumber = extracted.episodeNumber ?? episodeNumber;
            }
          }

          return EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: item.guid!,
            title: item.title,
            description: Value(item.description),
            audioUrl: item.enclosureUrl!,
            durationMs: Value(item.duration?.inMilliseconds),
            publishedAt: Value(item.publishDate),
            imageUrl: Value(item.primaryImage?.url),
            episodeNumber: Value(episodeNumber),
            seasonNumber: Value(seasonNumber),
          );
        })
        .toList();

    return _datasource.upsertAll(companions);
  }

  @override
  Future<List<Episode>> getByIds(List<int> ids) {
    return _datasource.getByIds(ids);
  }

  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) {
    return _datasource.getSubsequentEpisodes(
      podcastId: podcastId,
      afterEpisodeNumber: afterEpisodeNumber,
      limit: limit,
    );
  }
}

/// Adapter to make [PodcastItem] work with [EpisodeData] interface.
class _PodcastItemEpisodeData implements EpisodeData {
  const _PodcastItemEpisodeData(this._item);

  final PodcastItem _item;

  @override
  String get title => _item.title;

  @override
  String? get description => _item.description;

  @override
  int? get seasonNumber => _item.seasonNumber;

  @override
  int? get episodeNumber => _item.episodeNumber;
}
