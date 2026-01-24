import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../builders/podcast_builder.dart';
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

  /// Parses a podcast RSS feed from raw XML content.
  ///
  /// This is useful for testing or when the XML content is already available.
  Future<ParsedFeed> parseFromString(String xmlContent) async {
    _logger?.d('Parsing podcast feed from string content');

    final errors = <PodcastParseError>[];
    final warnings = <PodcastParseWarning>[];
    PodcastFeed? feed;
    final items = <PodcastItem>[];

    try {
      await for (final entity in _parser.parseFromString(xmlContent)) {
        if (entity is PodcastFeed) {
          feed = entity;
        } else if (entity is PodcastItem) {
          items.add(entity);
        } else if (entity is PodcastParseError) {
          errors.add(entity);
        } else if (entity is PodcastParseWarning) {
          warnings.add(entity);
        }
      }

      if (feed == null) {
        throw PodcastException.parsing(
          'No feed metadata found in XML content',
          sourceUrl: 'string',
        );
      }

      _logger?.i('Parsed feed: ${feed.title} with ${items.length} episodes');

      return ParsedFeed(
        podcast: feed,
        episodes: items,
        errors: errors,
        warnings: warnings,
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
  /// Calls [onBatchReady] when a batch of episodes is ready to store.
  ///
  /// - [xmlContent]: Raw XML content of the RSS feed
  /// - [podcastId]: Database ID for the podcast (used in companion objects)
  /// - [knownGuids]: Set of episode GUIDs already in the database
  /// - [onBatchReady]: Callback to persist a batch of episodes
  /// - [batchSize]: Number of episodes per batch (default: 20)
  Stream<FeedParseProgress> parseWithProgress({
    required String xmlContent,
    required int podcastId,
    required Set<String> knownGuids,
    required Future<void> Function(List<EpisodesCompanion> companions)
    onBatchReady,
    int batchSize = _defaultBatchSize,
  }) async* {
    _logger?.i('Starting isolate parse for podcast $podcastId');
    _logger?.d('Known GUIDs: ${knownGuids.length}');

    final buffer = <EpisodesCompanion>[];
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
          :final enclosureType,
          :final enclosureLength,
          :final publishDate,
          :final duration,
          :final episodeNumber,
          :final seasonNumber,
          :final imageUrl,
        ):
          buffer.add(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid:
                  guid ??
                  enclosureUrl ??
                  'unknown-${DateTime.now().millisecondsSinceEpoch}',
              title: title,
              description: Value(description),
              audioUrl: enclosureUrl ?? '',
              durationMs: Value(duration?.inMilliseconds),
              publishedAt: Value(publishDate),
              imageUrl: Value(imageUrl),
              episodeNumber: Value(episodeNumber),
              seasonNumber: Value(seasonNumber),
            ),
          );
          totalParsed++;

          if (batchSize <= buffer.length) {
            await onBatchReady(buffer.toList());
            buffer.clear();
            _logger?.d('Stored batch, total: $totalParsed');
            yield EpisodesBatchStored(totalSoFar: totalParsed);
          }

        case ParseComplete(:final stoppedEarly):
          // Flush remaining buffer
          if (buffer.isNotEmpty) {
            await onBatchReady(buffer.toList());
            buffer.clear();
          }

          _logger?.i(
            'Parse complete: $totalParsed episodes, stoppedEarly: $stoppedEarly',
          );
          yield FeedParseComplete(
            total: totalParsed,
            stoppedEarly: stoppedEarly,
          );
      }
    }
  }

  /// Disposes resources used by this service.
  void dispose() {
    _parser.dispose();
  }
}
