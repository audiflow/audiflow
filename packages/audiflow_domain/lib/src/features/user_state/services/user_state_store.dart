import 'dart:typed_data';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/hlc.dart';
import '../models/outbox_op.dart';
import '../models/sync_meta.dart';
import '../sync/proto_wire.dart';
import '../sync/user_state_codec.dart';
import '../sync/user_state_fields.dart';
import 'sync_meta_access.dart';

/// The one entry point for writes to user state.
///
/// Each write runs in one Isar write transaction that also advances the
/// clock in [SyncMeta], and hands the body a [UserStateTxn] carrying the
/// [Hlc] stamp for that change.
/// Rows the body changes are reported with [UserStateTxn.touch]; before
/// the transaction commits, the store writes an [OutboxOp] for each field
/// this write stamped, so a change never exists without its op.
///
/// The store keeps no state of its own: the clock lives in [SyncMeta] and
/// is read inside the transaction, which Isar serializes across isolates.
/// Any number of instances over one database therefore issue strictly
/// increasing stamps, and a datasource can create its own.
/// What a [UserStateStore.write] body needs to record its change.
class UserStateTxn {
  UserStateTxn({required this.stamp, required this.deviceId});

  /// Stamps every field this write changes.
  final Hlc stamp;

  /// This device's id for per-device counters, or [unknownDeviceId] before
  /// the first foreground launch recorded it.
  final String deviceId;

  /// Counters written before the device id is known. They still count in
  /// every sum; restore detection (M5) settles who wrote them.
  static const unknownDeviceId = '';

  final List<_Touched<Object?>> _touched = [];

  /// Reports that [row] of [entity] was written in this transaction, so
  /// the fields this write stamped get their ops.
  void touch<T>(EntitySpec<T> entity, T row) =>
      _touched.add(_Touched<T>(entity, row));

  /// Reports that a merge changed [fieldIds] of [row], keeping the clocks
  /// they arrived with, so the change reaches other devices.
  void touchMerged<T>(EntitySpec<T> entity, T row, Set<int> fieldIds) =>
      _touched.add(_Touched<T>(entity, row, only: fieldIds));

  final List<OutboxOp> _opaqueOps = [];

  /// Reports that a merge stored a field this version does not know, as
  /// [payload] (the field in wire form), so it reaches other devices too.
  void addOpaqueOp(
    String entity,
    String key,
    int fieldId,
    int hlc,
    List<int> payload,
  ) => _opaqueOps.add(
    OutboxOp()
      ..entity = entity
      ..key = key
      ..fieldId = fieldId
      ..hlc = hlc
      ..payload = payload,
  );
}

class _Touched<T> {
  _Touched(this.entity, this.row, {this.only});

  final EntitySpec<T> entity;
  final T row;

  /// The fields a merge changed; null for a local write, whose changed
  /// fields are the ones stamped with its HLC.
  final Set<int>? only;

  /// The ops for the fields stamped [stamp], and those without a clock.
  Iterable<OutboxOp> ops(int stamp, String Function() newOpId) sync* {
    final key = entity.key(row);
    for (final field in entity.fields) {
      final hlc = field.hlc?.call(row);
      final changed = only == null
          ? hlc == null || hlc == stamp
          : only!.contains(field.id);
      if (!changed) continue;
      yield OutboxOp()
        ..opId = newOpId()
        ..entity = entity.name
        ..key = key
        ..fieldId = field.id
        ..hlc = hlc ?? stamp
        ..payload = encodeField(field, row);
    }
  }
}

class UserStateStore {
  UserStateStore(
    this._isar, {
    int Function()? nowMillis,
    this._createHistoryId,
    String Function()? newOpId,
    this._outboxCap = outboxCap,
  }) : _nowMillis = nowMillis ?? _wallClock,
       _newOpId = newOpId ?? const Uuid().v7;

