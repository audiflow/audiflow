import 'episode_filters.dart';
import 'episode_list_config.dart';
import 'group_list_config.dart';
import 'numbering_extractor.dart';
import 'smart_playlist_group_def.dart';
import 'smart_playlist_title_extractor.dart';

/// Unified per-playlist definition with all fields strongly typed.
final class SmartPlaylistDefinition {
  const SmartPlaylistDefinition({
    required this.id,
    required this.displayName,
    required this.resolverType,
    required this.presentation,
    this.episodeFilters,
    this.titleExtractor,
    this.prependSeasonNumber = false,
    this.groupList,
    this.episodeList,
    this.numberingExtractor,
    this.groups,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    // Accept v3 field aliases for cached data backward compatibility:
    // v3 'playlistStructure' -> v4 'presentation'
    // v3 'episodeExtractor' -> v4 'numberingExtractor'
    // v3 resolver types: 'rss' -> 'seasonNumber',
    //   'category' -> 'titleClassifier',
    //   'titleAppearanceOrder' -> 'titleDiscovery'
    final rawExtractor = json['numberingExtractor'] ?? json['episodeExtractor'];
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      resolverType: _normalizeResolverType(json['resolverType'] as String),
      presentation:
          (json['presentation'] ?? json['playlistStructure'] ?? 'separate')
              as String,
      episodeFilters: json['episodeFilters'] != null
          ? EpisodeFilters.fromJson(
              json['episodeFilters'] as Map<String, dynamic>,
            )
          : null,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
      prependSeasonNumber: (json['prependSeasonNumber'] as bool?) ?? false,
      groupList: json['groupList'] != null
          ? GroupListConfig.fromJson(json['groupList'] as Map<String, dynamic>)
          : null,
      episodeList: json['episodeList'] != null
          ? EpisodeListConfig.fromJson(
              json['episodeList'] as Map<String, dynamic>,
            )
          : null,
      numberingExtractor: rawExtractor != null
          ? NumberingExtractor.fromJson(rawExtractor as Map<String, dynamic>)
          : null,
      groups: (json['groups'] as List<dynamic>?)
          ?.map(
            (g) => SmartPlaylistGroupDef.fromJson(g as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Maps legacy v3 resolver type IDs to their v4 equivalents.
  static String _normalizeResolverType(String type) {
    return switch (type) {
      'rss' => 'seasonNumber',
      'category' => 'titleClassifier',
      'titleAppearanceOrder' => 'titleDiscovery',
      _ => type,
    };
  }

  final String id;
  final String displayName;
  final String resolverType;

  /// Presentation mode: "separate" or "combined".
  final String presentation;

  /// Episode filters applied before resolver processing.
  final EpisodeFilters? episodeFilters;

  /// Configuration for extracting display names from episode data.
  final SmartPlaylistTitleExtractor? titleExtractor;

  /// Whether to prepend season number label to group titles.
  final bool prependSeasonNumber;

  /// Settings for the group list view (combined mode only).
  final GroupListConfig? groupList;

  /// Default settings for episode lists within groups.
  final EpisodeListConfig? episodeList;

  /// Configuration for extracting season/episode numbers.
  final NumberingExtractor? numberingExtractor;

  /// Static group definitions for category-based grouping.
  final List<SmartPlaylistGroupDef>? groups;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'resolverType': resolverType,
      'presentation': presentation,
      if (episodeFilters != null) 'episodeFilters': episodeFilters!.toJson(),
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
      if (prependSeasonNumber) 'prependSeasonNumber': prependSeasonNumber,
      if (groupList != null) 'groupList': groupList!.toJson(),
      if (episodeList != null) 'episodeList': episodeList!.toJson(),
      if (numberingExtractor != null)
        'numberingExtractor': numberingExtractor!.toJson(),
      if (groups != null) 'groups': groups!.map((g) => g.toJson()).toList(),
    };
  }
}
