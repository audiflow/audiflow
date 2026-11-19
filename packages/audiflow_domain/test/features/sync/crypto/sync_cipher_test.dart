import 'dart:convert';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;

void main() {
  final accountId = Uint8List.fromList(List.generate(16, (i) => i));
  final otherAccount = Uint8List.fromList(List.generate(16, (i) => i + 1));
  final key = Uint8List.fromList(List.generate(32, (i) => i * 3));
  final payload = Uint8List.fromList(utf8.encode('position=1234'));

  group('SyncKeyDerivation', () {
    final syncKey = Uint8List.fromList(List.generate(32, (i) => i));

    test('derives distinct, stable auth and wrap secrets', () async {
      final a = await SyncKeyDerivation.derive(syncKey);
      final b = await SyncKeyDerivation.derive(syncKey);
      check(a.authSecret.length).equals(32);
      check(a.wrapKey.length).equals(32);
      check(a.authSecret).deepEquals(b.authSecret);
      check(a.authSecret).not((it) => it.deepEquals(a.wrapKey));
    });

    test('pins the derivation, which every device must agree on', () async {
      final keys = await SyncKeyDerivation.derive(syncKey);
      check(base64Url.encode(keys.authSecret)).equals(_pinnedAuthSecret);
      check(base64Url.encode(keys.wrapKey)).equals(_pinnedWrapKey);
    });

    test('the verifier is a hash of the auth secret', () async {
      final keys = await SyncKeyDerivation.derive(syncKey);
      final verifier = SyncKeyDerivation.authVerifier(keys.authSecret);
      check(verifier.length).equals(32);
      check(verifier).not((it) => it.deepEquals(keys.authSecret));
    });
  });

  group('SyncCipher', () {
    final cipher = SyncCipher(accountId);

    test('round-trips and records the key version', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 3,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      check(SyncCipher.keyVersionOf(sealed)).equals(3);
      final opened = await cipher.open(
        sealed,
        purpose: SealPurpose.frame,
        keyFor: (v) => v == 3 ? key : null,
      );
      check(opened).deepEquals(payload);
    });

    test('never reuses a nonce', () async {
      Future<Uint8List> seal() => cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      final a = await seal();
      final b = await seal();
      check(a).not((it) => it.deepEquals(b));
    });

    test('hides the plaintext', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      check(
        latin1.decode(sealed, allowInvalid: true),
      ).not((it) => it.contains('position'));
    });

    test('fails on a flipped bit', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      sealed[sealed.length - 1] ^= 1;
      await check(
        cipher.open(sealed, purpose: SealPurpose.frame, keyFor: (_) => key),
      ).throws<SyncCryptoFailure>();
    });

    test('fails in another account', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      await check(
        SyncCipher(
          otherAccount,
        ).open(sealed, purpose: SealPurpose.frame, keyFor: (_) => key),
      ).throws<SyncCryptoFailure>();
    });

    test('fails for another purpose', () async {
      // A wrap replayed as a frame must not open.
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.syncWrap,
        plaintext: payload,
      );
      await check(
        cipher.open(sealed, purpose: SealPurpose.frame, keyFor: (_) => key),
      ).throws<SyncCryptoFailure>();
    });

    test('fails when the key version is unknown or rewritten', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      await check(
        cipher.open(sealed, purpose: SealPurpose.frame, keyFor: (_) => null),
      ).throws<SyncCryptoFailure>();
      // The version is bound into the associated data.
      final relabeled = Uint8List.fromList(sealed)..[4] = 2;
      await check(
        cipher.open(relabeled, purpose: SealPurpose.frame, keyFor: (_) => key),
      ).throws<SyncCryptoFailure>();
    });

    test('fails on truncated input or an unknown algorithm', () async {
      final sealed = await cipher.seal(
        key: key,
        keyVersion: 1,
        purpose: SealPurpose.frame,
        plaintext: payload,
      );
      await check(
        cipher.open(
          Uint8List.sublistView(sealed, 0, 20),
          purpose: SealPurpose.frame,
          keyFor: (_) => key,
        ),
      ).throws<SyncCryptoFailure>();
      final unknownAlg = Uint8List.fromList(sealed)..[0] = 9;
      await check(
        cipher.open(unknownAlg, purpose: SealPurpose.frame, keyFor: (_) => key),
      ).throws<SyncCryptoFailure>();
    });
  });

  group('key wraps', () {
    final cipher = SyncCipher(accountId);
    final wrapKey = Uint8List.fromList(List.generate(32, (i) => 7 * i));
    final dataKey = Uint8List.fromList(List.generate(32, (i) => 100 + i));
    final syncKey = Uint8List.fromList(List.generate(32, (i) => 50 + i));

    test('the sync key wrap carries the data key', () async {
      final blob = await KeyWraps.sealSyncWrap(
        cipher,
        wrapKey: wrapKey,
        keys: DataKey(dataKey, version: 2),
      );
      final opened = await KeyWraps.openSyncWrap(
        cipher,
        wrapKey: wrapKey,
        blob: blob,
      );
      check(opened.key).deepEquals(dataKey);
      check(opened.version).equals(2);
    });

    test('a device wrap opens with the recipient private key', () async {
      final recipient = await DeviceKeyPair.generate();
      final blob = await KeyWraps.sealDeviceWrap(
        cipher,
        recipientPublicKey: recipient.publicKey,
        syncKey: syncKey,
        keys: DataKey(dataKey, version: 5),
      );
      // The stored private key alone rebuilds the pair.
      final restored = await DeviceKeyPair.fromPrivateKey(recipient.privateKey);
      check(restored.publicKey).deepEquals(recipient.publicKey);
      final opened = await KeyWraps.openDeviceWrap(
        cipher,
        keyPair: restored,
        blob: blob,
      );
      check(opened.syncKey).deepEquals(syncKey);
      check(opened.dataKey.key).deepEquals(dataKey);
      check(opened.dataKey.version).equals(5);
    });

    test('a device wrap does not open for another device', () async {
      final recipient = await DeviceKeyPair.generate();
      final other = await DeviceKeyPair.generate();
      final blob = await KeyWraps.sealDeviceWrap(
        cipher,
        recipientPublicKey: recipient.publicKey,
        syncKey: syncKey,
        keys: DataKey(dataKey, version: 1),
      );
      await check(
        KeyWraps.openDeviceWrap(cipher, keyPair: other, blob: blob),
      ).throws<SyncCryptoFailure>();
    });

    test('a device wrap with a swapped ephemeral key fails', () async {
      final recipient = await DeviceKeyPair.generate();
      final blob = await KeyWraps.sealDeviceWrap(
        cipher,
        recipientPublicKey: recipient.publicKey,
        syncKey: syncKey,
        keys: DataKey(dataKey, version: 1),
      );
      final swapped = Uint8List.fromList(blob)
        ..setRange(0, 32, (await DeviceKeyPair.generate()).publicKey);
      await check(
        KeyWraps.openDeviceWrap(cipher, keyPair: recipient, blob: swapped),
      ).throws<SyncCryptoFailure>();
    });

    test('a device wrap does not open as a sync key wrap', () async {
      final recipient = await DeviceKeyPair.generate();
      final blob = await KeyWraps.sealDeviceWrap(
        cipher,
        recipientPublicKey: recipient.publicKey,
        syncKey: syncKey,
        keys: DataKey(dataKey, version: 1),
      );
      await check(
        KeyWraps.openSyncWrap(cipher, wrapKey: wrapKey, blob: blob),
      ).throws<SyncCryptoFailure>();
    });
  });
}

// RFC 5869 HKDF-SHA256 with an empty salt, computed independently of the
// package (Python hmac). A change here means devices on different versions
// would no longer authenticate to, or read, the same account.
const _pinnedAuthSecret = 'I1800h2IUOhCQFJismprt1BolX3Wq1zNbi8j3r41yk0=';
const _pinnedWrapKey = 'borGTeBYWeH5xYKUBqQZGDFiFFQlS46Yj42evhv1BgA=';
