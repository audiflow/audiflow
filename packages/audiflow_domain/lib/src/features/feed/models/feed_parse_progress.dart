import 'package:audiflow_podcast/audiflow_podcast.dart'
    show ParsedChapter, ParsedTranscript;

/// Progress events emitted during feed parsing with batched storage.
sealed class FeedParseProgress {
  const FeedParseProgress();
}

/// Transcript and chapter metadata for an episode in a batch.
///
/// Carries parsed transcript/chapter data alongside episode companions
/// through the batch callback pipeline so callers can persist both.
final class ParsedEpisodeMediaMeta {
  const ParsedEpisodeMediaMeta({
    required this.guid,
    this.transcripts,
    this.chapters,
  });

  /// Episode GUID used to resolve the database episode ID.
  final String guid;

  /// Parsed transcript metadata from RSS feed.
  final List<ParsedTranscript>? transcripts;

  /// Parsed chapter metadata from RSS feed.
  final List<ParsedChapter>? chapters;

  /// Whether this episode has any transcript data.
  bool get hasTranscripts => transcripts != null && transcripts!.isNotEmpty;

  /// Whether this episode has any chapter data.
  bool get hasChapters => chapters != null && chapters!.isNotEmpty;

  /// Whether this episode has any media metadata to store.
  bool get hasData => hasTranscripts || hasChapters;
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
  const FeedParseComplete({
    required this.total,
    required this.stoppedEarly,
    this.tailGuids = const {},
  });

  /// Total episodes parsed and stored.
  final int total;

  /// True if stopped early due to known GUID.
  final bool stoppedEarly;

  /// GUIDs observed after the early-stop point (regex-only scan).
  final Set<String> tailGuids;
}
