import 'dart:convert';

import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../exceptions/search_exception.dart';
import '../models/podcast.dart';
import '../models/search_query.dart';
import '../parsers/search_response_parser.dart';
import '../utils/http_client.dart';

/// Client for interacting with the iTunes Search API.
///
/// This client handles keyword-based podcast search by constructing
/// properly formatted requests to the iTunes Search API endpoint and
/// parsing the responses.
class ItunesSearchClient {
  /// Creates an iTunes search client.
  ///
  /// Optionally accepts custom [httpClient] and [parser] for testing.
  ItunesSearchClient({
    HttpClient? httpClient,
    SearchResponseParser? parser,
  }) : _httpClient =
           httpClient ??
           HttpClient(
             providerId: 'itunes_search',
           ),
       _parser = parser ?? SearchResponseParser();
  final HttpClient _httpClient;
  final SearchResponseParser _parser;

  static const String baseUrl = 'https://itunes.apple.com/search';

  /// Constructs a search URL from the given query parameters.
  String buildSearchUrl(SearchQuery query) {
    final params = <String, String>{};

    // Required parameters
    params['term'] = Uri.encodeQueryComponent(query.term);
    params['media'] = 'podcast';
    params['entity'] = 'podcast';

    // Optional standard parameters
    if (query.country != null) {
      params['country'] = query.country!;
    }

    if (query.language != null) {
      params['lang'] = query.language!;
    }

    if (query.limit != null) {
      params['limit'] = query.limit.toString();
    }

    if (query.attribute != null) {
      params['attribute'] = Uri.encodeQueryComponent(query.attribute!);
    }

    if (query.explicit != null) {
      params['explicit'] = query.explicit! ? 'Yes' : 'No';
    }

    // Custom parameters (added last)
    if (query.customParams != null) {
      for (final entry in query.customParams!.entries) {
        params[entry.key] = Uri.encodeQueryComponent(entry.value);
      }
    }

    // Build query string
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  /// Performs a podcast search with the given query parameters.
  ///
  /// Returns a list of [Podcast] objects matching the search criteria.
  ///
  /// Throws:
  /// - [ContentNotModifiedException] if content hasn't changed (304 response)
  /// - [RateLimitException] if rate limit is exceeded (429 response)
  /// - [SearchNetworkException] on network failures or timeouts
  /// - [SearchApiException] on other API errors
  Future<List<Podcast>> search(SearchQuery query) async {
    try {
      final url = buildSearchUrl(query);

      final response = await _httpClient.get(
        url,
        ifModifiedSince: query.ifModifiedSince,
        ifNoneMatch: query.ifNoneMatch,
      );

      final rawData = response.data;
      final Map<String, dynamic> data;

      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw SearchException.invalidArgument(
          providerId: 'itunes',
          message: 'Response data is not a valid JSON object',
          details: {'dataType': rawData.runtimeType.toString()},
        );
      }

      return _parser.parseSearchResponse(data);
    } on SearchException {
      rethrow;
    } catch (e) {
      throw SearchException.invalidArgument(
        providerId: 'itunes',
        message: 'Unexpected error during search: $e',
        details: {'error': e.toString()},
      );
    }
  }

  /// Performs a podcast search using a builder for zero-copy construction.
  ///
  /// Returns a [SearchEntityResult] containing the constructed entities.
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) async {
    try {
      final url = buildSearchUrl(query);

      final response = await _httpClient.get(
        url,
        ifModifiedSince: query.ifModifiedSince,
        ifNoneMatch: query.ifNoneMatch,
      );

      final rawData = response.data;
      final Map<String, dynamic> data;

      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        final error = SearchException.invalidArgument(
          providerId: 'itunes',
          message: 'Response data is not a valid JSON object',
          details: {'dataType': rawData.runtimeType.toString()},
        );
        builder.onError(error);
        return SearchEntityResult(
          podcasts: <T>[],
          totalCount: 0,
          provider: 'itunes',
          timestamp: DateTime.now(),
          errors: [error],
        );
      }

      final result = _parser.parseSearchResponseWithBuilder(
        data,
        builder: builder,
        provider: 'itunes',
      );

      return SearchEntityResult(
        podcasts: result.podcasts,
        totalCount: result.totalCount,
        provider: result.provider,
        timestamp: result.timestamp,
        etag: response.headers.value('ETag'),
        lastModified: response.headers.value('Last-Modified'),
        errors: result.errors,
        warnings: result.warnings,
      );
    } on SearchException catch (e) {
      builder.onError(e);
      return SearchEntityResult(
        podcasts: <T>[],
        totalCount: 0,
        provider: 'itunes',
        timestamp: DateTime.now(),
        errors: [e],
      );
    } on Object catch (e) {
      final error = SearchException.invalidArgument(
        providerId: 'itunes',
        message: 'Unexpected error during search: $e',
        details: {'error': e.toString()},
      );
      builder.onError(error);
      return SearchEntityResult(
        podcasts: <T>[],
        totalCount: 0,
        provider: 'itunes',
        timestamp: DateTime.now(),
        errors: [error],
      );
    }
  }

  /// Closes the client and cleans up resources.
  void close() {
    _httpClient.close();
  }
}
