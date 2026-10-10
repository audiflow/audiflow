import '../models/podcast_chapter.dart';
import '../models/podcast_chapters_link.dart';

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
    this.link,
  });

  final String title;
  final String description;
  final String? author;
  final String? imageUrl;
  final String? language;

  /// The show's website from the channel `<link>`.
  final String? link;
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
    this.isExplicit,
    this.contentEncoded,
    this.summary,
    this.link,
    this.transcripts,
    this.chapters,
    this.chaptersLink,
    this.descriptionChapters = const [],
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

  /// Whether `<itunes:explicit>` marks the episode explicit; null when the
  /// item has no such tag.
  final bool? isExplicit;

  /// Rich HTML content from <content:encoded>.
  final String? contentEncoded;

  /// iTunes summary.
  final String? summary;

  /// Episode web page URL.
  final String? link;

  final List<ParsedTranscript>? transcripts;
  final List<ParsedChapter>? chapters;

  /// Link to an external chapters file from `<podcast:chapters>`.
  final PodcastChaptersLink? chaptersLink;

  /// Chapters derived from a timestamp list in the show notes; empty when
  /// the feed has its own chapters or the notes hold no such list.
  ///
  /// Derived here so the work stays off the UI isolate during sync.
  final List<PodcastChapter> descriptionChapters;
}

/// Transcript metadata extracted from `<podcast:transcript>` elements.
final class ParsedTranscript {
  const ParsedTranscript({
    required this.url,
    required this.type,
    this.language,
    this.rel,
  });

  final String url;
  final String type;
  final String? language;
  final String? rel;
}

/// Chapter metadata extracted from `<psc:chapter>` elements.
final class ParsedChapter {
  const ParsedChapter({
    required this.title,
    required this.startTime,
    this.url,
    this.imageUrl,
  });

  final String title;
  final Duration startTime;
  final String? url;
  final String? imageUrl;
}

/// Emitted when parsing is complete.
final class ParseComplete extends ParseProgress {
  const ParseComplete({
    required this.totalParsed,
    required this.stoppedEarly,
    this.tailGuids = const {},
  });

  /// Total number of episodes parsed.
  final int totalParsed;

  /// True if parsing stopped early due to finding a known GUID.
  final bool stoppedEarly;

  /// GUIDs observed after the early-stop point (regex-only, no DOM parse).
  /// Lets callers build a complete picture of which GUIDs are still in the
  /// feed even when it was not fully parsed.
  final Set<String> tailGuids;
}
