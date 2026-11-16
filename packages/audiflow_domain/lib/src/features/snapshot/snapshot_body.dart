import 'dart:typed_data';

import '../user_state/sync/proto_wire.dart';

// Snapshot { repeated Section sections = 1; }
// Section  { string entity = 1; repeated Row rows = 2; }
// Row      { string key = 1; bytes fields = 2; }
// `fields` is the entity message: every field wrapped in a Value carrying
// its HLC, followed by the fields this version keeps as opaque.
const _sectionField = 1;
const _entityField = 1;
const _rowField = 2;
const _keyField = 1;
const _fieldsField = 2;

/// One row of a snapshot: its key and its entity message.
class SnapshotRow {
  SnapshotRow(this.key, this.fields);

  final String key;
  final Uint8List fields;
}

/// The protobuf body of a snapshot file: rows grouped by entity name.
class SnapshotBody {
  SnapshotBody(this.sections);

  /// Rows by `EntitySpec.name`, in file order. Entities this version does
  /// not know are kept too, so their rows can be stored as opaque.
  final Map<String, List<SnapshotRow>> sections;

  Uint8List encode() {
    final out = ProtoWriter();
    for (final MapEntry(key: entity, value: rows) in sections.entries) {
      final section = ProtoWriter()..writeString(_entityField, entity);
      for (final row in rows) {
        final r = ProtoWriter()
          ..writeString(_keyField, row.key)
          ..writeBytes(_fieldsField, row.fields);
        section.writeBytes(_rowField, r.takeBytes());
      }
      out.writeBytes(_sectionField, section.takeBytes());
    }
    return out.takeBytes();
  }

  /// Throws [FormatException] on malformed input.
  static SnapshotBody decode(Uint8List bytes) {
    final sections = <String, List<SnapshotRow>>{};
    for (final s in readMessage(bytes)) {
      if (s.fieldNumber != _sectionField) continue;
      _expectBytes(s);
      String? entity;
      final rows = <SnapshotRow>[];
      for (final f in readMessage(s.raw)) {
        switch (f.fieldNumber) {
          case _entityField:
            _expectBytes(f);
            entity = f.asString;
          case _rowField:
            _expectBytes(f);
            rows.add(_decodeRow(f.raw));
        }
      }
      if (entity == null) throw const FormatException('section without entity');
      (sections[entity] ??= []).addAll(rows);
    }
    return SnapshotBody(sections);
  }

  static SnapshotRow _decodeRow(Uint8List bytes) {
    String? key;
    var fields = Uint8List(0);
    for (final f in readMessage(bytes)) {
      switch (f.fieldNumber) {
        case _keyField:
          _expectBytes(f);
          key = f.asString;
        case _fieldsField:
          _expectBytes(f);
          fields = f.raw;
      }
    }
    if (key == null) throw const FormatException('row without key');
    return SnapshotRow(key, fields);
  }

  static void _expectBytes(ProtoField f) {
    if (f.wireType == WireType.lengthDelimited) return;
    throw FormatException('field ${f.fieldNumber} is not length-delimited');
  }
}
