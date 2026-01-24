/// Progress events emitted during feed parsing with batched storage.
sealed class FeedParseProgress {
  const FeedParseProgress();
}

/// Emitted when podcast metadata is ready.
final class FeedMetaReady extends FeedParseProgress {
  const FeedMetaReady({
    required this.title,
    required this.description,
    this.imageUrl,
    this.author,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final String? author;
}

/// Emitted when a batch of episodes has been stored.
final class EpisodesBatchStored extends FeedParseProgress {
  const EpisodesBatchStored({required this.totalSoFar});

  /// Total episodes stored so far.
  final int totalSoFar;
}

/// Emitted when parsing is complete.
final class FeedParseComplete extends FeedParseProgress {
  const FeedParseComplete({required this.total, required this.stoppedEarly});

  /// Total episodes parsed and stored.
  final int total;

  /// True if stopped early due to known GUID.
  final bool stoppedEarly;
}