  final Isar _isar;
  final int Function() _nowMillis;
  final String Function()? _createHistoryId;

  /// A UUIDv7 by default.
  final String Function() _newOpId;
  final int _outboxCap;

  /// Most ops the outbox keeps; past it the oldest are dropped. Nothing
  /// sends ops before sync exists (M6), and turning sync on first uploads a
  /// full snapshot, so a dropped op loses nothing. Coalescing already keeps
  /// one op per changed field; the cap bounds a long-lived install that
  /// never syncs.
  static const outboxCap = 5000;

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;

  /// Runs [body] in one write transaction stamped with a new [Hlc].
  ///
  /// [body] must not start another transaction: Isar does not nest them.
  ///
  /// A failure in [body] rolls back the clock advance with the rest of the
  /// transaction.
  ///
  /// With [recordOps] false the touched rows get no ops: for copies of
  /// existing data (migration steps), which the first sync's snapshot
  /// carries.
  Future<T> write<T>(
    Future<T> Function(UserStateTxn txn) body, {
    bool recordOps = true,
  }) {
    return _isar.writeTxn(() async {
      final meta = await loadOrCreateSyncMeta(
        _isar,
        createHistoryId: _createHistoryId,
      );
      final stamp = Hlc.unpack(meta.hlc).send(_nowMillis());
      meta.hlc = stamp.packed;
      await _isar.syncMetas.put(meta);
      final txn = UserStateTxn(
        stamp: stamp,
        deviceId: meta.deviceId ?? UserStateTxn.unknownDeviceId,
      );
      final result = await body(txn);
      if (recordOps) await _writeOps(txn);
      return result;
    });
  }

  Future<void> _writeOps(UserStateTxn txn) async {
    if (txn._touched.isEmpty && txn._opaqueOps.isEmpty) return;
    final stamp = txn.stamp.packed;
    final ops = [
      for (final touched in txn._touched) ...touched.ops(stamp, _newOpId),
      for (final op in txn._opaqueOps) op..opId = _newOpId(),
    ];
    for (final op in ops) {
      // Coalesce: the newer change of a field replaces its pending op.
      final pending = await _isar.outboxOps.getByEntityKeyFieldId(
        op.entity,
        op.key,
        op.fieldId,
      );
      if (pending != null) {
        // A merge can bring an older clock than a pending local change of
        // the same field; that change must still go out.
        if (op.hlc < pending.hlc) continue;
        // Equal clocks: the larger value wins, as in a merge, whether each
        // side is a known field or one kept opaque.
        if (op.hlc == pending.hlc &&
            !_sortsAbove(op.payload, pending.payload)) {
          continue;
        }
        op.id = pending.id;
      }
      await _isar.outboxOps.put(op);
    }
    final excess = await _isar.outboxOps.count() - _outboxCap;
    if (excess <= 0) return;
    // Oldest by HLC: UUIDv7 ids from one millisecond, or written after the
    // wall clock moved back, do not sort in write order. Equal HLCs come
    // from one write, so which of them goes first does not matter.
    final oldest = await _isar.outboxOps
        .where()
        .sortByHlc()
        .limit(excess)
        .idProperty()
        .findAll();
    await _isar.outboxOps.deleteAll(oldest);
  }

  /// Whether field [a] carries a larger value than [b], comparing the Value
  /// bytes as a merge does (field tag and length aside).
  static bool _sortsAbove(List<int> a, List<int> b) {
    final x = _valueBytes(a);
    final y = _valueBytes(b);
    for (var i = 0; i < x.length && i < y.length; i++) {
      if (x[i] != y[i]) return y[i] < x[i];
    }
    return y.length < x.length;
  }

  static List<int> _valueBytes(List<int> field) {
    try {
      final parsed = readMessage(Uint8List.fromList(field));
      if (parsed.length == 1) return parsed.single.raw;
    } on FormatException {
      // Compared as is below.
    }
    return field;
  }
}
