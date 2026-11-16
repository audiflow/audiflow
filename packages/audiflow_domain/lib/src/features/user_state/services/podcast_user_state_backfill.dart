import 'package:isar_community/isar.dart';

import '../../subscription/models/subscriptions.dart';
import 'data_migration_runner.dart';
import 'podcast_user_state_access.dart';
import 'user_state_store.dart';

/// Copies per-podcast preferences of keyed podcasts into
/// `PodcastUserState` (M3).
///
/// Podcasts without a key yet are skipped; they are copied the moment
/// they get one (`assignStableKeys`). Sections the new row already holds
/// are left alone, so the step can be interrupted and run again.
class PodcastUserStateBackfill implements DataMigrationStep {
  const PodcastUserStateBackfill({this.batchSize = 100});

  /// Podcasts copied per transaction.
  final int batchSize;

  @override
  int get version => 2;

  @override
  String get name => 'podcast user state';

  @override
  Future<void> run(Isar isar) async {
    final store = UserStateStore(isar);
    final access = PodcastUserStateAccess(isar);
    final ids = await isar.subscriptions
        .filter()
        .podcastKeyIsNotNull()
        .idProperty()
        .findAll();
    for (var start = 0; start < ids.length; start += batchSize) {
      final end = ids.length < start + batchSize
          ? ids.length
          : start + batchSize;
      final batch = ids.sublist(start, end);
      await store.write((txn) async {
        for (final sub in await isar.subscriptions.getAll(batch)) {
          if (sub == null) continue;
          await access.copyLegacy(sub, txn);
        }
      });
    }
  }
}
