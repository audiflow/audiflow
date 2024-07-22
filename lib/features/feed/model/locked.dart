import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'locked.g.dart';

@collection
class Locked {
  Locked({
    required this.locked,
    required this.owner,
  });

  factory Locked.fromFeed(feed.Locked locked) {
    return Locked(
      locked: locked.locked,
      owner: locked.owner,
    );
  }

  Id? id;
  final bool locked;
  final String? owner;
}
