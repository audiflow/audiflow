import 'package:isar_community/isar.dart';

part 'transcript_segment_table.g.dart';

@collection
class TranscriptSegment {
  Id id = Isar.autoIncrement;

  @Index()
  late int transcriptId;

  @Index()
  late int startMs;

  late int endMs;
  late String body;
  String? speaker;
}
