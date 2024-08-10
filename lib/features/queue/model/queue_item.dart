import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'queue_item.freezed.dart';
part 'queue_item.g.dart';

abstract class QueueItem {
  int? get id;

  int get pid;

  int get eid;

  int get ordinal;
}

@collection
class ManualQueueItem implements QueueItem {
  ManualQueueItem({
    this.id,
    required this.pid,
    required this.eid,
    required this.ordinal,
  });

  @override
  Id? id;
  @override
  final int pid;
  @override
  final int eid;
  @override
  @Index()
  final int ordinal;

  ManualQueueItem copyWith({int? ordinal}) {
    return ManualQueueItem(
      id: id,
      pid: pid,
      eid: eid,
      ordinal: ordinal ?? this.ordinal,
    );
  }
}

@freezed
class SmartQueueItem with _$SmartQueueItem implements QueueItem {
  const factory SmartQueueItem({
    required int pid,
    required int eid,
    required int ordinal,
  }) = _SmartQueueItem;

  const SmartQueueItem._();

  @override
  int? get id => eid;
}
