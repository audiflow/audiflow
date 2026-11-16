import 'package:isar_community/isar.dart';

part 'sync_meta.g.dart';

/// The single row of bookkeeping for this device's copy of the user data.
///
/// Fields for the `deviceId` copy, the server cursor, and the tombstone
/// horizon join when the steps that use them land.
@collection
class SyncMeta {
  /// The only row's id.
  static const singletonId = 1;

  Id id = singletonId;

  /// Names the lineage of this user data: created when a device starts with
  /// empty data, and inherited by every copy of it.
  late String historyId;

  /// The latest [Hlc] this device issued or observed, as `Hlc.packed`.
  ///
  /// Stored rather than kept in memory so the clock stays monotonic across
  /// restarts and across isolates writing the same database.
  int hlc = 0;

  /// The last `DataMigrationStep.version` that completed.
  int schemaVersion = 0;
}
