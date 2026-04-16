import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../builders/podcast_builder.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';

part 'feed_parser_service.g.dart';

/// Service for parsing podcast RSS feeds.
///
/// Uses [PodcastRssParser] to fetch and parse RSS feeds, returning structured
/// podcast data. The service handles caching, error handling, and logging.
///
/// Example usage:
/// ```dart
/// final service = ref.watch(feedParserServiceProvider);
/// final result = await service.parseFromUrl('https://example.com/feed.xml');
/// print('Found ${result.episodeCount} episodes');
/// ```
@riverpod
FeedParserService feedParserService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('FeedParser'));
  return FeedParserService(logger: logger);
}

class FeedParserService {
  final PodcastRssParser _parser;
  final DefaultPodcastBuilder _builder;
  final Logger? _logger;

  FeedParserService({
    PodcastRssParser? parser,
    DefaultPodcastBuilder? builder,
    Logger? logger,
  }) : _parser = parser ?? PodcastRssParser(logger: logger),
       _builder = builder ?? DefaultPodcastBuilder(logger: logger),
       _logger = logger;

  /// Parses a podcast RSS feed from the given URL.
  ///
  /// Returns a [ParsedFeed] containing the podcast metadata and episodes.
  ///
  /// The [cacheOptions] parameter controls caching behavior:
  /// - `ttl`: Time to live for cached content (default: 1 hour)
  /// - `useCache`: Whether to use cached content (default: true)
  ///
  /// Throws [PodcastException] if parsing fails completely.
  Future<ParsedFeed> parseFromUrl(
    String url, {
    CacheOptions? cacheOptions,
  }) async {
    _logger?.i('Parsing podcast feed from: $url');

    try {
      final result = await _parser.parseWithBuilder(
        url,
        builder: _builder,
        cacheOptions: cacheOptions ?? const CacheOptions(),
      );

      _logger?.i(
        'Parsed feed: ${result.feed.title} with ${result.items.length} episodes',
      );

      return ParsedFeed(
        podcast: result.feed,
        episodes: result.items,
        errors: result.errors,
        warnings: result.warnings,
      );
    } on StateError catch (e) {
      _logger?.e('Failed to parse feed from $url: $e');
      throw PodcastException.parsing(e.message, sourceUrl: url);
    } catch (e) {
      _logger?.e('Unexpected error parsing feed from $url: $e');
      throw PodcastException(
        message: 'Failed to parse podcast feed: $e',
        sourceUrl: url,
      );
    }
  }

  /// Parses a podcast RSS feed from raw XML content using isolate.
  ///
  /// This runs parsing in a background isolate to prevent UI freezes.
  /// Pass [knownNewestPubDate] and optionally [knownNewestGuid] to enable
  /// early-stop optimization: parsing stops when an episode at or before
  /// the cutoff date is encountered (confirmed by GUID match if provided).
  Future<ParsedFeed> parseFromString(
    String xmlContent, {
    DateTime? knownNewestPubDate,
    String? knownNewestGuid,
  }) async {
    _logger?.d(
      'Parsing feed from string (isolate), '
      'cutoff: $knownNewestPubDate, guid: $knownNewestGuid',
    );

    try {
      // Use isolate-based parsing to prevent UI freeze
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlContent,
        knownNewestPubDate: knownNewestPubDate,
        knownNewestGuid: knownNewestGuid,
      );

      _logger?.i(
        'Parsed feed: ${result.meta.title} '
        'with ${result.episodes.length} episodes, '
        'stoppedEarly: ${result.stoppedEarly}',
      );

      // Convert ParsedPodcastMeta to PodcastFeed
      final feed = PodcastFeed.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: '',
        title: result.meta.title,
        description: result.meta.description,
        author: result.meta.author,
        language: result.meta.language,
        images: result.meta.imageUrl != null
            ? [PodcastImage(url: result.meta.imageUrl!)]
            : [],
      );

