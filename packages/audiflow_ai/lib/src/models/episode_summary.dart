// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Summary of a podcast episode.
class EpisodeSummary {
  /// Creates an [EpisodeSummary].
  const EpisodeSummary({
    required this.summary,
    required this.keyTopics,
    this.estimatedListeningMinutes,
  });

  /// The generated summary text.
  final String summary;

  /// Key topics extracted from the episode content.
  final List<String> keyTopics;

  /// Estimated listening time in minutes.
  final int? estimatedListeningMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeSummary &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          _listEquals(keyTopics, other.keyTopics) &&
          estimatedListeningMinutes == other.estimatedListeningMinutes;

  @override
  int get hashCode => Object.hash(
    summary,
    Object.hashAll(keyTopics),
    estimatedListeningMinutes,
  );

  @override
  String toString() =>
      'EpisodeSummary(summary: ${summary.length} chars, '
      'keyTopics: ${keyTopics.length}, '
      'estimatedListeningMinutes: $estimatedListeningMinutes)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
