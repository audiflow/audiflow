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
    this.priority = 0,
    this.playlistStructure,
    this.episodeFilters,
    this.nullSeasonGroupKey,
    this.titleExtractor,
    this.prependSeasonNumber = false,
    this.groupList,
    this.episodeList,
    this.episodeExtractor,
    this.groups,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      resolverType: json['resolverType'] as String,
      priority: (json['priority'] as int?) ?? 0,
      playlistStructure: json['playlistStructure'] as String?,
      episodeFilters: json['episodeFilters'] != null
          ? EpisodeFilters.fromJson(
              json['episodeFilters'] as Map<String, dynamic>,
            )
          : null,
      nullSeasonGroupKey: json['nullSeasonGroupKey'] as int?,
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
      episodeExtractor: json['episodeExtractor'] != null
          ? SmartPlaylistEpisodeExtractor.fromJson(
              json['episodeExtractor'] as Map<String, dynamic>,
            )
          : null,
      groups: (json['groups'] as List<dynamic>?)
          ?.map(
            (g) => SmartPlaylistGroupDef.fromJson(g as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String id;
  final String displayName;
  final String resolverType;
  final int priority;

  /// Playlist structure: "split" or "grouped".
  final String? playlistStructure;

  /// Episode filters applied before resolver processing.
  final EpisodeFilters? episodeFilters;

  final int? nullSeasonGroupKey;

  /// Configuration for extracting display names from episode data.
  final SmartPlaylistTitleExtractor? titleExtractor;

  /// Whether to prepend season number label to group titles.
  final bool prependSeasonNumber;

  /// Settings for the group list view (grouped mode only).
  final GroupListConfig? groupList;

  /// Default settings for episode lists within groups.
  final EpisodeListConfig? episodeList;

  /// Configuration for extracting season/episode numbers.
  final SmartPlaylistEpisodeExtractor? episodeExtractor;

  /// Static group definitions for category-based grouping.
  final List<SmartPlaylistGroupDef>? groups;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'resolverType': resolverType,
      if (priority != 0) 'priority': priority,
      if (playlistStructure != null) 'playlistStructure': playlistStructure,
      if (episodeFilters != null) 'episodeFilters': episodeFilters!.toJson(),
      if (nullSeasonGroupKey != null) 'nullSeasonGroupKey': nullSeasonGroupKey,
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
      if (prependSeasonNumber) 'prependSeasonNumber': prependSeasonNumber,
      if (groupList != null) 'groupList': groupList!.toJson(),
      if (episodeList != null) 'episodeList': episodeList!.toJson(),
      if (episodeExtractor != null)
        'episodeExtractor': episodeExtractor!.toJson(),
      if (groups != null) 'groups': groups!.map((g) => g.toJson()).toList(),
    };
  }
}
