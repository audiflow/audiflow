import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:logger/logger.dart';

/// Builder implementation for constructing podcast entities from parsed RSS data.
///
/// This builder uses the parser's built-in model types. When Drift tables are
/// added, this can be replaced with a DriftPodcastBuilder that produces
/// Drift Companion objects directly.
///
/// Example with Drift (future implementation):
/// ```dart
/// class DriftPodcastBuilder implements PodcastEntityBuilder<PodcastsCompanion, EpisodesCompanion> {
///   @override
///   PodcastsCompanion buildFeed(Map<String, dynamic> feedData, String sourceUrl) {
///     return PodcastsCompanion.insert(
///       feedUrl: sourceUrl,
///       title: feedData['title'] as String? ?? '',
///       // ... map all fields
///     );
///   }
///   // ...
/// }
/// ```
class DefaultPodcastBuilder
    implements PodcastEntityBuilder<PodcastFeed, PodcastItem> {
  final Logger? _logger;

  DefaultPodcastBuilder({Logger? logger}) : _logger = logger;

  @override
  PodcastFeed buildFeed(Map<String, dynamic> feedData, String sourceUrl) {
    _logger?.d('Building feed from data: ${feedData['title']}');
    return PodcastFeed.fromMap(feedData, sourceUrl);
  }

  @override
  PodcastItem buildItem(Map<String, dynamic> itemData, String sourceUrl) {
    _logger?.t('Building item: ${itemData['title']}');
    return PodcastItem.fromMap(itemData, sourceUrl);
  }

  @override
  void onError(PodcastParseError error) {
    _logger?.e('Podcast parse error: ${error.message}', error: error);
  }

  @override
  void onWarning(PodcastParseWarning warning) {
    _logger?.w('Podcast parse warning: ${warning.message}');
  }
}

/// Parsed feed result containing podcast metadata and episodes.
///
/// This is a domain-level representation of a parsed RSS feed.
class ParsedFeed {
  /// The parsed podcast metadata.
  final PodcastFeed podcast;

  /// The parsed episode items.
  final List<PodcastItem> episodes;

  /// Any errors that occurred during parsing.
  final List<PodcastParseError> errors;

  /// Any warnings that occurred during parsing.
  final List<PodcastParseWarning> warnings;

  const ParsedFeed({
    required this.podcast,
    required this.episodes,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Returns true if parsing completed without errors.
  bool get hasNoErrors => errors.isEmpty;

  /// Returns true if parsing completed without warnings.
  bool get hasNoWarnings => warnings.isEmpty;

  /// Returns true if parsing completed cleanly (no errors or warnings).
  bool get isClean => hasNoErrors && hasNoWarnings;

  /// Number of episodes in the feed.
  int get episodeCount => episodes.length;
}
