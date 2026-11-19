import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;

void main() {
  final credentials = SyncCredentials(
    accountId: Uint8List.fromList(List.generate(16, (i) => i)),
    syncKey: Uint8List.fromList(List.generate(32, (i) => 255 - i)),
  );

  group('SyncCredentials', () {
    test('generates fresh random ids and keys', () {
      final a = SyncCredentials.generate();
      final b = SyncCredentials.generate();
      check(a.accountId.length).equals(16);
      check(a.syncKey.length).equals(32);
      check(a.accountId).not((it) => it.deepEquals(b.accountId));
      check(a.syncKey).not((it) => it.deepEquals(b.syncKey));
    });

    test('rejects ids and keys of the wrong length', () {
      check(
        () => SyncCredentials(accountId: Uint8List(15), syncKey: Uint8List(32)),
      ).throws<ArgumentError>();
      check(
        () => SyncCredentials(accountId: Uint8List(16), syncKey: Uint8List(31)),
      ).throws<ArgumentError>();
    });
  });

  group('QR payload', () {
    test('round-trips', () {
      final text = PairingCodec.encodeQr(credentials);
      check(text).startsWith('audiflow-sync:1:');
      check(PairingCodec.decodeQr(text)).equals(credentials);
    });

    test('rejects another scheme, version, or length', () {
      final body = PairingCodec.encodeQr(credentials).split(':').last;
      for (final text in [
        'https://example.com',
        'audiflow-sync:2:$body',
        'audiflow-sync:1:${body.substring(4)}',
        'audiflow-sync:1:!!!',
      ]) {
        check(() => PairingCodec.decodeQr(text)).throws<FormatException>();
      }
    });
  });

  group('recovery code', () {
    test('is 20 groups of 4 Crockford base32 characters', () {
      final code = PairingCodec.encodeRecoveryCode(credentials);
      final groups = code.split('-');
      check(groups.length).equals(20);
      for (final g in groups) {
        check(g).matchesPattern(RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}$'));
      }
    });

    test('round-trips', () {
      final code = PairingCodec.encodeRecoveryCode(credentials);
      check(PairingCodec.decodeRecoveryCode(code)).equals(credentials);
    });

    test('accepts lower case, spaces, and look-alike letters', () {
      final code = PairingCodec.encodeRecoveryCode(credentials);
      final typed = code
          .toLowerCase()
          .replaceAll('-', ' ')
          .replaceAll('0', 'o')
          .replaceAll('1', 'l');
      check(PairingCodec.decodeRecoveryCode(typed)).equals(credentials);
    });

    test('rejects a mistyped character', () {
      final code = PairingCodec.encodeRecoveryCode(credentials);
      final wrong = (code[0] == 'A' ? 'B' : 'A') + code.substring(1);
      check(
        () => PairingCodec.decodeRecoveryCode(wrong),
      ).throws<FormatException>();
    });

    test('rejects a short or foreign code', () {
      final code = PairingCodec.encodeRecoveryCode(credentials);
      check(
        () => PairingCodec.decodeRecoveryCode(code.substring(5)),
      ).throws<FormatException>();
      check(
        () => PairingCodec.decodeRecoveryCode('U' * 80),
      ).throws<FormatException>();
    });
  });
}
