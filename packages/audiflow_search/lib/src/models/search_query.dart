import 'package:audiflow_search/audiflow_search.dart' show StatusCode;
import 'package:audiflow_search/src/exceptions/status_code.dart'
    show StatusCode;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/search_exception.dart';

part 'search_query.freezed.dart';

/// Immutable value object representing podcast search parameters.
///
/// This class validates all search parameters according to iTunes Search API
/// requirements and provides type-safe access to search options.
///
/// Use the [SearchQuery.validated] factory for construction with validation.
///
/// Example:
/// ```dart
/// final query = SearchQuery.validated(
///   term: 'technology podcasts',
///   country: 'us',
///   language: 'en_us',
///   limit: 50,
/// );
/// ```
@freezed
abstract class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    /// The search term for finding podcasts (required, non-empty).
    required String term,

    /// ISO 3166-1 alpha-2 country code (2 lowercase letters).
    String? country,

    /// Language code in format `{lang}_{country}` (both lowercase).
    String? language,

    /// Maximum number of search results to return (1-200 inclusive).
    int? limit,

    /// Search attribute to filter by specific fields.
    String? attribute,

    /// Whether to include explicit content in results.
    bool? explicit,

    /// Custom query parameters to append to the API request.
    Map<String, String>? customParams,

    /// HTTP If-Modified-Since header value for conditional requests.
    String? ifModifiedSince,

    /// HTTP If-None-Match header value for conditional requests.
    String? ifNoneMatch,
  }) = _SearchQuery;
  const SearchQuery._();

  /// Creates a validated search query with the given parameters.
  ///
  /// Validates all parameters and throws [SearchException] with
  /// [StatusCode.invalidArgument] if validation fails.
  ///
  /// The [term] parameter is required and must not be empty or whitespace-only.
  factory SearchQuery.validated({
    required String term,
    String? country,
    String? language,
    int? limit,
    String? attribute,
    bool? explicit,
    Map<String, String>? customParams,
    String? ifModifiedSince,
    String? ifNoneMatch,
  }) {
    final trimmedTerm = term.trim();

    // Validate search term
    if (trimmedTerm.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'search_query',
        message: 'Search term must not be empty',
        details: {'field': 'term', 'value': term},
      );
    }

    // Validate limit
    if (limit != null && (limit < 1 || 200 < limit)) {
      throw SearchException.invalidArgument(
        providerId: 'search_query',
        message: 'Limit must be between 1 and 200 inclusive',
        details: {'field': 'limit', 'value': limit},
      );
    }

    // Validate country code (ISO 3166-1 alpha-2: 2 lowercase letters)
    if (country != null && !_isValidCountryCode(country)) {
      throw SearchException.invalidArgument(
        providerId: 'search_query',
        message:
            'Country code must be 2 lowercase letters (ISO 3166-1 alpha-2)',
        details: {'field': 'country', 'value': country},
      );
    }

    // Validate language code (format: lang_country, both lowercase)
    if (language != null && !_isValidLanguageCode(language)) {
      throw SearchException.invalidArgument(
        providerId: 'search_query',
        message:
            'Language code must be in format {lang}_{country} (e.g., en_us, ja_jp)',
        details: {'field': 'language', 'value': language},
      );
    }

    // Validate If-Modified-Since HTTP date format
    if (ifModifiedSince != null && !_isValidHttpDate(ifModifiedSince)) {
      throw SearchException.invalidArgument(
        providerId: 'search_query',
        message:
            'If-Modified-Since must be a valid HTTP date format (RFC 7232)',
        details: {'field': 'ifModifiedSince', 'value': ifModifiedSince},
      );
    }

    return SearchQuery(
      term: trimmedTerm,
      country: country,
      language: language,
      limit: limit,
      attribute: attribute,
      explicit: explicit,
      customParams: customParams,
      ifModifiedSince: ifModifiedSince,
      ifNoneMatch: ifNoneMatch,
    );
  }
}

/// Validates country code format (2 lowercase letters).
bool _isValidCountryCode(String code) {
  return RegExp(r'^[a-z]{2}$').hasMatch(code);
}

/// Validates language code format (lang_country, both lowercase).
bool _isValidLanguageCode(String code) {
  return RegExp(r'^[a-z]{2}_[a-z]{2}$').hasMatch(code);
}

/// Validates HTTP date format (RFC 7232).
bool _isValidHttpDate(String date) {
  return RegExp(
    r'^[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT$',
  ).hasMatch(date);
}
