import 'package:audiflow_search/audiflow_search.dart' show StatusCode;

import 'package:audiflow_search/src/exceptions/status_code.dart'
    show StatusCode;

import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../exceptions/search_exception.dart';
import '../models/podcast.dart';

/// Parses iTunes Search API JSON responses into Podcast models.
///
/// This parser handles the transformation of raw JSON data from the iTunes
/// Search API endpoint into strongly-typed [Podcast] domain models.
class SearchResponseParser {
  static const String _providerId = 'itunes_search';

  /// Parses search API JSON response into a list of podcasts.
  ///
  /// Throws [SearchException] with [StatusCode.internal] if:
  /// - `resultCount` field is missing or invalid
  /// - `results` field is missing or not a list
  List<Podcast> parseSearchResponse(Map<String, dynamic> json) {
    try {
      final resultCount = json['resultCount'];
      if (resultCount == null) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'Missing resultCount field in search response',
          details: {'json': json},
        );
      }

      final results = json['results'];
      if (results == null) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'Missing results array in search response',
          details: {'json': json},
        );
      }

      if (results is! List) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'results field is not a list',
          details: {'json': json, 'resultsType': results.runtimeType},
        );
      }

      if (resultCount == 0 || results.isEmpty) {
        return [];
      }

      return results.map((item) {
        if (item is! Map<String, dynamic>) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'Podcast item is not a valid JSON object',
            details: {'item': item},
          );
        }
        return Podcast.fromJson(item);
      }).toList();
    } catch (e) {
      if (e is SearchException) {
        rethrow;
      }
      throw SearchException.internal(
        providerId: _providerId,
        message: 'Failed to parse search response: $e',
        details: {'error': e.toString(), 'json': json},
      );
    }
  }

  /// Parses search API JSON response using a builder for zero-copy construction.
  ///
  /// This method allows consumers to construct their own entity types
  /// directly from the parsed JSON data.
  SearchEntityResult<T> parseSearchResponseWithBuilder<T>(
    Map<String, dynamic> json, {
    required PodcastSearchEntityBuilder<T> builder,
    required String provider,
  }) {
    final errors = <SearchException>[];
    final warnings = <String>[];
    final podcasts = <T>[];

    try {
      final resultCount = json['resultCount'];
      if (resultCount == null) {
        final error = SearchException.internal(
          providerId: _providerId,
          message: 'Missing resultCount field in search response',
          details: {'json': json},
        );
        errors.add(error);
        builder.onError(error);
        return SearchEntityResult(
          podcasts: podcasts,
          totalCount: 0,
          provider: provider,
          timestamp: DateTime.now(),
          errors: errors,
          warnings: warnings,
        );
      }

      final results = json['results'];
      if (results == null) {
        final error = SearchException.internal(
          providerId: _providerId,
          message: 'Missing results array in search response',
          details: {'json': json},
        );
        errors.add(error);
        builder.onError(error);
        return SearchEntityResult(
          podcasts: podcasts,
          totalCount: resultCount as int? ?? 0,
          provider: provider,
          timestamp: DateTime.now(),
          errors: errors,
          warnings: warnings,
        );
      }

      if (results is! List) {
        final error = SearchException.internal(
          providerId: _providerId,
          message: 'results field is not a list',
          details: {'json': json, 'resultsType': results.runtimeType},
        );
        errors.add(error);
        builder.onError(error);
        return SearchEntityResult(
          podcasts: podcasts,
          totalCount: resultCount as int? ?? 0,
          provider: provider,
          timestamp: DateTime.now(),
          errors: errors,
          warnings: warnings,
        );
      }

      for (final item in results) {
        if (item is! Map<String, dynamic>) {
          const warning = 'Podcast item is not a valid JSON object';
          warnings.add(warning);
          builder.onWarning(warning, context: {'item': item});
          continue;
        }

        try {
          // Parse to Podcast first to validate and normalize data
          final podcast = Podcast.fromJson(item);
          // Build using the builder interface
          final entity = builder.buildPodcast(podcast.toBuilderData());
          podcasts.add(entity);
        } catch (e) {
          if (e is SearchException) {
            errors.add(e);
            builder.onError(e);
          } else {
            final warning = 'Failed to parse podcast item: $e';
            warnings.add(warning);
            builder.onWarning(
              warning,
              context: {'item': item, 'error': e.toString()},
            );
          }
        }
      }

      return SearchEntityResult(
        podcasts: podcasts,
        totalCount: resultCount as int? ?? podcasts.length,
        provider: provider,
        timestamp: DateTime.now(),
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      if (e is SearchException) {
        errors.add(e);
        builder.onError(e);
      } else {
        final error = SearchException.internal(
          providerId: _providerId,
          message: 'Failed to parse search response: $e',
          details: {'error': e.toString()},
        );
        errors.add(error);
        builder.onError(error);
      }

      return SearchEntityResult(
        podcasts: podcasts,
        totalCount: 0,
        provider: provider,
        timestamp: DateTime.now(),
        errors: errors,
        warnings: warnings,
      );
    }
  }
}
