import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:audiflow/features/queue/model/smart_queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_event.g.dart';

sealed class ManualQueueEvent {}

class ManualQueueItemAddedEvent implements ManualQueueEvent {
  const ManualQueueItemAddedEvent(this.item);

  final ManualQueueItem item;
}

class ManualQueueItemDeletedEvent implements ManualQueueEvent {
  const ManualQueueItemDeletedEvent(this.item);

  final ManualQueueItem item;
}

class ManualQueueItemsUpdatedEvent implements ManualQueueEvent {
  const ManualQueueItemsUpdatedEvent(this.items);

  final List<ManualQueueItem> items;
}

class ManualQueueItemsRemovedEvent implements ManualQueueEvent {
  const ManualQueueItemsRemovedEvent(this.item);

  final ManualQueueItem item;
}

class ManualQueueItemClearedEvent implements ManualQueueEvent {
  const ManualQueueItemClearedEvent();
}

sealed class SmartQueueEvent {}

class SmartQueueUpdatedEvent implements SmartQueueEvent {
  const SmartQueueUpdatedEvent(this.info);

  final SmartQueueInfo info;
}

@Riverpod(keepAlive: true)
class ManualQueueEventStream extends _$ManualQueueEventStream {
  @override
  Stream<ManualQueueEvent> build() async* {}

  void add(ManualQueueEvent event) {
    state = AsyncData(event);
  }
}

@Riverpod(keepAlive: true)
class SmartQueueEventStream extends _$SmartQueueEventStream {
  @override
  Stream<SmartQueueEvent> build() async* {}

  void add(SmartQueueEvent event) {
    state = AsyncData(event);
  }
}
