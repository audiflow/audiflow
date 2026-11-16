import 'package:isar_community/isar.dart';

import '../../queue/models/queue_item.dart';
import 'data_migration_runner.dart';
import 'queue_entry_access.dart';
import 'user_state_store.dart';

/// Gives existing queue items their `QueueEntry` (M3).
///
/// Items whose episode has no key yet are skipped; they get an entry the
/// moment it gets one (`assignStableKeys`). Items that already have an
/// entry are rewritten only where they differ, so the step can be
/// interrupted and run again.
class QueueEntryBackfill implements DataMigrationStep {
  const QueueEntryBackfill();

  @override
  int get version => 4;

  @override
  String get name => 'queue entries';

  @override
  Future<void> run(Isar isar) async {
    // A queue is short; one transaction keeps its ranks consistent.
    await UserStateStore(isar).write((txn) async {
      final items = await isar.queueItems.where().findAll();
      await QueueEntryAccess(isar).saveAll(items, txn);
    });
  }
}