      // Convert ParsedEpisode to PodcastItem
      final items = result.episodes
          .map(
            (e) => PodcastItem.fromData(
              parsedAt: DateTime.now(),
              sourceUrl: '',
              title: e.title,
              description: e.description ?? '',
              guid: e.guid,
              enclosureUrl: e.enclosureUrl,
              enclosureType: e.enclosureType,
              enclosureLength: e.enclosureLength,
              publishDate: e.publishDate,
              duration: e.duration,
              episodeNumber: e.episodeNumber,
              seasonNumber: e.seasonNumber,
              contentEncoded: e.contentEncoded,
              summary: e.summary,
              link: e.link,
              images: e.imageUrl != null
                  ? [PodcastImage(url: e.imageUrl!)]
                  : [],
              transcripts: e.transcripts
                  ?.map(
                    (t) => PodcastTranscript(
                      url: t.url,
                      type: t.type,
                      language: t.language,
                      rel: t.rel,
                    ),
                  )
                  .toList(),
              chapters: e.chapters
                  ?.map(
                    (c) => PodcastChapter(
                      title: c.title,
                      startTime: c.startTime,
                      url: c.url,
                      imageUrl: c.imageUrl,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      return ParsedFeed(
        podcast: feed,
        episodes: items,
        errors: const [],
        warnings: const [],
      );
    } catch (e) {
      if (e is PodcastException) rethrow;
      _logger?.e('Unexpected error parsing feed from string: $e');
      throw PodcastException(message: 'Failed to parse podcast feed: $e');
    }
  }

  static const _defaultBatchSize = 20;

  /// Parses XML content in isolate with progress streaming and batched storage.
  ///
  /// Emits [FeedParseProgress] events for UI updates.
  /// Calls [onBatchReady] when a batch of episodes is ready to store,
  /// passing both episodes and transcript/chapter metadata.
  ///
  /// - [xmlContent]: Raw XML content of the RSS feed
  /// - [podcastId]: Database ID for the podcast
  /// - [knownGuids]: Set of episode GUIDs already in the database
  /// - [onBatchReady]: Callback to persist episodes and media metadata
  /// - [batchSize]: Number of episodes per batch (default: 20)
  Stream<FeedParseProgress> parseWithProgress({
    required String xmlContent,
    required int podcastId,
    required Set<String> knownGuids,
    required Future<void> Function(
      List<Episode> episodes,
      List<ParsedEpisodeMediaMeta> mediaMetas,
    )
    onBatchReady,
    int batchSize = _defaultBatchSize,
  }) async* {
    _logger?.i('Starting isolate parse for podcast $podcastId');
    _logger?.d('Known GUIDs: ${knownGuids.length}');

    final buffer = <Episode>[];
    final mediaMetaBuffer = <ParsedEpisodeMediaMeta>[];
    var totalParsed = 0;

    await for (final progress in IsolateRssParser.parse(
      feedXml: xmlContent,
      knownGuids: knownGuids,
    )) {
      switch (progress) {
        case ParsedPodcastMeta(
          :final title,
          :final description,
          :final imageUrl,
          :final author,
        ):
          _logger?.d('Parsed metadata: $title');
          yield FeedMetaReady(
            title: title,
            description: description,
            imageUrl: imageUrl,
            author: author,
          );

        case ParsedEpisode(
          :final guid,
          :final title,
          :final description,
          :final enclosureUrl,
          :final publishDate,
          :final duration,
          :final episodeNumber,
          :final seasonNumber,
          :final imageUrl,
          :final contentEncoded,
          :final summary,
          :final link,
          :final transcripts,
          :final chapters,
        ):
          final resolvedGuid =
              guid ??
              enclosureUrl ??
              'unknown-${DateTime.now().millisecondsSinceEpoch}';
          buffer.add(
            Episode()
              ..podcastId = podcastId
              ..guid = resolvedGuid
              ..title = title
              ..description = description
              ..audioUrl = enclosureUrl ?? ''
              ..durationMs = duration?.inMilliseconds
              ..publishedAt = publishDate
              ..imageUrl = imageUrl
              ..episodeNumber = episodeNumber
              ..seasonNumber = seasonNumber
              ..contentEncoded = contentEncoded
              ..summary = summary
              ..link = link,
          );

          if (transcripts != null || chapters != null) {
            mediaMetaBuffer.add(
              ParsedEpisodeMediaMeta(
                guid: resolvedGuid,
                transcripts: transcripts,
                chapters: chapters,
              ),
            );
          }

          totalParsed++;

          if (batchSize <= buffer.length) {
            await onBatchReady(buffer.toList(), mediaMetaBuffer.toList());
            buffer.clear();
            mediaMetaBuffer.clear();
            _logger?.d('Stored batch, total: $totalParsed');
            yield EpisodesBatchStored(totalSoFar: totalParsed);
          }

        case ParseComplete(:final stoppedEarly, :final tailGuids):
          // Flush remaining buffer
          if (buffer.isNotEmpty) {
            await onBatchReady(buffer.toList(), mediaMetaBuffer.toList());
            buffer.clear();
            mediaMetaBuffer.clear();
          }

          _logger?.i(
            'Parse complete: $totalParsed episodes, '
            'stoppedEarly: $stoppedEarly, tailGuids: ${tailGuids.length}',
          );
          yield FeedParseComplete(
            total: totalParsed,
            stoppedEarly: stoppedEarly,
            tailGuids: tailGuids,
          );
      }
    }
  }

  /// Disposes resources used by this service.
  void dispose() {
    _parser.dispose();
  }
}
