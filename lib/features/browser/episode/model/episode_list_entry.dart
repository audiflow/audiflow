import 'package:isar/isar.dart';

part  'episode_list_entry.g.dart';

enum EpisodeListEntryRole {
  page,
  queue,
}

@collection
class EpisodeListEntry {
  EpisodeListEntry({
    required this.pid,
    required this.role,
    required this.eid,
    required this.order,
  });

  Id get id => eid;
  @Index(composite: [CompositeIndex('role'), CompositeIndex('order')])
  final int pid;
  @enumerated
  final EpisodeListEntryRole role;
  final int eid;
  final int order;
}
