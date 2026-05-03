import 'smart_playlist_title_extractor.dart';

/// Defaults for individual group card display.
final class GroupItemConfig {
  const GroupItemConfig({
    this.showDateRange,
    this.pinToYear,
    this.prependSeasonNumber,
    this.titleExtractor,
    this.showThumbnail,
  });

  factory GroupItemConfig.fromJson(Map<String, dynamic> json) {
    return GroupItemConfig(
      showDateRange: json['showDateRange'] as bool?,
      pinToYear: json['pinToYear'] as bool?,
      prependSeasonNumber: json['prependSeasonNumber'] as bool?,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
      showThumbnail: json['showThumbnail'] as bool?,
    );
  }

  /// Show date range on group card.
  final bool? showDateRange;

  /// Pin group to its earliest year's section.
  final bool? pinToYear;

  /// Prefix group title with season number (e.g. "S13").
  final bool? prependSeasonNumber;

  /// Generates group display names from episode data.
  final SmartPlaylistTitleExtractor? titleExtractor;

  /// Whether group cards show a thumbnail.
  /// Tri-state: `null` means unset (defaults to `true` per schema).
  final bool? showThumbnail;

  Map<String, dynamic> toJson() {
    return {
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (pinToYear != null) 'pinToYear': pinToYear,
      if (prependSeasonNumber != null)
        'prependSeasonNumber': prependSeasonNumber,
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
      if (showThumbnail != null) 'showThumbnail': showThumbnail,
    };
  }
}
