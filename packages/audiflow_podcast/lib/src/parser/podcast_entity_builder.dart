import '../errors/podcast_parse_error.dart';

/// Callback interface for constructing domain entities from parsed RSS data.
///
/// This interface enables zero-copy architecture by allowing consumers to
/// build their own entity types directly from raw XML data, without creating
/// intermediate parser-specific model objects.
///
/// ## Usage
///
/// Implement this interface to construct your domain entities (e.g., Drift
/// database companions) directly from parsed RSS data:
///
/// ```dart
/// class DriftPodcastBuilder implements PodcastEntityBuilder<PodcastsCompanion, EpisodesCompanion> {
///   @override
///   PodcastsCompanion buildFeed(Map<String, dynamic> feedData, String sourceUrl) {
///     return PodcastsCompanion.insert(
///       feedUrl: sourceUrl,
///       title: feedData['title'] as String? ?? '',
///       // ... map all fields from raw data
///     );
///   }
///
///   @override
///   EpisodesCompanion buildItem(Map<String, dynamic> itemData, String sourceUrl) {
///     return EpisodesCompanion.insert(
///       guid: itemData['guid'] as String? ?? '',
///       title: itemData['title'] as String? ?? '',
///       // ... map all fields from raw data
///     );
///   }
///
///   @override
///   void onError(PodcastParseError error) {
///     // Handle or convert error as needed
///   }
///
///   @override
///   void onWarning(PodcastParseWarning warning) {
///     // Handle warning as needed
///   }
/// }
/// ```
///
/// ## Available Feed Data Keys
///
/// The `feedData` map contains these keys:
/// - `title` (String)
/// - `description` (String)
/// - `link` (String?)
/// - `language` (String?)
/// - `copyright` (String?)
/// - `lastBuildDate` (DateTime?)
/// - `pubDate` (DateTime?)
/// - `generator` (String?)
/// - `managingEditor` (String?)
/// - `webMaster` (String?)
/// - `ttl` (int?)
/// - `image` (Map<String, dynamic>?) - RSS image with url, title, width, height
/// - `itunesImage` (String?)
/// - `itunesAuthor` (String?)
/// - `itunesSubtitle` (String?)
/// - `itunesSummary` (String?)
/// - `itunesExplicit` (bool?)
/// - `itunesOwner` (Map<String, dynamic>?) - with name, email
/// - `itunesType` (String?) - episodic or serial
/// - `itunesComplete` (bool?)
/// - `itunesNewFeedUrl` (String?)
/// - `categories` (List<String>?)
/// - `itunesCategories` (List<String>?)
///
/// ## Available Item Data Keys
///
/// The `itemData` map contains these keys:
/// - `title` (String)
/// - `description` (String)
/// - `link` (String?)
/// - `guid` (String?)
/// - `guidIsPermaLink` (bool?)
/// - `pubDate` (DateTime?)
/// - `author` (String?)
/// - `comments` (String?)
/// - `source` (String?)
/// - `contentEncoded` (String?)
/// - `categories` (List<String>?)
/// - `enclosure` (Map<String, dynamic>?) - with url, type, length
/// - `itunesTitle` (String?)
/// - `itunesSubtitle` (String?)
/// - `itunesSummary` (String?)
/// - `itunesAuthor` (String?)
/// - `itunesDuration` (Duration?)
/// - `itunesExplicit` (bool?)
/// - `itunesImage` (String?)
/// - `itunesEpisode` (int?)
/// - `itunesSeason` (int?)
/// - `itunesEpisodeType` (String?)
/// - `chapters` (List<Map<String, dynamic>>?)
/// - `transcripts` (List<Map<String, dynamic>>?)
abstract class PodcastEntityBuilder<TFeed, TItem> {
  /// Called when feed-level metadata is parsed.
  ///
  /// The [feedData] map contains all parsed feed-level attributes.
  /// The [sourceUrl] is the original URL of the RSS feed.
  ///
  /// Returns the constructed feed entity.
  TFeed buildFeed(Map<String, dynamic> feedData, String sourceUrl);

  /// Called for each episode item parsed from the feed.
  ///
  /// The [itemData] map contains all parsed item attributes.
  /// The [sourceUrl] is the original URL of the RSS feed.
  ///
  /// Returns the constructed item entity.
  TItem buildItem(Map<String, dynamic> itemData, String sourceUrl);

  /// Called when a parsing error occurs.
  ///
  /// Implementations can choose to:
  /// - Log the error and continue
  /// - Convert to a domain-specific exception and throw
  /// - Accumulate errors for later processing
  void onError(PodcastParseError error);

  /// Called for recoverable parsing warnings.
  ///
  /// Warnings indicate issues that don't prevent parsing but may indicate
  /// data quality problems. Implementations can log or ignore these.
  void onWarning(PodcastParseWarning warning);
}

/// Result of parsing a podcast feed using a builder.
class ParsedPodcastResult<TFeed, TItem> {
  /// The parsed feed metadata.
  final TFeed feed;

  /// The parsed episode items.
  final List<TItem> items;

  /// Any errors that occurred during parsing.
  final List<PodcastParseError> errors;

  /// Any warnings that occurred during parsing.
  final List<PodcastParseWarning> warnings;

  const ParsedPodcastResult({
    required this.feed,
    required this.items,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Returns true if parsing completed without errors.
  bool get hasNoErrors => errors.isEmpty;

  /// Returns true if parsing completed without warnings.
  bool get hasNoWarnings => warnings.isEmpty;

  /// Returns true if parsing completed cleanly (no errors or warnings).
  bool get isClean => hasNoErrors && hasNoWarnings;
}
