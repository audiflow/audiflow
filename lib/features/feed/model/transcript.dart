import 'package:audiflow/utils/hash.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'transcript.g.dart';

enum TranscriptFormat {
  json,
  subrip,
  unsupported,
}

/// This class represents a Podcasting 2.0 transcript URL.
///
/// [docs](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
@collection
class TranscriptUrl {
  TranscriptUrl({
    this.url = '',
    this.type = TranscriptFormat.unsupported,
    this.language = '',
    this.rel = '',
  });

  factory TranscriptUrl.fromFeed(feed.TranscriptUrl t) {
    TranscriptFormat type;
    switch (t.type) {
      case feed.TranscriptFormat.subrip:
        type = TranscriptFormat.subrip;
      case feed.TranscriptFormat.json:
        type = TranscriptFormat.json;
      case feed.TranscriptFormat.unsupported:
        type = TranscriptFormat.unsupported;
    }
    return TranscriptUrl(
      url: t.url,
      type: type,
      language: t.language,
      rel: t.rel,
    );
  }

  Id? id;

  /// The URL for the transcript.
  final String url;

  /// The type of transcript: json or srt
  @enumerated
  final TranscriptFormat type;

  /// The language for the transcript
  final String language;

  /// If set to captions, shows that this is a closed-caption file
  final String rel;
}

/// This class represents a Podcasting 2.0 transcript container.
/// [docs](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
@collection
class Transcript {
  Transcript({
    this.transcriptId,
    required this.pid,
    required this.guid,
    this.filtered = false,
  });

  Id get id => fastHash(guid);
  final int? transcriptId;
  final int pid;
  final String guid;
  final subtitles = IsarLinks<Subtitle>();
  final bool filtered;
}

/// Represents an individual line within a transcript.
@collection
class Subtitle {
  Subtitle({
    required this.id,
    required this.index,
    required this.startMS,
    this.endMS,
    this.data,
    this.speaker = '',
  });

  final Id id;
  final int index;
  final int startMS;
  final int? endMS;
  final String? data;
  final String speaker;
}

extension SubtitleExt on Subtitle {
  Duration get start => Duration(milliseconds: startMS);

  Duration? get end => endMS == null ? null : Duration(milliseconds: endMS!);
}
