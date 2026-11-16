import 'package:isar_community/isar.dart';

part 'queue_entry.g.dart';

/// One item of the play queue, named so every device refers to it the same
/// way (docs/architecture/user-data-sync.md, "Local storage").
///
/// `QueueItem` stays as the local copy the queue reads, holding local ids;
/// this row is what syncs. Each value carries the [Hlc] of its last change
/// (`*Hlc`, packed). A removed item stays as a row with [deleted] set, so
/// the removal can win a merge.
@collection
class QueueEntry {
  Id id = Isar.autoIncrement;

  /// A UUIDv7, so ids sort by creation time.
  @Index(unique: true)
  late String entryId;

  @Index()
  late String episodeKey;

  /// Sort key: entries order by [rank], then [entryId]. See
  /// `rankForPosition`.
  String rank = '';
  int rankHlc = 0;

  bool isAdhoc = false;
  int isAdhocHlc = 0;

  String? sourceContext;
  int sourceContextHlc = 0;

  /// When the item was added; never changes.
  DateTime? addedAt;

  bool deleted = false;
  int deletedHlc = 0;
}
