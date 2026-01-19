import 'package:audiflow_search/audiflow_search.dart' show StatusCode;

import 'package:audiflow_search/src/exceptions/status_code.dart'
    show StatusCode;

import '../exceptions/search_exception.dart';
import '../models/podcast.dart';

/// Parses iTunes Lookup API JSON responses into Podcast models.
///
/// This parser handles the transformation of raw JSON data from the iTunes
/// Lookup API endpoint into strongly-typed [Podcast] domain models.
class LookupResponseParser {
  static const String _providerId = 'itunes_lookup';

  /// Parses lookup API JSON response into a single podcast.
  ///
  /// Throws [SearchException] with [StatusCode.notFound] if:
  /// - `resultCount` is 0 (podcast not found)
  /// - `results` array is empty (podcast not found)
  ///
  /// Throws [SearchException] with [StatusCode.internal] if:
  /// - `resultCount` field is missing or invalid
  /// - `results` field is missing or not a list
  Podcast parseLookupResponse(Map<String, dynamic> json) {
    try {
      final resultCount = json['resultCount'];
      if (resultCount == null) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'Missing resultCount field in lookup response',
          details: {'json': json},
        );
      }

      final results = json['results'];
      if (results == null) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'Missing results array in lookup response',
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
        throw SearchException.notFound(
          providerId: _providerId,
          message: 'Podcast not found in lookup response',
          details: {
            'resultCount': resultCount,
            'resultsLength': results.length,
          },
        );
      }

      final firstResult = results[0];
      if (firstResult is! Map<String, dynamic>) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'First result item is not a valid JSON object',
          details: {'firstResult': firstResult},
        );
      }

      return Podcast.fromJson(firstResult);
    } catch (e) {
      if (e is SearchException) {
        rethrow;
      }
      throw SearchException.internal(
        providerId: _providerId,
        message: 'Failed to parse lookup response: $e',
        details: {'error': e.toString(), 'json': json},
      );
    }
  }
}
