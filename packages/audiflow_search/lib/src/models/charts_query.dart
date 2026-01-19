import 'package:audiflow_search/audiflow_search.dart' show StatusCode;
import 'package:audiflow_search/src/exceptions/status_code.dart'
    show StatusCode;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/search_exception.dart';
import 'itunes_genre.dart';

part 'charts_query.freezed.dart';

/// Immutable value object representing podcast chart retrieval parameters.
///
/// This class validates all chart parameters according to iTunes Search API
/// requirements and provides type-safe access to chart options.
///
/// Use the [ChartsQuery.validated] factory for construction with validation.
///
/// Example:
/// ```dart
/// final query = ChartsQuery.validated(
///   country: 'us',
///   limit: 100,
///   genre: ItunesGenre.technology,
///   explicit: false,
/// );
/// ```
@freezed
abstract class ChartsQuery with _$ChartsQuery {
  const factory ChartsQuery({
    /// ISO 3166-1 alpha-2 country code (2 lowercase letters, required).
    required String country,

    /// Maximum number of chart results to return (1-200 inclusive).
    int? limit,

    /// Genre filter for chart retrieval.
    ItunesGenre? genre,

    /// Whether to include explicit content in chart results.
    bool? explicit,

    /// HTTP If-Modified-Since header value for conditional requests.
    String? ifModifiedSince,

    /// HTTP If-None-Match header value for conditional requests.
    String? ifNoneMatch,
  }) = _ChartsQuery;
  const ChartsQuery._();

  /// Creates a validated charts query with the given parameters.
  ///
  /// Validates all parameters and throws [SearchException] with
  /// [StatusCode.invalidArgument] if validation fails.
  ///
  /// The [country] parameter is required and must be a valid 2-letter
  /// ISO 3166-1 alpha-2 country code in lowercase.
  factory ChartsQuery.validated({
    required String country,
    int? limit,
    ItunesGenre? genre,
    bool? explicit,
    String? ifModifiedSince,
    String? ifNoneMatch,
  }) {
    final trimmedCountry = country.trim();

    // Validate country code
    if (trimmedCountry.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'charts_query',
        message: 'Country code must not be empty',
        details: {'field': 'country', 'value': country},
      );
    }

    if (!_isValidCountryCode(trimmedCountry)) {
      throw SearchException.invalidArgument(
        providerId: 'charts_query',
        message:
            'Country code must be 2 lowercase letters (ISO 3166-1 alpha-2)',
        details: {'field': 'country', 'value': country},
      );
    }

    // Validate limit
    if (limit != null && (limit < 1 || 200 < limit)) {
      throw SearchException.invalidArgument(
        providerId: 'charts_query',
        message: 'Limit must be between 1 and 200 inclusive',
        details: {'field': 'limit', 'value': limit},
      );
    }

    // Validate If-Modified-Since HTTP date format
    if (ifModifiedSince != null && !_isValidHttpDate(ifModifiedSince)) {
      throw SearchException.invalidArgument(
        providerId: 'charts_query',
        message:
            'If-Modified-Since must be a valid HTTP date format (RFC 7232)',
        details: {'field': 'ifModifiedSince', 'value': ifModifiedSince},
      );
    }

    return ChartsQuery(
      country: trimmedCountry,
      limit: limit,
      genre: genre,
      explicit: explicit,
      ifModifiedSince: ifModifiedSince,
      ifNoneMatch: ifNoneMatch,
    );
  }
}

/// Validates country code format (2 lowercase letters).
bool _isValidCountryCode(String code) {
  return RegExp(r'^[a-z]{2}$').hasMatch(code);
}

/// Validates HTTP date format (RFC 7232).
bool _isValidHttpDate(String date) {
  return RegExp(
    r'^[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT$',
  ).hasMatch(date);
}
