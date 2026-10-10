import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../transcript/datasources/local/chapter_local_datasource.dart';
import '../../transcript/datasources/local/transcript_local_datasource.dart';
import '../../transcript/models/chapter_source.dart';
import '../../transcript/models/episode_chapter.dart';
import '../../transcript/models/episode_transcript.dart';
import '../../transcript/models/json_chapters_link.dart';
import '../../transcript/services/chapter_mapping.dart';
import '../datasources/local/episode_local_datasource.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/numbering_extractor.dart';
import '../models/preset_config.dart';
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
    required this._datasource,
    this._transcriptDatasource,
    this._chapterDatasource,
  });

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
    NumberingExtractor? extractor,
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
        ..seasonNumber = seasonNumber
        ..contentEncoded = item.contentEncoded
        ..summary = item.summary
        ..link = item.link
        ..chaptersUrl = item.chaptersLink?.url
        ..chaptersType = item.chaptersLink?.type
        ..itunesExplicit = item.isExplicit ?? false;
    }).toList();

    await _datasource.upsertAll(episodes);
    await _storeTranscriptAndChapterData(podcastId, validItems);
  }

  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required PresetConfig config,
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
        ..seasonNumber = seasonNumber
        ..contentEncoded = item.contentEncoded
        ..summary = item.summary
        ..link = item.link
        ..chaptersUrl = item.chaptersLink?.url
        ..chaptersType = item.chaptersLink?.type
        ..itunesExplicit = item.isExplicit ?? false;
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
    // Derived by the isolate parser, off the UI isolate.
    final derivedByKey = {
      for (final item in items)
        if (item.descriptionChapters.isNotEmpty)
          _podcastItemKey(item): item.descriptionChapters,
    };

    if (hasTranscriptItems.isEmpty &&
        hasChapterItems.isEmpty &&
        derivedByKey.isEmpty) {
      return;
    }

    // Resolve episode IDs for items that need transcript/chapter storage
    final itemsNeedingLookup = {
      for (final item in [...hasTranscriptItems, ...hasChapterItems])
        _podcastItemKey(item): item,
      for (final item in items)
        if (derivedByKey.containsKey(_podcastItemKey(item)))
          _podcastItemKey(item): item,
    };

    final keyToId = <String, int>{};
    for (final MapEntry(:key, value: item) in itemsNeedingLookup.entries) {
      final episode = await _datasource.getByFeedItem(
        podcastId,
        item.guid!,
        item.enclosureUrl!,
      );
      if (episode != null) {
        keyToId[key] = episode.id;
      }
    }

    if (keyToId.isEmpty) return;

    await _storeTranscriptMetas(hasTranscriptItems, keyToId);
    await _storeChapters(hasChapterItems, keyToId);
    await _storeDescriptionChapters(derivedByKey, keyToId);
  }

  /// Identifies a feed item by guid and enclosure URL, since a feed may
  /// reuse one guid for several items.
  static String _feedItemKey(String guid, String audioUrl) =>
      duplicateGuidKey(guid, audioUrl);

  static String _podcastItemKey(PodcastItem item) =>
      _feedItemKey(item.guid!, item.enclosureUrl!);

  /// Stores chapters derived from show notes, keyed by feed item key.
  Future<void> _storeDescriptionChapters(
    Map<String, List<PodcastChapter>> chaptersByKey,
    Map<String, int> keyToId,
  ) async {
    final rows = <int, List<EpisodeChapter>>{};
    for (final MapEntry(:key, value: chapters) in chaptersByKey.entries) {
      final episodeId = keyToId[key];
      if (episodeId == null) continue;
      rows[episodeId] = toEpisodeChapters(episodeId, chapters);
    }
    await _storeChapterRows(rows, ChapterSource.description);
  }

  /// Builds and upserts transcript metadata.
  Future<void> _storeTranscriptMetas(
    Iterable<PodcastItem> items,
    Map<String, int> keyToId,
  ) async {
    if (_transcriptDatasource == null) return;

    final metas = <EpisodeTranscript>[];
    for (final item in items) {
      final episodeId = keyToId[_podcastItemKey(item)];
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
    Map<String, int> keyToId,
  ) async {
    if (_chapterDatasource == null) return;

    final chaptersByEpisode = <int, List<EpisodeChapter>>{};
    for (final item in items) {
      final episodeId = keyToId[_podcastItemKey(item)];
      if (episodeId == null) continue;
      chaptersByEpisode[episodeId] = [
        for (final (index, chapter) in item.chapters!.indexed)
          EpisodeChapter()
            ..episodeId = episodeId
            ..sortOrder = index
            ..title = chapter.title
            ..startMs = chapter.startTime.inMilliseconds
            ..endMs = chapter.endTime?.inMilliseconds
            ..url = chapter.url
            ..imageUrl = chapter.imageUrl,
      ];
    }
    await _storeChapterRows(chaptersByEpisode, ChapterSource.podlove);
  }

  /// Stores chapters from [source], keeping any higher-priority chapters
  /// (such as `<podcast:chapters>` JSON) already stored.
  Future<void> _storeChapterRows(
    Map<int, List<EpisodeChapter>> chaptersByEpisode,
    ChapterSource source,
  ) async {
    if (_chapterDatasource == null || chaptersByEpisode.isEmpty) return;
    await _chapterDatasource.replaceChapters(
      chaptersByEpisode,
      source: source,
      linkedJsonUrls: await _linkedJsonUrls(chaptersByEpisode.keys),
    );
  }

  /// Each episode's current JSON chapters link, read after the episodes were
  /// upserted, so a re-import that drops or changes the link can store the
  /// feed's own chapters over the stale JSON ones.
  Future<Map<int, String?>> _linkedJsonUrls(Iterable<int> episodeIds) async {
    return {
      for (final id in episodeIds)
        id: (await _datasource.getById(id))?.jsonChaptersUrl,
    };
  }

  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {
    final withData = mediaMetas.where((m) => m.hasData);
    if (withData.isEmpty) return;

    // Resolve episode IDs by guid and audio URL
    String keyOf(ParsedEpisodeMediaMeta meta) =>
        _feedItemKey(meta.guid, meta.audioUrl);
    final keyToId = <String, int>{};
    for (final meta in withData) {
      final episode = await _datasource.getByFeedItem(
        podcastId,
        meta.guid,
        meta.audioUrl,
      );
      if (episode != null) {
        keyToId[keyOf(meta)] = episode.id;
      }
    }
    if (keyToId.isEmpty) return;

    // Store transcript metas
    if (_transcriptDatasource != null) {
      final transcriptMetas = <EpisodeTranscript>[];
      for (final meta in withData) {
        if (!meta.hasTranscripts) continue;
        final episodeId = keyToId[keyOf(meta)];
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

    final chaptersByEpisode = <int, List<EpisodeChapter>>{};
    for (final meta in withData) {
      if (!meta.hasChapters) continue;
      final episodeId = keyToId[keyOf(meta)];
      if (episodeId == null) continue;
      chaptersByEpisode[episodeId] = [
        for (final (index, c) in meta.chapters!.indexed)
          EpisodeChapter()
            ..episodeId = episodeId
            ..sortOrder = index
            ..title = c.title
            ..startMs = c.startTime.inMilliseconds
            ..url = c.url
            ..imageUrl = c.imageUrl,
      ];
    }
    await _storeChapterRows(chaptersByEpisode, ChapterSource.podlove);
    await _storeDescriptionChapters({
      for (final meta in withData)
        if (meta.hasDescriptionChapters) keyOf(meta): meta.descriptionChapters,
    }, keyToId);
  }

  @override
  Future<Map<String, String>> getAudioUrlsByGuid(int podcastId) {
    return _datasource.getAudioUrlsByGuid(podcastId);
  }

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) {
    return _datasource.getNewestByPodcastId(podcastId);
  }

  @override
  Future<List<Episode>> getByIds(List<int> ids) {
    return _datasource.getByIds(ids);
  }

  @override
  Future<int> deleteByPodcastIdAndGuids(int podcastId, Set<String> guids) {
    return _datasource.deleteByPodcastIdAndGuids(podcastId, guids);
  }

  @override
  Future<List<Episode>> getPendingAutoDownloadByPodcastId(int podcastId) {
    return _datasource.getPendingAutoDownloadByPodcastId(podcastId);
  }

  @override
  Future<void> markAutoDownloadEnqueued(Iterable<int> ids) {
    return _datasource.markAutoDownloadEnqueued(ids);
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
