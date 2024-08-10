import 'dart:async';

import 'package:audiflow/features/queue/model/queue.dart';

abstract class AutoQueueBuilder {
  QueueItem? get current;

  FutureOr<List<QueueItem>> getQueuedItems({required int limit});

  FutureOr<bool> moveNext();

  FutureOr<String> encodeState();

  FutureOr<bool> decodeState(String encoded);

  void clear();
}
