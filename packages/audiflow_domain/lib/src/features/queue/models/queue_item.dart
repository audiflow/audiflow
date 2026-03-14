import 'package:isar_community/isar.dart';

part 'queue_item.g.dart';

@collection
class QueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  @Index()
  late int position;

  bool isAdhoc = false;
  String? sourceContext;
  late DateTime addedAt;
}
