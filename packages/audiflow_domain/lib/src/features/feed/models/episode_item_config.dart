import 'smart_playlist_title_extractor.dart';

/// Defaults for individual episode row display.
final class EpisodeItemConfig {
  const EpisodeItemConfig({this.titleExtractor, this.showThumbnail});

  factory EpisodeItemConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeItemConfig(
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
      showThumbnail: json['showThumbnail'] as bool?,
    );
  }

  /// Transforms episode display names.
  final SmartPlaylistTitleExtractor? titleExtractor;

  /// Whether episode rows show a thumbnail. Applies to rows
  /// rendered both inside groups and inline at the playlist level.
  /// Tri-state: `null` means inherit from the parent surface; see
  /// `EffectiveThumbnails`.
  final bool? showThumbnail;

  Map<String, dynamic> toJson() {
    return {
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
      if (showThumbnail != null) 'showThumbnail': showThumbnail,
    };
  }
}
