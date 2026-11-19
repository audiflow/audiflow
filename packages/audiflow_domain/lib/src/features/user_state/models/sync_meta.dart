import 'package:isar_community/isar.dart';

part 'sync_meta.g.dart';

/// The single row of bookkeeping for this device's copy of the user data.
///
/// The server cursor joins when sync (M6) lands.
@collection
class SyncMeta {
  /// The only row's id.
  static const singletonId = 1;

  Id id = singletonId;

  /// Names the lineage of this user data: created when a device starts with
  /// empty data, and inherited by every copy of it.
  late String historyId;

  /// Copy of this device's id from device-only storage, recorded at launch.
  ///
  /// Attributes per-device counters to this device. Restore detection (M5)
  /// compares it with device-only storage to tell a restored copy apart.
  /// Null until the first foreground launch records it.
  String? deviceId;

  /// The latest [Hlc] this device issued or observed, as `Hlc.packed`.
  ///
  /// Stored rather than kept in memory so the clock stays monotonic across
  /// restarts and across isolates writing the same database.
  int hlc = 0;

  /// The HLC up to which tombstones were purged, as `Hlc.packed`; 0 while
  /// none has been. Within one history, a set element unknown here and
  /// added before it was deleted, and its tombstone is gone.
  int tombstoneHorizon = 0;

  /// The last `DataMigrationStep.version` that completed.
  int schemaVersion = 0;

  /// A restore left queue entries out because their episodes were not
  /// fetched yet; the next feed sync projects the queue again.
  bool queueProjectionPending = false;

  /// [hlc] as it was when the continuity snapshot was last written; 0 when
  /// none was. The snapshot is rewritten only once [hlc] has moved on.
  int lastSnapshotHlc = 0;

  /// A launch restore of the continuity snapshot started and has not yet
  /// rebuilt the library. The merge commits before the rebuild, so without
  /// this mark a crash between the two leaves data that no longer looks
  /// empty, and no later launch would restore again.
  bool continuityRestorePending = false;
}
