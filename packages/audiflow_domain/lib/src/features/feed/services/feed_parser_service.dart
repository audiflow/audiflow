import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../builders/podcast_builder.dart';

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
  return FeedParserService();
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

  /// Disposes resources used by this service.
  void dispose() {
    _parser.dispose();
  }
}
