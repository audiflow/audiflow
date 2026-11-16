import 'package:isar_community/isar.dart';

part 'outbox_op.g.dart';

/// A user state change not yet sent to other devices (M4 writes them; M6
/// sends them). One op per (entity, key, field): a newer change of the same
/// field replaces the pending op, so the outbox holds the latest value of
/// each changed field, not its history.
@collection
class OutboxOp {
  Id id = Isar.autoIncrement;

  /// A UUIDv7, so ops sort by when they were written.
  @Index(unique: true)
  late String opId;

  /// `EntitySpec.name`.
  @Index(
    unique: true,
    composite: [CompositeIndex('key'), CompositeIndex('fieldId')],
  )
  late String entity;

  late String key;

  late int fieldId;

  /// The field's packed HLC at this change.
  int hlc = 0;

  /// The entity message holding just this field, in protobuf wire form.
  List<byte> payload = [];
}

/// A field this app version does not know, kept as received so a later
/// version can apply it and backups include it.
@collection
class OpaqueField {
  Id id = Isar.autoIncrement;

  @Index(
    unique: true,
    composite: [CompositeIndex('key'), CompositeIndex('fieldId')],
  )
  late String entity;

  late String key;

  late int fieldId;

  int hlc = 0;

  /// The field in wire form, tag included.
  List<byte> payload = [];
}
