import '../exceptions/search_exception.dart';

/// Builder interface for constructing domain entities from iTunes search data.
///
/// Enables zero-copy architecture by allowing consumers to build their own
/// entity types directly from parsed JSON data, without creating intermediate
/// parser-specific model objects.
///
/// ## Usage
///
/// Implement this interface to construct your domain entities (e.g., Drift
/// database companions) directly from parsed iTunes API data:
///
/// ```dart
/// class DriftPodcastSearchBuilder
///     implements PodcastSearchEntityBuilder<PodcastsCompanion> {
///   @override
///   PodcastsCompanion buildPodcast(Map<String, dynamic> podcastData) {
///     return PodcastsCompanion.insert(
///       itunesId: Value(podcastData['id'] as String),
///       title: podcastData['name'] as String,
///       artistName: podcastData['artistName'] as String,
///       feedUrl: Value(podcastData['feedUrl'] as String?),
///       // ... map all fields from raw data
///     );
///   }
///
///   @override
///   void onError(SearchException error) {
///     // Handle or convert error as needed
///   }
///
///   @override
///   void onWarning(String message, {Map<String, dynamic>? context}) {
///     // Handle warning as needed
///   }
/// }
/// ```
///
/// ## Available Podcast Data Keys
///
/// The `podcastData` map contains these keys:
/// - `id` (String) - iTunes podcast ID (from collectionId or trackId)
/// - `name` (String) - Podcast title
/// - `artistName` (String) - Publisher/artist name
/// - `genres` (List<String>) - Genre names
/// - `explicit` (bool) - Explicit content flag
/// - `feedUrl` (String?) - RSS feed URL
/// - `description` (String?) - Podcast description
/// - `artworkUrl` (String?) - Highest resolution artwork URL
/// - `releaseDate` (DateTime?) - Last release date
/// - `trackCount` (int?) - Episode count
abstract class PodcastSearchEntityBuilder<T> {
  /// Called for each podcast parsed from search or chart results.
  ///
  /// The [podcastData] map contains normalized podcast attributes.
  /// See class documentation for available keys.
  ///
  /// Returns the constructed podcast entity.
  T buildPodcast(Map<String, dynamic> podcastData);

  /// Called when an API or parsing error occurs.
  ///
  /// Implementations can choose to:
  /// - Log the error and continue
  /// - Convert to a domain-specific exception and throw
  /// - Accumulate errors for later processing
  void onError(SearchException error);

  /// Called for recoverable warnings during parsing.
  ///
  /// Warnings indicate issues that don't prevent parsing but may indicate
  /// data quality problems. Implementations can log or ignore these.
  void onWarning(String message, {Map<String, dynamic>? context});
}
