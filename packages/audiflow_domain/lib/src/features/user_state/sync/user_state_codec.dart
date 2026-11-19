import 'dart:typed_data';

import 'proto_wire.dart';
import 'user_state_fields.dart';

// Field numbers of the Value message wrapping every field value, so a
// null still names its field. None set means null.
const _intValue = 1;
const _doubleValue = 2;
const _stringValue = 3;
const _boolValue = 4;
const _timeValue = 5;

/// The field's packed HLC, carried in snapshots, where every field travels
/// with its clock. Ops carry theirs on the op instead.
const _hlcValue = 15;

/// Encodes [value] (null, int, double, bool, String, or DateTime) as a
/// Value message, with its packed [hlc] when given.
Uint8List encodeValue(Object? value, {int? hlc}) {
  final w = ProtoWriter();
  if (hlc != null) w.writeInt(_hlcValue, hlc);
  switch (value) {
    case null:
      break;
    case final int v:
      w.writeSint(_intValue, v);
    case final double v:
      w.writeDouble(_doubleValue, v);
    case final String v:
      w.writeString(_stringValue, v);
    case final bool v:
      w.writeBool(_boolValue, value: v);
    case final DateTime v:
      w.writeSint(_timeValue, v.microsecondsSinceEpoch);
    default:
      throw ArgumentError.value(value, 'value', 'not a user state value');
  }
  return w.takeBytes();
}

/// Decodes a Value message; DateTimes come back in UTC. Throws
/// [FormatException] when a value has the wrong wire type.
///
/// As protobuf requires, the last occurrence wins when a value repeats.
Object? decodeValue(Uint8List bytes) {
  Object? value;
  for (final field in readMessage(bytes)) {
    switch (field.fieldNumber) {
      case _intValue:
        _expect(field, WireType.varint);
        value = field.asSint;
      case _doubleValue:
        _expect(field, WireType.fixed64);
        value = field.asDouble;
      case _stringValue:
        _expect(field, WireType.lengthDelimited);
        // Malformed UTF-8 throws FormatException too.
        value = field.asString;
      case _boolValue:
        _expect(field, WireType.varint);
        value = field.asBool;
      case _timeValue:
        _expect(field, WireType.varint);
        value = DateTime.fromMicrosecondsSinceEpoch(field.asSint, isUtc: true);
      case _hlcValue:
        _expect(field, WireType.varint);
    }
  }
  return value;
}

/// [bytes] (a Value message) without the HLC it carries, so a stored copy
/// is the same bytes whichever snapshot or op it came from.
/// Whether [a] sorts above [b] byte by byte, a longer run winning a shared
/// prefix: the tie-break for values whose clocks are equal.
bool sortsAbove(List<int> a, List<int> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return b[i] < a[i];
  }
  return b.length < a.length;
}

/// The Value bytes of a field in wire form, without its tag and length, so
/// a known field and one kept opaque compare the same way. Anything that
/// is not one length-delimited field comes back as is.
List<int> fieldValueBytes(List<int> field) {
  try {
    final parsed = readMessage(Uint8List.fromList(field));
    if (parsed.length == 1 &&
        parsed.single.wireType == WireType.lengthDelimited) {
      return parsed.single.raw;
    }
  } on FormatException {
    // Not a field; compared as is.
  }
  return field;
}

Uint8List withoutHlc(Uint8List bytes) {
  final w = ProtoWriter();
  for (final field in readMessage(bytes)) {
    if (field.fieldNumber != _hlcValue) w.writeRaw(field.encode());
  }
  return w.takeBytes();
}

/// The packed HLC a Value message carries, or null when it has none.
int? decodeHlc(Uint8List bytes) {
  int? hlc;
  for (final field in readMessage(bytes)) {
    if (field.fieldNumber != _hlcValue) continue;
    _expect(field, WireType.varint);
    hlc = field.asInt;
  }
  return hlc;
}

const _valueFields = {
  _intValue,
  _doubleValue,
  _stringValue,
  _boolValue,
  _timeValue,
  _hlcValue,
};

/// Whether a Value message uses a field number (a value type) this version
/// does not know.
bool _hasUnknownValueType(Uint8List bytes) =>
    readMessage(bytes).any((f) => !_valueFields.contains(f.fieldNumber));

void _expect(ProtoField field, int wireType) {
  if (field.wireType == wireType) return;
  throw FormatException(
    'value field ${field.fieldNumber} has wire type ${field.wireType}, '
    'expected $wireType',
  );
}

/// The entity message holding just [field] of [row].
Uint8List encodeField<T>(FieldSpec<T> field, T row) {
  final w = ProtoWriter()..writeBytes(field.id, encodeValue(field.value(row)));
  return w.takeBytes();
}

/// An entity message split into the fields this version knows (decoded
/// values by fieldId) and those it does not (kept in wire form).
class DecodedEntity {
  DecodedEntity(this.known, this.unknown, {this.hlcs = const {}});

  final Map<int, Object?> known;
  final List<ProtoField> unknown;

  /// The HLC each known field carried, where it carried one (snapshots).
  final Map<int, int> hlcs;
}

/// Splits an entity message of [entity] by what [UserStateEntities]
/// knows. A fieldId this version does not know, an entity it does not know
/// at all, or a value of a type it does not know lands in
/// [DecodedEntity.unknown].
DecodedEntity decodeEntity(String entity, Uint8List bytes) {
  final ids = UserStateEntities.registry[entity] ?? const <int, String>{};
  final known = <int, Object?>{};
  final hlcs = <int, int>{};
  final unknown = <ProtoField>[];
  for (final field in readMessage(bytes)) {
    if (ids.containsKey(field.fieldNumber) &&
        field.wireType == WireType.lengthDelimited &&
        !_hasUnknownValueType(field.raw)) {
      known[field.fieldNumber] = decodeValue(field.raw);
      final hlc = decodeHlc(field.raw);
      if (hlc != null) hlcs[field.fieldNumber] = hlc;
    } else {
      unknown.add(field);
    }
  }
  return DecodedEntity(known, unknown, hlcs: hlcs);
}

/// A field in wire form ([payload], as an op or an opaque field stores it)
/// with its packed [hlc] appended to the Value message, the way snapshot
/// rows and sync frames carry it, so a merge keeps the newer of two copies.
/// Appending merges into the message as protobuf defines; a payload that is
/// not one Value field goes as is.
///
/// Never throws: unknown data a merge accepted must not block a backup or
/// a send.
List<int> fieldWithHlc(int fieldId, List<int> payload, int hlc) {
  try {
    final parsed = readMessage(Uint8List.fromList(payload));
    if (parsed.length != 1 ||
        parsed.single.wireType != WireType.lengthDelimited) {
      return payload;
    }
    final value = ProtoWriter()
      ..writeRaw(withoutHlc(parsed.single.raw))
      ..writeRaw(encodeValue(null, hlc: hlc));
    return (ProtoWriter()..writeBytes(fieldId, value.takeBytes())).takeBytes();
  } on FormatException {
    return payload;
  }
}
