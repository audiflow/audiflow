import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../transcript/datasources/local/chapter_local_datasource.dart';
import '../../transcript/datasources/local/transcript_local_datasource.dart';
import '../../transcript/models/episode_chapter.dart';
import '../../transcript/models/episode_transcript.dart';
import '../datasources/local/episode_local_datasource.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/smart_playlist_episode_extractor.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../services/episode_extractor_resolver.dart';
import 'episode_repository.dart';

part 'episode_repository_impl.g.dart';

/// Provides a singleton [EpisodeRepository] instance.
@Riverpod(keepAlive: true)
EpisodeRepository episodeRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = EpisodeLocalDatasource(isar);
  return EpisodeRepositoryImpl(
    datasource: datasource,
    transcriptDatasource: TranscriptLocalDatasource(isar),
    chapterDatasource: ChapterLocalDatasource(isar),
  );
}

/// Implementation of [EpisodeRepository] using Isar database.
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
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) {
    return _datasource.getByPodcastIdAndGuid(podcastId, guid);
  }

  @override
  Future<void> upsertEpisodes(List<Episode> episodes) {
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

    final episodes = validItems.map((item) {
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

      return Episode()
        ..podcastId = podcastId
        ..guid = item.guid!
        ..title = item.title
        ..description = item.description
        ..audioUrl = item.enclosureUrl!
        ..durationMs = item.duration?.inMilliseconds
        ..publishedAt = item.publishDate
        ..imageUrl = item.primaryImage?.url
        ..episodeNumber = episodeNumber
        ..seasonNumber = seasonNumber;
    }).toList();

    await _datasource.upsertAll(episodes);
    await _storeTranscriptAndChapterData(podcastId, validItems);
  }

  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  }) async {
    final resolver = EpisodeExtractorResolver();
    final validItems = items
        .where((item) => item.guid != null && item.enclosureUrl != null)
        .toList();

    final episodes = validItems.map((item) {
      int? seasonNumber = item.seasonNumber;
      int? episodeNumber = item.episodeNumber;

      final extractor = resolver.resolve(item.title, item.description, config);
      if (extractor != null) {
        final episodeData = _PodcastItemEpisodeData(item);
        final extracted = extractor.extract(episodeData);
        if (extracted.hasValues) {
          seasonNumber = extracted.seasonNumber ?? seasonNumber;
          episodeNumber = extracted.episodeNumber ?? episodeNumber;
        }
      }

      return Episode()
        ..podcastId = podcastId
        ..guid = item.guid!
        ..title = item.title
        ..description = item.description
        ..audioUrl = item.enclosureUrl!
        ..durationMs = item.duration?.inMilliseconds
        ..publishedAt = item.publishDate
        ..imageUrl = item.primaryImage?.url
        ..episodeNumber = episodeNumber
        ..seasonNumber = seasonNumber;
    }).toList();

    await _datasource.upsertAll(episodes);
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

  /// Builds and upserts transcript metadata.
  Future<void> _storeTranscriptMetas(
    Iterable<PodcastItem> items,
    Map<String, int> guidToId,
  ) async {
    if (_transcriptDatasource == null) return;

    final metas = <EpisodeTranscript>[];
    for (final item in items) {
      final episodeId = guidToId[item.guid!];
      if (episodeId == null) continue;

      for (final transcript in item.transcripts!) {
        metas.add(
          EpisodeTranscript()
            ..episodeId = episodeId
            ..url = transcript.url
            ..type = transcript.type
            ..language = transcript.language
            ..rel = transcript.rel,
        );
      }
    }

    if (metas.isNotEmpty) {
      await _transcriptDatasource.upsertMetas(metas);
    }
  }

  /// Builds and upserts chapters.
  Future<void> _storeChapters(
    Iterable<PodcastItem> items,
    Map<String, int> guidToId,
  ) async {
    if (_chapterDatasource == null) return;

    final chapters = <EpisodeChapter>[];
    for (final item in items) {
      final episodeId = guidToId[item.guid!];
      if (episodeId == null) continue;

      for (final (index, chapter) in item.chapters!.indexed) {
        chapters.add(
          EpisodeChapter()
            ..episodeId = episodeId
            ..sortOrder = index
            ..title = chapter.title
            ..startMs = chapter.startTime.inMilliseconds
            ..endMs = chapter.endTime?.inMilliseconds
            ..url = chapter.url
            ..imageUrl = chapter.imageUrl,
        );
      }
    }

    if (chapters.isNotEmpty) {
      await _chapterDatasource.upsertChapters(chapters);
    }
  }

  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {
    final withData = mediaMetas.where((m) => m.hasData);
    if (withData.isEmpty) return;

    // Resolve episode IDs by guid
    final guidToId = <String, int>{};
    for (final meta in withData) {
      final episode = await _datasource.getByPodcastIdAndGuid(
        podcastId,
        meta.guid,
      );
      if (episode != null) {
        guidToId[meta.guid] = episode.id;
      }
    }
    if (guidToId.isEmpty) return;

    // Store transcript metas
    if (_transcriptDatasource != null) {
      final transcriptMetas = <EpisodeTranscript>[];
      for (final meta in withData) {
        if (!meta.hasTranscripts) continue;
        final episodeId = guidToId[meta.guid];
        if (episodeId == null) continue;

        for (final t in meta.transcripts!) {
          transcriptMetas.add(
            EpisodeTranscript()
              ..episodeId = episodeId
              ..url = t.url
              ..type = t.type
              ..language = t.language
              ..rel = t.rel,
          );
        }
      }
      if (transcriptMetas.isNotEmpty) {
        await _transcriptDatasource.upsertMetas(transcriptMetas);
      }
    }

    // Store chapters
    if (_chapterDatasource != null) {
      final chapterEntities = <EpisodeChapter>[];
      for (final meta in withData) {
        if (!meta.hasChapters) continue;
        final episodeId = guidToId[meta.guid];
        if (episodeId == null) continue;

        for (final (index, c) in meta.chapters!.indexed) {
          chapterEntities.add(
            EpisodeChapter()
              ..episodeId = episodeId
              ..sortOrder = index
              ..title = c.title
              ..startMs = c.startTime.inMilliseconds
              ..url = c.url
              ..imageUrl = c.imageUrl,
          );
        }
      }
      if (chapterEntities.isNotEmpty) {
        await _chapterDatasource.upsertChapters(chapterEntities);
      }
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
