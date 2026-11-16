import 'package:isar_community/isar.dart';

part 'queue_item.g.dart';

@collection
class QueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late int episodeId;

  @Index()
  late int position;

  /// The id of this item's `QueueEntry`, the copy that syncs; null until
  /// its episode has a stable key.
  @Index()
  String? entryId;

  bool isAdhoc = false;
  String? sourceContext;
  late DateTime addedAt;
}
