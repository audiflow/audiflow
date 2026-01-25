/// Interface for episode data used by pattern extractors.
///
/// This interface allows extractors to work with episode data without
/// depending on specific database implementations (like Drift).
abstract interface class EpisodeData {
  /// Episode title.
  String get title;

  /// Episode description (optional).
  String? get description;

  /// Season number from RSS metadata (optional).
  int? get seasonNumber;

  /// Episode number from RSS metadata (optional).
  int? get episodeNumber;
}

/// Simple implementation of [EpisodeData] for testing and CLI tools.
final class SimpleEpisodeData implements EpisodeData {
  const SimpleEpisodeData({
    required this.title,
    this.description,
    this.seasonNumber,
    this.episodeNumber,
  });

  @override
  final String title;

  @override
  final String? description;

  @override
  final int? seasonNumber;

  @override
  final int? episodeNumber;
}
