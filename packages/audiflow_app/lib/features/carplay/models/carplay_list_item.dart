/// A CarPlay list the native side can ask for over `audiflow/carplay`.
///
/// The enum names are the wire values, shared with `CarPlaySection` in
/// `ios/Runner/CarPlayChannel.swift`.
enum CarPlaySection {
  upNext,
  inProgress,
  library,
  downloads,

  /// The episodes of one podcast, opened from [library].
  podcast;

  /// The section named [name], or null for a value this build does not know.
  static CarPlaySection? byName(Object? name) {
    for (final section in values) {
      if (section.name == name) return section;
    }
    return null;
  }
}

/// One row of a CarPlay list.
final class CarPlayListItem {
  const CarPlayListItem({
    required this.id,
    required this.title,
    this.detail,
    this.artworkUrl,
    this.progress,
    this.isPlaying = false,
  });

  /// The queue item id in [CarPlaySection.upNext], the podcast id in
  /// [CarPlaySection.library], and the episode id everywhere else: the id
  /// the native side sends back when the row is tapped.
  final int id;

  final String title;

  /// Secondary line: the podcast title, or the duration inside a podcast.
  final String? detail;

  final String? artworkUrl;

  /// Listened fraction, 0 to 1, for an episode with a resume position.
  final double? progress;

  /// Whether the row is the now-playing episode.
  final bool isPlaying;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'detail': detail,
    'artworkUrl': artworkUrl,
    'progress': progress,
    'isPlaying': isPlaying,
  };
}
