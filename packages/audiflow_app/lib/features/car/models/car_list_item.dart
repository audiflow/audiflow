/// An in-car list.
///
/// The enum names are wire values: CarPlay sends them over
/// `audiflow/carplay` (`CarPlaySection` in `ios/Runner/CarPlayChannel.swift`),
/// and Android Auto media ids are built from them.
enum CarSection {
  upNext,
  inProgress,
  library,
  downloads,

  /// The episodes of one podcast, opened from [library].
  podcast,

  /// The user's stations, in the Library's order.
  stations,

  /// The episodes of one station, opened from [stations].
  station;

  /// The section named [name], or null for a value this build does not know.
  static CarSection? byName(Object? name) {
    for (final section in values) {
      if (section.name == name) return section;
    }
    return null;
  }
}

/// One row of an in-car list.
final class CarListItem {
  const CarListItem({
    required this.id,
    required this.title,
    this.detail,
    this.artworkUrl,
    this.progress,
    this.isPlaying = false,
  });

  /// The queue item id in [CarSection.upNext], the podcast id in
  /// [CarSection.library], the station id in [CarSection.stations], and
  /// the episode id everywhere else: the id
  /// the native side sends back when the row is tapped.
  final int id;

  final String title;

  /// Secondary line: the podcast title, the duration inside a podcast, or
  /// a station's episode count.
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
