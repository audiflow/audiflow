import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../exceptions/search_exception.dart';
import '../models/charts_query.dart';
import '../models/podcast.dart';
import '../parsers/feed_response_parser.dart';
import '../parsers/lookup_response_parser.dart';
import '../utils/http_client.dart';

/// Client for iTunes charts RSS feed retrieval and podcast detail lookups.
///
/// This client handles the two-step process of retrieving podcast charts:
/// 1. Fetch RSS feed to get podcast IDs
/// 2. Lookup each podcast ID for detailed information
class ItunesChartsClient {
  /// Creates a new iTunes charts client.
  ItunesChartsClient({
    HttpClient? httpClient,
    FeedResponseParser? feedParser,
    LookupResponseParser? lookupParser,
  }) : _httpClient =
           httpClient ??
           HttpClient(
             timeout: const Duration(seconds: 15),
             providerId: 'itunes_charts',
           ),
       _feedParser = feedParser ?? FeedResponseParser(),
       _lookupParser = lookupParser ?? LookupResponseParser();
  final HttpClient _httpClient;
  final FeedResponseParser _feedParser;
  final LookupResponseParser _lookupParser;

  static const String rssBaseUrl = 'https://itunes.apple.com';
  static const String lookupBaseUrl = 'https://itunes.apple.com/lookup';

  /// Constructs RSS feed URL for charts.
  String buildChartsUrl(ChartsQuery query) {
    final pathSegments = <String>[query.country, 'rss', 'toppodcasts'];

    if (query.limit != null) {
      pathSegments.add('limit=${query.limit}');
    }

    if (query.genre != null) {
      pathSegments.add('genre=${query.genre!.genreId}');
    }

    if (query.explicit != null) {
      final explicitValue = query.explicit! ? 'Yes' : 'No';
      pathSegments.add('explicit=$explicitValue');
    }

    pathSegments.add('json');

    return '$rssBaseUrl/${pathSegments.join('/')}';
  }

  /// Fetches top podcast charts.
  ///
  /// Returns empty list if feed retrieval fails, feed contains no entries,
  /// or all lookups fail.
  Future<List<Podcast>> fetchTopCharts(ChartsQuery query) async {
    final url = buildChartsUrl(query);

    final response = await _httpClient.get(
      url,
      ifModifiedSince: query.ifModifiedSince,
      ifNoneMatch: query.ifNoneMatch,
    );

    final podcastIds = _feedParser.extractPodcastIds(
      response.data as Map<String, dynamic>,
    );

    if (podcastIds.isEmpty) {
      return [];
    }

    final podcasts = <Podcast>[];
    for (final podcastId in podcastIds) {
      final podcast = await lookupPodcast(podcastId);
      if (podcast != null) {
        podcasts.add(podcast);
      }
    }

    return podcasts;
  }

  /// Fetches top podcast charts using a builder for zero-copy construction.
  Future<SearchEntityResult<T>> fetchTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) async {
    final errors = <SearchException>[];
    final warnings = <String>[];
    final podcasts = <T>[];

    try {
      final url = buildChartsUrl(query);

      final response = await _httpClient.get(
        url,
        ifModifiedSince: query.ifModifiedSince,
        ifNoneMatch: query.ifNoneMatch,
      );

      final podcastIds = _feedParser.extractPodcastIds(
        response.data as Map<String, dynamic>,
      );

      if (podcastIds.isEmpty) {
        return SearchEntityResult(
          podcasts: podcasts,
          totalCount: 0,
          provider: 'itunes',
          timestamp: DateTime.now(),
          etag: response.headers.value('ETag'),
          lastModified: response.headers.value('Last-Modified'),
          errors: errors,
          warnings: warnings,
        );
      }

      for (final podcastId in podcastIds) {
        try {
          final podcast = await lookupPodcast(podcastId);
          if (podcast != null) {
            final entity = builder.buildPodcast(podcast.toBuilderData());
            podcasts.add(entity);
          } else {
            final warning = 'Failed to lookup podcast with ID: $podcastId';
            warnings.add(warning);
            builder.onWarning(warning, context: {'podcastId': podcastId});
          }
        } on SearchException catch (e) {
          errors.add(e);
          builder.onError(e);
        } on Object catch (e) {
          final warning = 'Error looking up podcast $podcastId: $e';
          warnings.add(warning);
          builder.onWarning(
            warning,
            context: {'podcastId': podcastId, 'error': e.toString()},
          );
        }
      }

      return SearchEntityResult(
        podcasts: podcasts,
        totalCount: podcastIds.length,
        provider: 'itunes',
        timestamp: DateTime.now(),
        etag: response.headers.value('ETag'),
        lastModified: response.headers.value('Last-Modified'),
        errors: errors,
        warnings: warnings,
      );
    } on SearchException catch (e) {
      errors.add(e);
      builder.onError(e);
      return SearchEntityResult(
        podcasts: podcasts,
        totalCount: 0,
        provider: 'itunes',
        timestamp: DateTime.now(),
        errors: errors,
        warnings: warnings,
      );
    } on Object catch (e) {
      final error = SearchException.internal(
        providerId: 'itunes_charts',
        message: 'Unexpected error fetching charts: $e',
        details: {'error': e.toString()},
      );
      errors.add(error);
      builder.onError(error);
      return SearchEntityResult(
        podcasts: podcasts,
        totalCount: 0,
        provider: 'itunes',
        timestamp: DateTime.now(),
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Looks up podcast details by ID.
  ///
  /// Returns null if lookup fails (allows partial results).
  Future<Podcast?> lookupPodcast(String podcastId) async {
    try {
      final url = '$lookupBaseUrl?id=$podcastId';
      final response = await _httpClient.get(url);
      return _lookupParser.parseLookupResponse(
        response.data as Map<String, dynamic>,
      );
    } on Object {
      // Return null for failed lookups to allow partial results
      return null;
    }
  }

  /// Closes the client and cleans up resources.
  void close() {
    _httpClient.close();
  }
}
