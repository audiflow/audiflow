import 'package:isar/isar.dart';

part  'episode_list_entry.g.dart';

@collection
class EpisodeListEntry {
  EpisodeListEntry({
    required this.pid,
    required this.eid,
    required this.order,
  });

  Id get id => eid;
  @Index(composite: [CompositeIndex('order')])
  final int pid;
  final int eid;
  final int order;
}
