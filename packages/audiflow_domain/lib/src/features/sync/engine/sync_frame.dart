import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import '../../snapshot/snapshot_body.dart';
import '../../user_state/models/hlc.dart';
import '../../user_state/models/outbox_op.dart';
import '../../user_state/sync/proto_wire.dart';
import '../../user_state/sync/user_state_codec.dart';
import '../../user_state/sync/user_state_fields.dart';

/// One batch of ops as a sync frame carries it, before sealing (plan P5).
///
/// The rows are the snapshot body layout, each field with its clock, so a
/// receiver merges a frame with the same rules as a snapshot.
class SyncFrame {
  SyncFrame({
    required this.historyId,
    required this.deviceId,
    required this.sections,
  });

  final String historyId;
  final String deviceId;
  final Map<String, List<SnapshotRow>> sections;

  static const _historyField = 1;
  static const _deviceField = 2;
  static const _bodyField = 3;

  Uint8List encode() {
    final w = ProtoWriter()
      ..writeString(_historyField, historyId)
      ..writeString(_deviceField, deviceId)
      ..writeBytes(_bodyField, SnapshotBody(sections).encode());
    return w.takeBytes();
  }

  /// Throws [FormatException] for bytes that are not a frame.
  static SyncFrame decode(Uint8List bytes) {
    var historyId = '';
    var deviceId = '';
    var sections = <String, List<SnapshotRow>>{};
    for (final field in readMessage(bytes)) {
      if (field.wireType != WireType.lengthDelimited) continue;
      switch (field.fieldNumber) {
        case _historyField:
          historyId = field.asString;
        case _deviceField:
          deviceId = field.asString;
        case _bodyField:
          sections = SnapshotBody.decode(field.raw).sections;
      }
    }
    return SyncFrame(
      historyId: historyId,
      deviceId: deviceId,
      sections: sections,
    );
  }

  /// Builds a frame from [ops], one row per (entity, key).
  static SyncFrame fromOps(
    List<OutboxOp> ops, {
    required String historyId,
    required String deviceId,
  }) {
    final rows = <(String, String), ProtoWriter>{};
    for (final op in ops) {
      (rows[(op.entity, op.key)] ??= ProtoWriter()).writeRaw(
        fieldWithHlc(op.fieldId, op.payload, op.hlc),
      );
    }
    final sections = <String, List<SnapshotRow>>{};
    for (final MapEntry(key: (entity, key), value: w) in rows.entries) {
      (sections[entity] ??= []).add(SnapshotRow(key, w.takeBytes()));
    }
    return SyncFrame(
      historyId: historyId,
      deviceId: deviceId,
      sections: sections,
    );
  }
}

/// Each field received rows carry, with its clock and its Value bytes
/// without the clock.
Iterable<ReceivedField> receivedFields(
  Map<String, List<SnapshotRow>> sections,
) sync* {
  for (final MapEntry(key: entity, value: rows) in sections.entries) {
    for (final row in rows) {
      final List<ProtoField> fields;
      try {
        fields = readMessage(row.fields);
      } on FormatException {
        continue;
      }
      for (final f in fields) {
        if (f.wireType != WireType.lengthDelimited) continue;
        final int? hlc;
        final Uint8List value;
        try {
          hlc = decodeHlc(f.raw);
          value = withoutHlc(f.raw);
        } on FormatException {
          continue;
        }
        if (hlc == null) continue;
        yield (
          entity: entity,
          key: row.key,
          fieldId: f.fieldNumber,
          hlc: hlc,
          value: value,
        );
      }
    }
  }
}

typedef ReceivedField = ({
  String entity,
  String key,
  int fieldId,
  int hlc,
  Uint8List value,
});

/// Removes pending ops that received [fields] beat under the merge rules:
/// an older clock than the incoming one (clamped to [Hlc.maxDrift] ahead,
/// as the merge clamps it), or an equal one whose value does not sort
/// above. They would lose at every receiver, so sending them only costs
/// traffic. A local change newer than what arrived stays and goes out.
///
/// Grow-only counters merge by maximum, not by clock, so their pending ops
/// always stay: a larger local count must still reach the others.
Future<void> dropBeatenOps(
  Isar isar,
  Iterable<ReceivedField> fields, {
  required int nowMillis,
}) => isar.writeTxn(() async {
  // A field sent twice in a row merges as its last occurrence, so only
  // that one decides.
  final effective = {for (final f in fields) (f.entity, f.key, f.fieldId): f};
  for (final f in effective.values) {
    if (f.entity == UserStateEntities.episodeCounter.name) continue;
    final op = await isar.outboxOps.getByEntityKeyFieldId(
      f.entity,
      f.key,
      f.fieldId,
    );
    if (op == null) continue;
    final incoming = Hlc.unpack(f.hlc).clampedTo(nowMillis).packed;
    final beaten =
        op.hlc < incoming ||
        (op.hlc == incoming &&
            !sortsAbove(fieldValueBytes(op.payload), f.value));
    if (beaten) await isar.outboxOps.delete(op.id);
  }
});
