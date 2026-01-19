import '../exceptions/search_exception.dart';

/// Result of a search or chart query using a builder.
///
/// This class wraps the constructed entities along with metadata
/// about the search operation, including cache validation headers
/// and any errors that occurred during parsing.
///
/// Example:
/// ```dart
/// final result = await searchService.searchWithBuilder(
///   query,
///   builder: myBuilder,
/// );
/// print('Found ${result.podcasts.length} podcasts');
/// if (result.hasErrors) {
///   print('Errors: ${result.errors}');
/// }
/// ```
class SearchEntityResult<T> {
  /// Creates a new search entity result.
  const SearchEntityResult({
    required this.podcasts,
    required this.totalCount,
    required this.provider,
    required this.timestamp,
    this.etag,
    this.lastModified,
    this.errors = const [],
    this.warnings = const [],
  });

  /// The constructed podcast entities.
  final List<T> podcasts;

  /// Total count from the API response.
  final int totalCount;

  /// Provider that returned these results.
  final String provider;

  /// Timestamp when results were fetched.
  final DateTime timestamp;

  /// ETag for conditional requests.
  final String? etag;

  /// Last-Modified header for conditional requests.
  final String? lastModified;

  /// Any errors that occurred during parsing.
  final List<SearchException> errors;

  /// Any warnings that occurred during parsing.
  final List<String> warnings;

  /// Returns true if there were errors during parsing.
  bool get hasErrors => errors.isNotEmpty;

  /// Returns true if there were warnings during parsing.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns true if parsing completed without errors or warnings.
  bool get isClean => !hasErrors && !hasWarnings;

  /// Whether this result contains no podcasts.
  bool get isEmpty => podcasts.isEmpty;

  /// Whether this result contains at least one podcast.
  bool get isNotEmpty => podcasts.isNotEmpty;

  /// Whether this result has cache validation headers.
  bool get hasCacheHeaders => etag != null || lastModified != null;

  @override
  String toString() {
    return 'SearchEntityResult<$T>{'
        'podcasts: ${podcasts.length} items, '
        'totalCount: $totalCount, '
        'provider: $provider, '
        'errors: ${errors.length}, '
        'warnings: ${warnings.length}}';
  }
}
