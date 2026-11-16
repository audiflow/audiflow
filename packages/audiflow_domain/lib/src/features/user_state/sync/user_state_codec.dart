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

/// Encodes [value] (null, int, double, bool, String, or DateTime) as a
/// Value message.
Uint8List encodeValue(Object? value) {
  final w = ProtoWriter();
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
    }
  }
  return value;
}

const _valueFields = {
  _intValue,
  _doubleValue,
  _stringValue,
  _boolValue,
  _timeValue,
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
  DecodedEntity(this.known, this.unknown);

  final Map<int, Object?> known;
  final List<ProtoField> unknown;
}

/// Splits an entity message of [entity] by what [UserStateEntities]
/// knows. A fieldId this version does not know, an entity it does not know
/// at all, or a value of a type it does not know lands in
/// [DecodedEntity.unknown].
DecodedEntity decodeEntity(String entity, Uint8List bytes) {
  final ids = UserStateEntities.registry[entity] ?? const <int, String>{};
  final known = <int, Object?>{};
  final unknown = <ProtoField>[];
  for (final field in readMessage(bytes)) {
    if (ids.containsKey(field.fieldNumber) &&
        field.wireType == WireType.lengthDelimited &&
        !_hasUnknownValueType(field.raw)) {
      known[field.fieldNumber] = decodeValue(field.raw);
    } else {
      unknown.add(field);
    }
  }
  return DecodedEntity(known, unknown);
}
