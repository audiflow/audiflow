import 'package:isar_community/isar.dart';

import '../models/hlc.dart';
import '../models/sync_meta.dart';
import 'sync_meta_access.dart';

/// The one entry point for writes to user state.
///
/// Each write runs in one Isar write transaction that also advances the
/// clock in [SyncMeta], and hands the body the [Hlc] stamp for that change.
/// Later steps write per-field timestamps and outbox ops from the stamp
/// inside the same transaction, so a change never exists without them.
///
/// The store keeps no state of its own: the clock lives in [SyncMeta] and
/// is read inside the transaction, which Isar serializes across isolates.
/// Any number of instances over one database therefore issue strictly
/// increasing stamps, and a datasource can create its own.
class UserStateStore {
  UserStateStore(this._isar, {int Function()? nowMillis, this._createHistoryId})
    : _nowMillis = nowMillis ?? _wallClock;

  final Isar _isar;
  final int Function() _nowMillis;
  final String Function()? _createHistoryId;

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;

  /// Runs [body] in one write transaction stamped with a new [Hlc].
  ///
  /// A failure in [body] rolls back the clock advance with the rest of the
  /// transaction.
  Future<T> write<T>(Future<T> Function(Hlc stamp) body) {
    return _isar.writeTxn(() async {
      final meta = await loadOrCreateSyncMeta(
        _isar,
        createHistoryId: _createHistoryId,
      );
      final stamp = Hlc.unpack(meta.hlc).send(_nowMillis());
      meta.hlc = stamp.packed;
      await _isar.syncMetas.put(meta);
      return body(stamp);
    });
  }
}
