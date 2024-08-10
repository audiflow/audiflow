import 'package:isar/isar.dart';

part 'smart_queue.g.dart';

enum SmartQueueType {
  detailsPage;
}

@collection
class SmartQueueInfo {
  SmartQueueInfo({
    required this.type,
    required this.json,
  });

  Id get id => 1;
  @enumerated
  final SmartQueueType type;
  final String json;
}
