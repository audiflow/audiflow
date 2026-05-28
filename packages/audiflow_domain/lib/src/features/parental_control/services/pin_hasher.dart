import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../models/parental_control_settings.dart';

class PinHasher {
  PinHasher({Random? secureRandom}) : _random = secureRandom ?? Random.secure();

  final Random _random;

  Uint8List generateSalt({int length = 16}) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256.
  /// Returns 32-byte derived key.
  Uint8List hash({
    required String pin,
    required Uint8List salt,
    required int iterations,
  }) {
    final pinBytes = utf8.encode(pin);
    final hmac = Hmac(sha256, pinBytes);

    const blockSize = 32; // sha256 output length
    const dkLen = 32;
    final blocks = (dkLen / blockSize).ceil();
    final out = BytesBuilder();

    for (var i = 1; i <= blocks; i++) {
      out.add(_pbkdf2Block(hmac, salt, iterations, i));
    }

    final bytes = out.toBytes();
    return bytes.sublist(0, dkLen);
  }

  Uint8List _pbkdf2Block(
    Hmac hmac,
    Uint8List salt,
    int iterations,
    int blockIndex,
  ) {
    final saltWithIndex = Uint8List(salt.length + 4)
      ..setRange(0, salt.length, salt)
      ..[salt.length] = (blockIndex >> 24) & 0xff
      ..[salt.length + 1] = (blockIndex >> 16) & 0xff
      ..[salt.length + 2] = (blockIndex >> 8) & 0xff
      ..[salt.length + 3] = blockIndex & 0xff;

    var u = Uint8List.fromList(hmac.convert(saltWithIndex).bytes);
    final result = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  bool verify({
    required String pin,
    required ParentalControlSettings settings,
  }) {
    final hashB64 = settings.pinHashBase64;
    final saltB64 = settings.pinSaltBase64;
    if (hashB64 == null || saltB64 == null) return false;

    final salt = base64.decode(saltB64);
    final computed = hash(
      pin: pin,
      salt: Uint8List.fromList(salt),
      iterations: settings.pinIterations,
    );
    final stored = base64.decode(hashB64);
    return _constantTimeEquals(computed, stored);
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
