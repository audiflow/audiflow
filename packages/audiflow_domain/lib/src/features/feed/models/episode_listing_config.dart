import 'episode_sort_rule.dart';

/// How episodes are arranged within groups.
final class EpisodeListingConfig {
  const EpisodeListingConfig({this.sort, this.showYearHeaders});

  factory EpisodeListingConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeListingConfig(
      sort: json['sort'] != null
          ? EpisodeSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      showYearHeaders: json['showYearHeaders'] as bool?,
    );
  }

  /// Sort rule for ordering episodes within a group.
  final EpisodeSortRule? sort;

  /// Show year dividers in episode list.
  final bool? showYearHeaders;

  Map<String, dynamic> toJson() {
    return {
      if (sort != null) 'sort': sort!.toJson(),
      if (showYearHeaders != null) 'showYearHeaders': showYearHeaders,
    };
  }
}
