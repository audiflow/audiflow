import 'episode_sort_rule.dart';
import 'smart_playlist_title_extractor.dart';

/// Default display and ordering settings for episode lists.
final class EpisodeListConfig {
  const EpisodeListConfig({
    this.showYearHeaders,
    this.sort,
    this.titleExtractor,
  });

  factory EpisodeListConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeListConfig(
      showYearHeaders: json['showYearHeaders'] as bool?,
      sort: json['sort'] != null
          ? EpisodeSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Show year separator headers within episode lists.
  final bool? showYearHeaders;

  /// Sort rule for ordering episodes within a group.
  final EpisodeSortRule? sort;

  /// Transform episode titles for display.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (showYearHeaders != null) 'showYearHeaders': showYearHeaders,
      if (sort != null) 'sort': sort!.toJson(),
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
