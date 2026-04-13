import 'smart_playlist_title_extractor.dart';

/// Controls how resolver groups map to selector dropdown entries.
final class SelectorConfig {
  const SelectorConfig({this.partitionBy, this.titleExtractor});

  factory SelectorConfig.fromJson(Map<String, dynamic> json) {
    return SelectorConfig(
      partitionBy: json['partitionBy'] as String?,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// How to partition groups: group, seasonNumber, year.
  final String? partitionBy;

  /// Names for partitioned selector entries.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (partitionBy != null) 'partitionBy': partitionBy,
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
