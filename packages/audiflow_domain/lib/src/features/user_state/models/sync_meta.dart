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
  @ignore
  int get lastSnapshotHlc => storedLastSnapshotHlc ?? 0;
  set lastSnapshotHlc(int value) => storedLastSnapshotHlc = value;

  // The `stored*` fields below came after the collection shipped. Isar
  // reads a non-null int missing from an older row as its null sentinel
  // (the smallest int64), not 0, so they are stored nullable and read
  // through a getter that defaults to 0. Not for use elsewhere.

  @Name('lastSnapshotHlc')
  int? storedLastSnapshotHlc;

  /// A launch restore of the continuity snapshot started and has not yet
  /// rebuilt the library. The merge commits before the rebuild, so without
  /// this mark a crash between the two leaves data that no longer looks
  /// empty, and no later launch would restore again.
  bool continuityRestorePending = false;

  /// The relay `seq` up to which this device has merged every frame, or
  /// the `seq` the snapshot it merged covers; 0 before sync was on.
  @ignore
  int get serverCursor => storedServerCursor ?? 0;
  set serverCursor(int value) => storedServerCursor = value;

  @Name('serverCursor')
  int? storedServerCursor;

  /// Requests to send the whole state, and the last request sent. A
  /// request is pending while [fullStateSent] is below
  /// [fullStateRequested]. The outbox cap raises it when it drops ops, and
  /// creating or joining raises it, so a resend interrupted by the app
  /// stopping is done again on the next connection. The engine records the
  /// request it exported only once the relay holds every frame, so a drop
  /// during the resend stays pending.
  @ignore
  int get fullStateRequested => storedFullStateRequested ?? 0;
  set fullStateRequested(int value) => storedFullStateRequested = value;

  @ignore
  int get fullStateSent => storedFullStateSent ?? 0;
  set fullStateSent(int value) => storedFullStateSent = value;

  @Name('fullStateRequested')
  int? storedFullStateRequested;

  @Name('fullStateSent')
  int? storedFullStateSent;
}
