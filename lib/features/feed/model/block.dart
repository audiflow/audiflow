import 'package:isar/isar.dart';
import 'package:podcast_feed/podcast_feed.dart' as feed;

part 'block.g.dart';

/// This class represents a PC2.0 [block](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#block) tag.
@collection
class Block {
  Block({
    required this.block,
    this.blockId,
  });

  factory Block.fromFeed(feed.Block block) {
    return Block(
      block: block.block,
      blockId: block.id,
    );
  }

  Id? id;
  final bool block;
  final String? blockId;
}
