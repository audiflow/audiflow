import 'dart:convert';
import 'dart:typed_data';

/// The protobuf wire format, enough for user state ops and snapshots.
///
/// Hand-written instead of generated: the messages are built from the
/// field registry (`user_state_fields.dart`), so there is no `.proto` to
/// compile, and a reader must keep fields it does not know.
/// https://protobuf.dev/programming-guides/encoding/
abstract final class WireType {
  static const varint = 0;
  static const fixed64 = 1;
  static const lengthDelimited = 2;
  static const fixed32 = 5;
}

/// Builds one protobuf message.
class ProtoWriter {
  final BytesBuilder _out = BytesBuilder(copy: false);

  Uint8List takeBytes() => _out.takeBytes();

  void _tag(int fieldNumber, int wireType) =>
      _varint((fieldNumber << 3) | wireType);

  void _varint(int value) {
    // Dart ints are 64-bit; a negative value is written as its 10-byte
    // two's complement, as protobuf does for int64.
    var v = value;
    for (var i = 0; i < 10; i++) {
      final byte = v & 0x7f;
      v = v >>> 7;
      if (v == 0) {
        _out.addByte(byte);
        return;
      }
      _out.addByte(byte | 0x80);
    }
  }

  void writeInt(int fieldNumber, int value) {
    _tag(fieldNumber, WireType.varint);
    _varint(value);
  }

  /// Signed int in zigzag form (sint64), short for small negatives.
  void writeSint(int fieldNumber, int value) {
    _tag(fieldNumber, WireType.varint);
    _varint((value << 1) ^ (value >> 63));
  }

  void writeBool(int fieldNumber, {required bool value}) =>
      writeInt(fieldNumber, value ? 1 : 0);

  void writeDouble(int fieldNumber, double value) {
    _tag(fieldNumber, WireType.fixed64);
    final data = ByteData(8)..setFloat64(0, value, Endian.little);
    _out.add(data.buffer.asUint8List());
  }

  void writeBytes(int fieldNumber, List<int> value) {
    _tag(fieldNumber, WireType.lengthDelimited);
    _varint(value.length);
    _out.add(value);
  }

  void writeString(int fieldNumber, String value) =>
      writeBytes(fieldNumber, utf8.encode(value));

  /// Writes an already-encoded field (tag included) as is.
  void writeRaw(List<int> encodedField) => _out.add(encodedField);
}

/// One field read from a message, kept in its wire form so unknown fields
/// can be stored and written back unchanged.
class ProtoField {
  ProtoField(this.fieldNumber, this.wireType, this.raw);

  final int fieldNumber;
  final int wireType;

  /// The value bytes: the varint, the 8 or 4 fixed bytes, or the
  /// length-delimited payload (without its length).
  final Uint8List raw;

  int get asInt => _readVarint(raw, 0).value;

  int get asSint {
    final v = asInt;
    return (v >>> 1) ^ -(v & 1);
  }

  bool get asBool => asInt != 0;

  double get asDouble => ByteData.sublistView(raw).getFloat64(0, Endian.little);

  String get asString => utf8.decode(raw);

  /// The field written back in wire form, tag included.
  Uint8List encode() {
    final w = ProtoWriter();
    switch (wireType) {
      case WireType.varint:
        w.writeInt(fieldNumber, asInt);
      case WireType.lengthDelimited:
        w.writeBytes(fieldNumber, raw);
      default:
        w
          .._tag(fieldNumber, wireType)
          ..writeRaw(raw);
    }
    return w.takeBytes();
  }
}

/// Splits [bytes] into its fields, in order. Throws [FormatException] on
/// malformed input.
List<ProtoField> readMessage(Uint8List bytes) {
  final fields = <ProtoField>[];
  var pos = 0;
  while (pos < bytes.length) {
    final tag = _readVarint(bytes, pos);
    pos = tag.next;
    final fieldNumber = tag.value >>> 3;
    final wireType = tag.value & 7;
    if (fieldNumber == 0) throw const FormatException('field number 0');
    switch (wireType) {
      case WireType.varint:
        final start = pos;
        pos = _readVarint(bytes, pos).next;
        fields.add(
          ProtoField(fieldNumber, wireType, bytes.sublist(start, pos)),
        );
      case WireType.fixed64 || WireType.fixed32:
        final size = wireType == WireType.fixed64 ? 8 : 4;
        if (bytes.length < pos + size) {
          throw const FormatException('truncated fixed field');
        }
        fields.add(
          ProtoField(fieldNumber, wireType, bytes.sublist(pos, pos + size)),
        );
        pos += size;
      case WireType.lengthDelimited:
        final len = _readVarint(bytes, pos);
        pos = len.next;
        if (len.value < 0 || bytes.length < pos + len.value) {
          throw const FormatException('truncated length-delimited field');
        }
        fields.add(
          ProtoField(
            fieldNumber,
            wireType,
            bytes.sublist(pos, pos + len.value),
          ),
        );
        pos += len.value;
      default:
        throw FormatException('unsupported wire type $wireType');
    }
  }
  return fields;
}

({int value, int next}) _readVarint(Uint8List bytes, int start) {
  var result = 0;
  var shift = 0;
  var pos = start;
  while (true) {
    if (bytes.length <= pos) throw const FormatException('truncated varint');
    final byte = bytes[pos++];
    result |= (byte & 0x7f) << shift;
    if (byte & 0x80 == 0) return (value: result, next: pos);
    shift += 7;
    if (63 < shift) throw const FormatException('varint too long');
  }
}
