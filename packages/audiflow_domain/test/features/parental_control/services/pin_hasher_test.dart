import 'dart:convert';
import 'dart:typed_data';

import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinHasher', () {
    final hasher = PinHasher();

    test('generateSalt returns 16 random bytes; two calls differ', () {
      final a = hasher.generateSalt();
      final b = hasher.generateSalt();
      check(a.length).equals(16);
      check(b.length).equals(16);
      check(base64.encode(a)).not((s) => s.equals(base64.encode(b)));
    });

    test('hash is deterministic with same salt+pin+iterations', () {
      final salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final h1 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      final h2 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      check(base64.encode(h1)).equals(base64.encode(h2));
      check(h1.length).equals(32);
    });

    test('hash differs for different PINs', () {
      final salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final h1 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      final h2 = hasher.hash(pin: '1235', salt: salt, iterations: 1000);
      check(base64.encode(h1)).not((s) => s.equals(base64.encode(h2)));
    });

    test('verify returns true for correct PIN', () {
      final salt = hasher.generateSalt();
      final settings = ParentalControlSettings()
        ..pinHashBase64 = base64.encode(
          hasher.hash(pin: '4321', salt: salt, iterations: 1000),
        )
        ..pinSaltBase64 = base64.encode(salt)
        ..pinIterations = 1000;
      check(hasher.verify(pin: '4321', settings: settings)).isTrue();
    });

    test('verify returns false for wrong PIN', () {
      final salt = hasher.generateSalt();
      final settings = ParentalControlSettings()
        ..pinHashBase64 = base64.encode(
          hasher.hash(pin: '4321', salt: salt, iterations: 1000),
        )
        ..pinSaltBase64 = base64.encode(salt)
        ..pinIterations = 1000;
      check(hasher.verify(pin: '9999', settings: settings)).isFalse();
    });

    test('verify returns false when hash or salt is null', () {
      final settings = ParentalControlSettings();
      check(hasher.verify(pin: '1234', settings: settings)).isFalse();
    });
  });
}
