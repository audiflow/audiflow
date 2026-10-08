import 'package:audiflow_podcast/audiflow_podcast.dart'
    show TranscriptFileParser;
import 'package:isar_community/isar.dart';

part 'episode_transcript.g.dart';

@collection
class EpisodeTranscript {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('url')], unique: true)
  late int episodeId;

  late String url;
  late String type;
  String? language;
  String? rel;
  DateTime? fetchedAt;

  /// When a fetch got the file but it held no transcript (empty, or not
  /// parseable as its declared type). Network and HTTP failures are not
  /// recorded here, since they may clear up on a later try.
  DateTime? unusableAt;
}

/// Whether a declared transcript file is worth offering or fetching.
extension EpisodeTranscriptUsability on EpisodeTranscript {
  /// A supported format not yet found unusable. Until it is fetched this
  /// is the feed's promise, not proof of content.
  bool get isCandidate =>
      unusableAt == null && TranscriptFileParser.isSupported(type);
}
