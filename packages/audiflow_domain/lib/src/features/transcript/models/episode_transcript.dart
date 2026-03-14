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
}
