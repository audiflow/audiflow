import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../transcript/datasources/local/chapter_local_datasource.dart';
import '../../transcript/datasources/local/transcript_local_datasource.dart';
import '../datasources/local/episode_local_datasource.dart';
import '../models/smart_playlist_episode_extractor.dart';
import 'episode_repository.dart';

part 'episode_repository_impl.g.dart';

/// Provides a singleton [EpisodeRepository] instance.
@Riverpod(keepAlive: true)
EpisodeRepository episodeRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final datasource = EpisodeLocalDatasource(db);
  return EpisodeRepositoryImpl(
    datasource: datasource,
    transcriptDatasource: TranscriptLocalDatasource(db),
    chapterDatasource: ChapterLocalDatasource(db),
  );
}

/// Implementation of [EpisodeRepository] using Drift database.
class EpisodeRepositoryImpl implements EpisodeRepository {
  EpisodeRepositoryImpl({
    required EpisodeLocalDatasource datasource,
    TranscriptLocalDatasource? transcriptDatasource,
    ChapterLocalDatasource? chapterDatasource,
  }) : _datasource = datasource,
       _transcriptDatasource = transcriptDatasource,
       _chapterDatasource = chapterDatasource;

  final EpisodeLocalDatasource _datasource;
  final TranscriptLocalDatasource? _transcriptDatasource;
  final ChapterLocalDatasource? _chapterDatasource;

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
  }) async {
    final validItems = items
        .where((item) => item.guid != null && item.enclosureUrl != null)
        .toList();

    final companions = validItems.map((item) {
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
    }).toList();

    await _datasource.upsertAll(companions);
    await _storeTranscriptAndChapterData(podcastId, validItems);
  }

  /// Stores transcript metadata and chapters for episodes that have them.
  Future<void> _storeTranscriptAndChapterData(
    int podcastId,
    List<PodcastItem> items,
  ) async {
    final hasTranscriptItems = items.where((i) => i.hasTranscripts);
    final hasChapterItems = items.where((i) => i.hasChapters);

    if (hasTranscriptItems.isEmpty && hasChapterItems.isEmpty) return;

    // Resolve episode IDs for items that need transcript/chapter storage
    final guidsNeedingLookup = <String>{
      ...hasTranscriptItems.map((i) => i.guid!),
      ...hasChapterItems.map((i) => i.guid!),
    };

    final guidToId = <String, int>{};
    for (final guid in guidsNeedingLookup) {
      final episode = await _datasource.getByPodcastIdAndGuid(podcastId, guid);
      if (episode != null) {
        guidToId[guid] = episode.id;
      }
    }

    if (guidToId.isEmpty) return;

    await _storeTranscriptMetas(hasTranscriptItems, guidToId);
    await _storeChapters(hasChapterItems, guidToId);
  }

  /// Builds and upserts transcript metadata companions.
  Future<void> _storeTranscriptMetas(
    Iterable<PodcastItem> items,
    Map<String, int> guidToId,
  ) async {
    if (_transcriptDatasource == null) return;

    final companions = <EpisodeTranscriptsCompanion>[];
    for (final item in items) {
      final episodeId = guidToId[item.guid!];
      if (episodeId == null) continue;

      for (final transcript in item.transcripts!) {
        companions.add(
          EpisodeTranscriptsCompanion.insert(
            episodeId: episodeId,
            url: transcript.url,
            type: transcript.type,
            language: Value(transcript.language),
            rel: Value(transcript.rel),
          ),
        );
      }
    }

    if (companions.isNotEmpty) {
      await _transcriptDatasource.upsertMetas(companions);
    }
  }

  /// Builds and upserts chapter companions.
  Future<void> _storeChapters(
    Iterable<PodcastItem> items,
    Map<String, int> guidToId,
  ) async {
    if (_chapterDatasource == null) return;

    final companions = <EpisodeChaptersCompanion>[];
    for (final item in items) {
      final episodeId = guidToId[item.guid!];
      if (episodeId == null) continue;

      for (final (index, chapter) in item.chapters!.indexed) {
        companions.add(
          EpisodeChaptersCompanion.insert(
            episodeId: episodeId,
            sortOrder: index,
            title: chapter.title,
            startMs: chapter.startTime.inMilliseconds,
            endMs: Value(chapter.endTime?.inMilliseconds),
            url: Value(chapter.url),
            imageUrl: Value(chapter.imageUrl),
          ),
        );
      }
    }

    if (companions.isNotEmpty) {
      await _chapterDatasource.upsertChapters(companions);
    }
  }

  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) {
    return _datasource.getGuidsByPodcastId(podcastId);
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
