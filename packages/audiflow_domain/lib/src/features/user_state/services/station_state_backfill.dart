import 'package:isar_community/isar.dart';

import '../../station/models/station.dart';
import '../../station/models/station_podcast.dart';
import 'data_migration_runner.dart';
import 'station_state_access.dart';
import 'user_state_store.dart';

/// Gives existing stations their `StationState` and their keyed podcasts
/// their `StationMember` (M3).
///
/// Links to podcasts without a key yet are recorded once the podcast is
/// keyed (`assignStableKeys`). Rows already recorded are rewritten only
/// where they differ, so the step can be interrupted and run again.
class StationStateBackfill implements DataMigrationStep {
  const StationStateBackfill();

  @override
  int get version => 5;

  @override
  String get name => 'station state';

  @override
  Future<void> run(Isar isar) async {
    // Stations are few; one transaction keeps them and their links together.
    await UserStateStore(isar).write((txn) async {
      final access = StationStateAccess(isar);
      await access.saveStations(await isar.stations.where().findAll(), txn);
      await access.saveMembers(
        await isar.stationPodcasts.where().findAll(),
        txn,
      );
      // Existing data travels with the first sync's snapshot instead.
    }, recordOps: false);
  }
}
