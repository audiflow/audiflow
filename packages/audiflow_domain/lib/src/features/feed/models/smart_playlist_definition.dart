import 'episode_filters.dart';
import 'episode_item_config.dart';
import 'episode_listing_config.dart';
import 'group_item_config.dart';
import 'group_listing_config.dart';
import 'grouping_config.dart';
import 'selector_config.dart';

/// Unified per-playlist definition with all fields strongly typed.
final class SmartPlaylistDefinition {
  const SmartPlaylistDefinition({
    required this.id,
    required this.displayName,
    required this.grouping,
    required this.priority,
    this.selector,
    this.groupListing,
    this.groupItem,
    this.episodeListing,
    this.episodeItem,
    this.episodeFilters,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      grouping: GroupingConfig.fromJson(
        json['grouping'] as Map<String, dynamic>,
      ),
      priority: json['priority'] as int,
      selector: json['selector'] != null
          ? SelectorConfig.fromJson(json['selector'] as Map<String, dynamic>)
          : null,
      groupListing: json['groupListing'] != null
          ? GroupListingConfig.fromJson(
              json['groupListing'] as Map<String, dynamic>,
            )
          : null,
      groupItem: json['groupItem'] != null
          ? GroupItemConfig.fromJson(json['groupItem'] as Map<String, dynamic>)
          : null,
      episodeListing: json['episodeListing'] != null
          ? EpisodeListingConfig.fromJson(
              json['episodeListing'] as Map<String, dynamic>,
            )
          : null,
      episodeItem: json['episodeItem'] != null
          ? EpisodeItemConfig.fromJson(
              json['episodeItem'] as Map<String, dynamic>,
            )
          : null,
      episodeFilters: json['episodeFilters'] != null
          ? EpisodeFilters.fromJson(
              json['episodeFilters'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String displayName;

  /// Pipeline-oriented grouping configuration.
  final GroupingConfig grouping;

  /// Sort priority among playlists in the same pattern.
  final int priority;

  /// When present, this playlist exposes a selector UI.
  final SelectorConfig? selector;

  /// Playlist-level default for group list arrangement.
  final GroupListingConfig? groupListing;

  /// Playlist-level default for group card display.
  final GroupItemConfig? groupItem;

  /// Playlist-level default for episode list arrangement.
  final EpisodeListingConfig? episodeListing;

  /// Playlist-level default for episode row display.
  final EpisodeItemConfig? episodeItem;

  /// Episode filters applied before resolver processing.
  final EpisodeFilters? episodeFilters;

  /// True when this playlist renders as a separate top-level entry
  /// (i.e. a selector is configured).
  bool get isSeparate => selector != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'grouping': grouping.toJson(),
      'priority': priority,
      if (selector != null) 'selector': selector!.toJson(),
      if (groupListing != null) 'groupListing': groupListing!.toJson(),
      if (groupItem != null) 'groupItem': groupItem!.toJson(),
      if (episodeListing != null) 'episodeListing': episodeListing!.toJson(),
      if (episodeItem != null) 'episodeItem': episodeItem!.toJson(),
      if (episodeFilters != null) 'episodeFilters': episodeFilters!.toJson(),
    };
  }
}
