import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;
import 'package:cryptography/cryptography.dart';

/// Thrown when sealed bytes cannot be opened: damaged, forged, sealed for
/// another account or purpose, or under a key this device does not hold.
/// Carries no plaintext and no key material.
class SyncCryptoFailure implements Exception {
  const SyncCryptoFailure(this.reason);

  final String reason;

  @override
  String toString() => 'SyncCryptoFailure: $reason';
}

/// The secrets a sync key yields (plan P2, P3). Both sides of every device
/// derive the same values, so the derivation is pinned by a test.
class DerivedSyncKeys {
  const DerivedSyncKeys({required this.authSecret, required this.wrapKey});

  /// Sent once, over TLS, to enroll a device.
  final Uint8List authSecret;

  /// Opens the sync key wrap of the data key.
  final Uint8List wrapKey;
}

abstract final class SyncKeyDerivation {
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  static Future<DerivedSyncKeys> derive(Uint8List syncKey) async {
    Future<Uint8List> expand(String info) async {
      final key = await _hkdf.deriveKey(
        secretKey: SecretKey(syncKey),
        info: utf8.encode(info),
      );
      return Uint8List.fromList(await key.extractBytes());
    }

    return DerivedSyncKeys(
      authSecret: await expand('audiflow-sync auth v1'),
      wrapKey: await expand('audiflow-sync wrap v1'),
    );
  }

  /// What the relay stores to check [DerivedSyncKeys.authSecret]: a leaked
  /// relay database then does not let anyone enroll.
  static Uint8List authVerifier(Uint8List authSecret) =>
      Uint8List.fromList(hash.sha256.convert(authSecret).bytes);
}

/// What sealed bytes are for. Bound into the associated data, so bytes
/// sealed for one purpose never open as another (a key wrap replayed as a
/// frame, for example).
enum SealPurpose {
  frame(1),
  snapshot(2),
  presence(3),
  syncWrap(4),
  deviceWrap(5);

  const SealPurpose(this.code);

  final int code;
}

/// XChaCha20-Poly1305 sealing for one account (plan P4).
///
/// Layout: algId (1 byte), keyVersion (4 bytes, big endian), nonce (24),
/// ciphertext, tag (16). The associated data names the format, the
/// purpose, the account, the algorithm, and the key version, so none of
/// them can be swapped without the tag failing.
class SyncCipher {
  SyncCipher(this._accountId);

  final Uint8List _accountId;

  static const algXChaCha20Poly1305 = 1;
  static const _headerLength = 1 + 4;
  static const _nonceLength = 24;
  static const _tagLength = 16;
  static const keyLength = 32;
  static final _aead = Xchacha20.poly1305Aead();
  static final _random = Random.secure();

  /// A fresh random 256-bit key (data keys, device keys).
  static Uint8List generateKey() => _randomBytes(keyLength);

  /// The key version [sealed] was sealed under, read without opening it.
  static int keyVersionOf(Uint8List sealed) {
    if (sealed.length < _headerLength) {
      throw const SyncCryptoFailure('truncated');
    }
    return ByteData.sublistView(sealed).getUint32(1);
  }

