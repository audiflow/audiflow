import 'numbering_extractor.dart';
import 'smart_playlist_sort.dart';
import 'smart_playlist_title_extractor.dart';

/// Legacy pattern configuration for smart playlist grouping.
///
/// Superseded by [SmartPlaylistPatternConfig] which uses
/// [SmartPlaylistDefinition] for per-playlist settings. Kept
/// for backward compatibility with older serialized data.
@Deprecated('Use SmartPlaylistPatternConfig instead')
final class SmartPlaylistPattern {
  const SmartPlaylistPattern({
    required this.id,
    this.podcastGuid,
    this.feedUrls,
    required this.resolverType,
    required this.config,
    this.priority = 0,
    this.groupSort,
    this.titleExtractor,
    this.numberingExtractor,
    this.yearGroupedEpisodes = false,
  });

  final String id;
  final String? podcastGuid;
  final List<String>? feedUrls;
  final String resolverType;
  final Map<String, dynamic> config;
  final int priority;
  final SmartPlaylistSortRule? groupSort;
  final SmartPlaylistTitleExtractor? titleExtractor;
  final NumberingExtractor? numberingExtractor;
  final bool yearGroupedEpisodes;

  bool matchesPodcast(String? guid, String feedUrl) {
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }
    if (feedUrls != null && feedUrls!.contains(feedUrl)) {
      return true;
    }
    return false;
  }
}
