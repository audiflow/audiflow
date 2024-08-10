import 'dart:async';

import 'package:audiflow/features/queue/model/queue_item.dart';

abstract class SmartQueueBuilder {
  QueueItem? get current;

  FutureOr<List<QueueItem>> getQueuedItems({required int limit});

  FutureOr<bool> moveNext();

  FutureOr<String> encodeState();

  FutureOr<bool> decodeState(String encoded);

  void clear();
}
