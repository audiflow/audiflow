import 'smart_playlist_title_extractor.dart';

/// Defaults for individual episode row display.
final class EpisodeItemConfig {
  const EpisodeItemConfig({this.titleExtractor});

  factory EpisodeItemConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeItemConfig(
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Transforms episode display names.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
