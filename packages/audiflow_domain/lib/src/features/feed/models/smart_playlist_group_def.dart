import 'episode_item_config.dart';
import 'episode_listing_config.dart';
import 'group_item_config.dart';
import 'group_listing_config.dart';
import 'matcher.dart';
import 'numbering_extractor.dart';

/// Static group definition within a playlist.
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
    this.groupListing,
    this.groupItem,
    this.episodeListing,
    this.episodeItem,
    this.numberingExtractor,
  });

  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] != null
          ? Matcher.fromJson(json['pattern'] as Map<String, dynamic>)
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
      numberingExtractor:
          (json['numberingExtractor'] ?? json['episodeExtractor']) != null
          ? NumberingExtractor.fromJson(
              (json['numberingExtractor'] ?? json['episodeExtractor'])
                  as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String displayName;

  /// Matcher defining the episode field and regex pattern. Null = catch-all.
  final Matcher? pattern;

  /// Per-group override for group list arrangement.
  final GroupListingConfig? groupListing;

  /// Per-group override for group card display.
  final GroupItemConfig? groupItem;

  /// Per-group override for episode list arrangement.
  final EpisodeListingConfig? episodeListing;

  /// Per-group override for episode row display.
  final EpisodeItemConfig? episodeItem;

  /// Per-group override for episode number extraction.
  final NumberingExtractor? numberingExtractor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern!.toJson(),
      if (groupListing != null) 'groupListing': groupListing!.toJson(),
      if (groupItem != null) 'groupItem': groupItem!.toJson(),
      if (episodeListing != null) 'episodeListing': episodeListing!.toJson(),
      if (episodeItem != null) 'episodeItem': episodeItem!.toJson(),
      if (numberingExtractor != null)
        'numberingExtractor': numberingExtractor!.toJson(),
    };
  }
}
