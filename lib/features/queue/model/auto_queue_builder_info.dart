import 'package:isar/isar.dart';

part 'auto_queue_builder_info.g.dart';

enum AutoQueueBuilderType {
  detailsPage;
}

@collection
class AutoQueueBuilderInfo {
  AutoQueueBuilderInfo({
    required this.type,
    required this.json,
  });

  Id get id => type.index;
  @enumerated
  final AutoQueueBuilderType type;
  final String json;
}