  Future<Uint8List> seal({
    required Uint8List key,
    required int keyVersion,
    required SealPurpose purpose,
    required List<int> plaintext,
  }) async {
    final nonce = _randomBytes(_nonceLength);
    final box = await _aead.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: _aad(purpose, algXChaCha20Poly1305, keyVersion),
    );
    final header = ByteData(_headerLength)
      ..setUint8(0, algXChaCha20Poly1305)
      ..setUint32(1, keyVersion);
    return Uint8List.fromList([
      ...header.buffer.asUint8List(),
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// Opens [sealed] with the key [keyFor] returns for its key version.
  /// Throws a [SyncCryptoFailure] for anything that does not authenticate.
  Future<Uint8List> open(
    Uint8List sealed, {
    required SealPurpose purpose,
    required Uint8List? Function(int keyVersion) keyFor,
  }) async {
    if (sealed.length < _headerLength + _nonceLength + _tagLength) {
      throw const SyncCryptoFailure('truncated');
    }
    final view = ByteData.sublistView(sealed);
    final alg = view.getUint8(0);
    if (alg != algXChaCha20Poly1305) {
      throw SyncCryptoFailure('unknown algorithm $alg');
    }
    final keyVersion = view.getUint32(1);
    final key = keyFor(keyVersion);
    if (key == null) throw SyncCryptoFailure('no key for version $keyVersion');
    const bodyStart = _headerLength + _nonceLength;
    final tagStart = sealed.length - _tagLength;
    try {
      final clear = await _aead.decrypt(
        SecretBox(
          Uint8List.sublistView(sealed, bodyStart, tagStart),
          nonce: Uint8List.sublistView(sealed, _headerLength, bodyStart),
          mac: Mac(Uint8List.sublistView(sealed, tagStart)),
        ),
        secretKey: SecretKey(key),
        aad: _aad(purpose, alg, keyVersion),
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const SyncCryptoFailure('authentication failed');
    }
  }

  List<int> _aad(SealPurpose purpose, int alg, int keyVersion) {
    final version = ByteData(4)..setUint32(0, keyVersion);
    return [
      ...utf8.encode('audiflow-sync/1'),
      purpose.code,
      ..._accountId,
      alg,
      ...version.buffer.asUint8List(),
    ];
  }

  static Uint8List _randomBytes(int n) =>
      Uint8List.fromList(List.generate(n, (_) => _random.nextInt(256)));
}

/// The account's data key and its version; frames name the version they
/// were sealed under, so a device can still open frames from before a
/// rotation it holds the old key for.
class DataKey {
  DataKey(this.key, {required this.version}) {
    if (key.length != SyncCipher.keyLength) {
      throw ArgumentError.value(key.length, 'key', 'length');
    }
  }

  final Uint8List key;
  final int version;
}

/// What a device wrap carries: everything a remaining device needs after a
/// revocation replaced the sync key and the data key.
class DeviceSecrets {
  const DeviceSecrets({required this.syncKey, required this.dataKey});

  final Uint8List syncKey;
  final DataKey dataKey;
}

/// The data key sealed for whoever holds the sync key, and the sync key and
/// data key sealed for one device (plan P3).
abstract final class KeyWraps {
  static Future<Uint8List> sealSyncWrap(
    SyncCipher cipher, {
    required Uint8List wrapKey,
    required DataKey keys,
  }) => cipher.seal(
    key: wrapKey,
    keyVersion: keys.version,
    purpose: SealPurpose.syncWrap,
    plaintext: keys.key,
  );

  static Future<DataKey> openSyncWrap(
    SyncCipher cipher, {
    required Uint8List wrapKey,
    required Uint8List blob,
  }) async {
    final key = await cipher.open(
      blob,
      purpose: SealPurpose.syncWrap,
      keyFor: (_) => wrapKey,
    );
    return _dataKey(key, SyncCipher.keyVersionOf(blob));
  }

  static Future<Uint8List> sealDeviceWrap(
    SyncCipher cipher, {
    required Uint8List deviceKey,
    required Uint8List syncKey,
    required DataKey keys,
  }) => cipher.seal(
    key: deviceKey,
    keyVersion: keys.version,
    purpose: SealPurpose.deviceWrap,
    plaintext: [...syncKey, ...keys.key],
  );

  static Future<DeviceSecrets> openDeviceWrap(
    SyncCipher cipher, {
    required Uint8List deviceKey,
    required Uint8List blob,
  }) async {
    final clear = await cipher.open(
      blob,
      purpose: SealPurpose.deviceWrap,
      keyFor: (_) => deviceKey,
    );
    if (clear.length != 2 * SyncCipher.keyLength) {
      throw const SyncCryptoFailure('device wrap has the wrong length');
    }
    return DeviceSecrets(
      syncKey: Uint8List.fromList(clear.sublist(0, SyncCipher.keyLength)),
      dataKey: _dataKey(
        Uint8List.fromList(clear.sublist(SyncCipher.keyLength)),
        SyncCipher.keyVersionOf(blob),
      ),
    );
  }

  static DataKey _dataKey(Uint8List key, int version) {
    if (key.length != SyncCipher.keyLength) {
      throw const SyncCryptoFailure('data key has the wrong length');
    }
    return DataKey(key, version: version);
  }
}
