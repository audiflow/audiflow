import 'episode_list_config.dart';
import 'group_display_config.dart';
import 'smart_playlist_episode_extractor.dart';

/// Static group definition within a playlist.
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
    this.display,
    this.episodeList,
    this.episodeExtractor,
  });

  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] as String?,
      display: json['display'] != null
          ? GroupDisplayConfig.fromJson(json['display'] as Map<String, dynamic>)
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
    );
  }

  final String id;
  final String displayName;

  /// Regex pattern to match episode titles. Null = catch-all.
  final String? pattern;

  /// Per-group display overrides for the group card.
  final GroupDisplayConfig? display;

  /// Per-group override for episode list settings.
  final EpisodeListConfig? episodeList;

  /// Per-group override for episode number extraction.
  final SmartPlaylistEpisodeExtractor? episodeExtractor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern,
      if (display != null) 'display': display!.toJson(),
      if (episodeList != null) 'episodeList': episodeList!.toJson(),
      if (episodeExtractor != null)
        'episodeExtractor': episodeExtractor!.toJson(),
    };
  }
}
