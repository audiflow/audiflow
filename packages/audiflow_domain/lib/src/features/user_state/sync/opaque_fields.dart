import 'package:isar_community/isar.dart';

import '../models/outbox_op.dart';
import 'proto_wire.dart';

/// Stores [fields] of [entity] [key] that this app version does not know,
/// as received, replacing what an older [hlc] left. Must run inside a
/// write transaction.
///
/// A later version that knows them applies them after an upgrade; until
/// then backups carry them.
Future<void> keepUnknownFields(
  Isar isar, {
  required String entity,
  required String key,
  required int hlc,
  required List<ProtoField> fields,
}) async {
  for (final field in fields) {
    final existing = await isar.opaqueFields.getByEntityKeyFieldId(
      entity,
      key,
      field.fieldNumber,
    );
    if (existing != null && hlc <= existing.hlc) continue;
    await isar.opaqueFields.put(
      (existing ?? OpaqueField())
        ..entity = entity
        ..key = key
        ..fieldId = field.fieldNumber
        ..hlc = hlc
        ..payload = field.encode(),
    );
  }
}
