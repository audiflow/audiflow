/// Progress events emitted during isolate-based RSS parsing.
///
/// Used to communicate parsing state from the isolate back to the main thread.
sealed class ParseProgress {
  const ParseProgress();
}

/// Emitted when podcast metadata has been parsed.
final class ParsedPodcastMeta extends ParseProgress {
  const ParsedPodcastMeta({
    required this.title,
    required this.description,
    this.author,
    this.imageUrl,
    this.language,
  });

  final String title;
  final String description;
  final String? author;
  final String? imageUrl;
  final String? language;
}

/// Emitted for each episode parsed.
final class ParsedEpisode extends ParseProgress {
  const ParsedEpisode({
    required this.guid,
    required this.title,
    this.description,
    this.enclosureUrl,
    this.enclosureType,
    this.enclosureLength,
    this.publishDate,
    this.duration,
    this.episodeNumber,
    this.seasonNumber,
    this.imageUrl,
  });

  final String? guid;
  final String title;
  final String? description;
  final String? enclosureUrl;
  final String? enclosureType;
  final int? enclosureLength;
  final DateTime? publishDate;
  final Duration? duration;
  final int? episodeNumber;
  final int? seasonNumber;
  final String? imageUrl;
}

/// Emitted when parsing is complete.
final class ParseComplete extends ParseProgress {
  const ParseComplete({
    required this.totalParsed,
    required this.stoppedEarly,
  });

  /// Total number of episodes parsed.
  final int totalParsed;

  /// True if parsing stopped early due to finding a known GUID.
  final bool stoppedEarly;
}
