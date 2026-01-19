import 'package:freezed_annotation/freezed_annotation.dart';

import 'podcast.dart';

part 'search_result.freezed.dart';

/// Immutable container for podcast search or chart results.
///
/// This class wraps a list of [Podcast] results along with metadata
/// about the search operation, including the provider that generated
/// the results, the timestamp, and optional cache validation headers.
///
/// Example:
/// ```dart
/// final result = SearchResult(
///   totalCount: 50,
///   podcasts: [podcast1, podcast2, ...],
///   provider: 'itunes',
/// );
/// ```
@freezed
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    /// Total number of results found by the search/chart query.
    required int totalCount,

    /// List of podcast results returned by the search/chart query.
    required List<Podcast> podcasts,

    /// Identifier of the provider that generated these results.
    required String provider,

    /// Timestamp when these results were retrieved.
    DateTime? timestamp,

    /// HTTP Last-Modified header value from the API response.
    String? lastModified,

    /// HTTP ETag header value from the API response.
    String? etag,
  }) = _SearchResult;
  const SearchResult._();

  /// Whether this result contains no podcasts.
  bool get isEmpty => podcasts.isEmpty;

  /// Whether this result contains at least one podcast.
  bool get isNotEmpty => podcasts.isNotEmpty;

  /// Whether this result has cache validation headers.
  ///
  /// Returns true if either [lastModified] or [etag] is present.
  bool get hasCacheHeaders => lastModified != null || etag != null;

  /// Gets the timestamp, defaulting to the current time if not set.
  DateTime get effectiveTimestamp => timestamp ?? DateTime.now();
}
