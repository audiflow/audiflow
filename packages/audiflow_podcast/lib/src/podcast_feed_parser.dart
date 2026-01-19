import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';

import 'cache/cache_manager.dart';
import 'errors/podcast_parse_error.dart';
import 'models/podcast_entity.dart';
import 'models/podcast_feed.dart';
import 'models/podcast_item.dart';
import 'network/http_fetcher.dart';
import 'parser/podcast_entity_builder.dart';
import 'parser/streaming_xml_parser.dart';

/// The main entry point for the podcast RSS parser library.
///
/// Provides streaming RSS parsing capabilities for podcast feeds with
/// intelligent caching and error handling.
class PodcastRssParser {
  /// Creates a new instance of [PodcastRssParser].
  ///
  /// Optionally accepts custom [HttpFetcher], [CacheManager], and [Logger]
  /// instances for dependency injection and testing purposes.
  PodcastRssParser({
    HttpFetcher? httpFetcher,
    CacheManager? cacheManager,
    Logger? logger,
  }) : _httpFetcher = httpFetcher ?? HttpFetcher(),
       _cacheManager = cacheManager ?? CacheManager(),
       _logger = logger;
  final HttpFetcher _httpFetcher;
  final CacheManager _cacheManager;
  final Logger? _logger;

  /// Parses a podcast RSS feed from the given URL.
  ///
  /// Returns a stream of [PodcastEntity] objects (Feed and Item entities)
  /// as they are parsed from the RSS feed.
  ///
  /// The [url] parameter specifies the RSS feed URL to parse.
  /// The optional [cacheOptions] parameter controls caching behavior.
  Stream<PodcastEntity> parseFromUrl(
    String url, {
    CacheOptions? cacheOptions,
  }) async* {
    _logger?.d('Starting to parse RSS feed from URL: $url');
    try {
      // Validate URL
      final uri = Uri.tryParse(url);
      if (uri == null ||
          (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
        _logger?.w('Invalid URL format: $url');
        yield* Stream.error(
          NetworkError(
            parsedAt: DateTime.now(),
            sourceUrl: url,
            message: 'Invalid URL: $url',
            originalException: const FormatException('Invalid URL format'),
          ),
        );
        return;
      }

      final options = cacheOptions ?? const CacheOptions();

      // Try to get from cache if caching is enabled
      if (options.useCache) {
        try {
          final cachedFeed = await _cacheManager.getCachedFeed(url);
          if (cachedFeed != null && await _cacheManager.isCacheValid(url)) {
            _logger?.d('Using cached content for: $url');
            // Use cached content
            yield* parseFromStream(cachedFeed.getContentStream());
            return;
          }
        } catch (e) {
          _logger?.w('Cache read error for $url, falling back to network: $e');
          // Cache error, continue with network request
        }
      }

      // Fetch from network with integrated caching
      try {
        _logger?.d('Fetching RSS feed from network: $url');
        final networkStream = _httpFetcher.fetchStream(url);

        if (options.useCache) {
          // Cache during streaming to avoid double-fetching
          yield* _parseAndCacheFromStream(networkStream, url, options.ttl);
        } else {
          // Direct streaming without caching
          yield* parseFromStream(networkStream);
        }
      } catch (e) {
        _logger?.e('Network fetch failed for $url: $e');
        yield* Stream.error(
          NetworkError(
            parsedAt: DateTime.now(),
            sourceUrl: url,
            message: 'Failed to fetch RSS feed: $e',
            originalException: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    } catch (e) {
      _logger?.e('Unexpected error parsing from URL $url: $e');
      yield* Stream.error(
        XmlParsingError(
          parsedAt: DateTime.now(),
          sourceUrl: url,
          message: 'Unexpected error parsing from URL: $e',
          originalException: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Parses a podcast RSS feed from the given stream of bytes.
  ///
  /// Returns a stream of [PodcastEntity] objects as they are parsed.
  ///
  /// The [xmlStream] parameter provides the RSS feed content as a byte stream.
  Stream<PodcastEntity> parseFromStream(Stream<List<int>> xmlStream) async* {
    StreamingXmlParser? parser;
    late StreamController<PodcastEntity> controller;
    StreamSubscription? entitySubscription;

    try {
      parser = StreamingXmlParser();
      controller = StreamController<PodcastEntity>();

      // Forward entities from parser to controller
      entitySubscription = parser.entityStream.listen(
        (entity) => controller.add(entity),
        onError: (error) => controller.addError(
          error is PodcastParseError
              ? error
              : XmlParsingError(
                  parsedAt: DateTime.now(),
                  sourceUrl: 'stream',
                  message: 'Entity parsing error: $error',
                  originalException: error is Exception
                      ? error
                      : Exception(error.toString()),
                ),
        ),
        onDone: () => controller.close(),
      );

      // Start parsing with proper error handling
      try {
        await parser.parseXmlStream(xmlStream, sourceUrl: 'stream');
      } catch (e) {
        controller.addError(
          e is PodcastParseError
              ? e
              : XmlParsingError(
                  parsedAt: DateTime.now(),
                  sourceUrl: 'stream',
                  message: 'XML stream parsing error: $e',
                  originalException: e is Exception
                      ? e
                      : Exception(e.toString()),
                ),
        );
      }

      // Yield entities from the controller
      yield* controller.stream;
    } catch (e) {
      yield* Stream.error(
        e is PodcastParseError
            ? e
            : XmlParsingError(
                parsedAt: DateTime.now(),
                sourceUrl: 'stream',
                message: 'Stream setup error: $e',
                originalException: e is Exception ? e : Exception(e.toString()),
              ),
      );
    } finally {
      // Ensure proper cleanup
      await entitySubscription?.cancel();
      parser?.dispose();
      try {
        await controller.close();
      } catch (e) {
        // Controller might not be initialized if early failure
      }
    }
  }

  /// Parses a podcast RSS feed from the given XML string.
  ///
  /// Returns a stream of [PodcastEntity] objects as they are parsed.
  ///
  /// The [xmlContent] parameter contains the complete RSS feed as a string.
  Stream<PodcastEntity> parseFromString(String xmlContent) async* {
    try {
      if (xmlContent.trim().isEmpty) {
        yield* Stream.error(
          XmlParsingError(
            parsedAt: DateTime.now(),
            sourceUrl: 'string',
            message: 'XML content is empty',
          ),
        );
        return;
      }

      // Convert string to byte stream
      final bytes = utf8.encode(xmlContent);
      final byteStream = Stream.value(bytes);

      yield* parseFromStream(byteStream);
    } catch (e) {
      yield* Stream.error(
        e is PodcastParseError
            ? e
            : XmlParsingError(
                parsedAt: DateTime.now(),
                sourceUrl: 'string',
                message: 'Error parsing from string: $e',
                originalException: e is Exception ? e : Exception(e.toString()),
              ),
      );
    }
  }

  /// Parse from stream while simultaneously caching the content.
  ///
  /// This avoids double-fetching by caching during the streaming process.
  Stream<PodcastEntity> _parseAndCacheFromStream(
    Stream<List<int>> networkStream,
    String url,
    Duration ttl,
  ) async* {
    final cacheBuffer = <int>[];
    StreamController<List<int>>? parsingController;
    StreamSubscription? networkSubscription;

    try {
      parsingController = StreamController<List<int>>();

      // Tee the network stream: one for parsing, one for caching
      networkSubscription = networkStream.listen(
        (chunk) {
          // Send to parser
          if (!parsingController!.isClosed) {
            parsingController.add(chunk);
          }
          // Accumulate for cache
          cacheBuffer.addAll(chunk);
        },
        onError: (Object error) {
          if (!parsingController!.isClosed) {
            parsingController.addError(error);
          }
        },
        onDone: () {
          if (!parsingController!.isClosed) {
            parsingController.close();
          }
          // Cache the accumulated content in background
          _cacheManager.cacheFeed(url, cacheBuffer, ttl).catchError((error) {
            _logger?.w('Cache write failed for $url: $error');
            // Caching failed, but parsing succeeded - this is acceptable
          });
        },
      );

      // Parse from the teed stream
      yield* parseFromStream(parsingController.stream);
    } catch (e) {
      rethrow;
    } finally {
      await networkSubscription?.cancel();
      if (parsingController != null && !parsingController.isClosed) {
        await parsingController.close();
      }
    }
  }

  /// Parses a podcast RSS feed using a builder for zero-copy entity construction.
  ///
  /// This method allows consumers to construct their own entity types (e.g., Drift
  /// database companions) directly from raw XML data, without creating intermediate
  /// parser-specific model objects.
  ///
  /// The [url] parameter specifies the RSS feed URL to parse.
  /// The [builder] parameter provides callbacks for constructing entities.
  /// The optional [cacheOptions] parameter controls caching behavior.
  ///
  /// Returns a [ParsedPodcastResult] containing the constructed entities.
  ///
  /// Example:
  /// ```dart
  /// final result = await parser.parseWithBuilder(
  ///   'https://example.com/feed.xml',
  ///   builder: myDriftBuilder,
  /// );
  /// print('Parsed ${result.items.length} episodes');
  /// ```
  Future<ParsedPodcastResult<TFeed, TItem>> parseWithBuilder<TFeed, TItem>(
    String url, {
    required PodcastEntityBuilder<TFeed, TItem> builder,
    CacheOptions? cacheOptions,
  }) async {
    _logger?.d('Starting builder-based parsing from URL: $url');

    final errors = <PodcastParseError>[];
    final warnings = <PodcastParseWarning>[];
    final items = <TItem>[];
    TFeed? feed;

    try {
      await for (final entity in parseFromUrl(
        url,
        cacheOptions: cacheOptions,
      )) {
        if (entity is PodcastFeed) {
          // Convert PodcastFeed to raw data map and call builder
          final feedData = _feedToMap(entity);
          feed = builder.buildFeed(feedData, url);
        } else if (entity is PodcastItem) {
          // Convert PodcastItem to raw data map and call builder
          final itemData = _itemToMap(entity);
          items.add(builder.buildItem(itemData, url));
        } else if (entity is PodcastParseError) {
          errors.add(entity);
          builder.onError(entity);
        } else if (entity is PodcastParseWarning) {
          warnings.add(entity);
          builder.onWarning(entity);
        }
      }
    } catch (e) {
      _logger?.e('Builder parsing failed for $url: $e');
      final error = e is PodcastParseError
          ? e
          : NetworkError(
              parsedAt: DateTime.now(),
              sourceUrl: url,
              message: 'Builder parsing failed: $e',
              originalException: e is Exception ? e : Exception(e.toString()),
            );
      errors.add(error);
      builder.onError(error);
    }

    if (feed == null) {
      final error = XmlParsingError(
        parsedAt: DateTime.now(),
        sourceUrl: url,
        message: 'No feed metadata found in RSS feed',
      );
      builder.onError(error);
      throw StateError('No feed metadata found in RSS feed at $url');
    }

    return ParsedPodcastResult(
      feed: feed,
      items: items,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Convert PodcastFeed back to raw data map for builder.
  Map<String, dynamic> _feedToMap(PodcastFeed feed) {
    return {
      'title': feed.title,
      'description': feed.description,
      'link': feed.link,
      'language': feed.language,
      'copyright': feed.copyright,
      'lastBuildDate': feed.lastBuildDate,
      'pubDate': feed.pubDate,
      'generator': feed.generator,
      'managingEditor': feed.managingEditor,
      'webMaster': feed.webMaster,
      'ttl': feed.ttl,
      'itunesAuthor': feed.author,
      'itunesSubtitle': feed.subtitle,
      'itunesSummary': feed.summary,
      'itunesExplicit': feed.isExplicit,
      'itunesType': feed.type,
      'itunesComplete': feed.isComplete,
      'itunesNewFeedUrl': feed.newFeedUrl,
      'itunesOwner': feed.hasOwnerInfo
          ? {'name': feed.ownerName, 'email': feed.ownerEmail}
          : null,
      'categories': feed.categories,
      'images': feed.images
          .map(
            (img) => {
              'url': img.url,
              'width': img.width,
              'height': img.height,
              'title': img.title,
            },
          )
          .toList(),
    };
  }

  /// Convert PodcastItem back to raw data map for builder.
  Map<String, dynamic> _itemToMap(PodcastItem item) {
    return {
      'title': item.title,
      'description': item.description,
      'link': item.link,
      'guid': item.guid,
      'guidIsPermaLink': item.isPermaLink,
      'pubDate': item.publishDate,
      'author': item.author,
      'comments': item.comments,
      'source': item.source,
      'contentEncoded': item.contentEncoded,
      'categories': item.categories,
      'enclosure': item.enclosureUrl != null
          ? {
              'url': item.enclosureUrl,
              'type': item.enclosureType,
              'length': item.enclosureLength,
            }
          : null,
      'itunesTitle': item.title,
      'itunesSubtitle': item.subtitle,
      'itunesSummary': item.summary,
      'itunesAuthor': item.author,
      'itunesDuration': item.duration,
      'itunesExplicit': item.isExplicit,
      'itunesImage': item.images.isNotEmpty ? item.images.first.url : null,
      'itunesEpisode': item.episodeNumber,
      'itunesSeason': item.seasonNumber,
      'itunesEpisodeType': item.episodeType,
      'chapters': item.chapters
          ?.map(
            (ch) => {
              'startTime': ch.startTime.inMilliseconds,
              'title': ch.title,
              'url': ch.url,
              'imageUrl': ch.imageUrl,
            },
          )
          .toList(),
      'transcripts': item.transcripts
          ?.map(
            (tr) => {
              'url': tr.url,
              'type': tr.type,
              'language': tr.language,
              'rel': tr.rel,
            },
          )
          .toList(),
    };
  }

  /// Dispose resources used by this parser.
  ///
  /// Should be called when the parser is no longer needed to free up resources.
  /// After disposal, the parser can still be used as new instances will be created.
  void dispose() {
    _httpFetcher.dispose();
    // Note: CacheManager doesn't need disposal as it uses file system operations
    // StreamingXmlParser instances are disposed per-parsing session
  }
}

/// Options for controlling cache behavior when parsing RSS feeds.
class CacheOptions {
  const CacheOptions({
    this.ttl = const Duration(hours: 1),
    this.useCache = true,
    this.maxCacheSize,
  });

  /// Time to live for cached content.
  final Duration ttl;

  /// Whether to use cached content if available.
  final bool useCache;

  /// Maximum size for the cache in bytes.
  final int? maxCacheSize;
}
