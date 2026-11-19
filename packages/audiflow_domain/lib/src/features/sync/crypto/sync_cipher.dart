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
    // HKDF accepts any input; a missing or cut key would still derive.
    if (syncKey.length != SyncCipher.keyLength) {
      throw ArgumentError.value(syncKey.length, 'syncKey', 'length');
    }
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
  /// Copies [accountId], so a caller reusing the buffer cannot change the
  /// associated data between sealing and opening.
  SyncCipher(List<int> accountId) : _accountId = Uint8List.fromList(accountId);

  final Uint8List _accountId;

  static const algXChaCha20Poly1305 = 1;
  static const _headerLength = 1 + 4;
  static const _nonceLength = 24;
  static const _tagLength = 16;
  static const keyLength = 32;
  static const maxKeyVersion = 0xFFFFFFFF;
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
    // The header holds 32 bits; a larger version would be cut silently.
    if (keyVersion < 0 || maxKeyVersion < keyVersion) {
      throw ArgumentError.value(keyVersion, 'keyVersion', 'out of range');
    }
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

/// A device's X25519 key pair. The private key never leaves device-only
/// storage; the public key is registered with the relay, so any other
/// device of the account can seal a device wrap to it (plan P3).
class DeviceKeyPair {
  const DeviceKeyPair._(this.privateKey, this.publicKey);

  static final _x25519 = X25519();

  static Future<DeviceKeyPair> generate() async =>
      _from(await _x25519.newKeyPair());

  /// Rebuilds the pair from the stored private key.
  static Future<DeviceKeyPair> fromPrivateKey(Uint8List privateKey) async {
    if (privateKey.length != SyncCipher.keyLength) {
      throw ArgumentError.value(privateKey.length, 'privateKey', 'length');
    }
    return _from(await _x25519.newKeyPairFromSeed(privateKey));
  }

  static Future<DeviceKeyPair> _from(SimpleKeyPair pair) async {
    final data = await pair.extract();
    return DeviceKeyPair._(
      Uint8List.fromList(data.bytes),
      Uint8List.fromList(data.publicKey.bytes),
    );
  }

  final Uint8List privateKey;
  final Uint8List publicKey;

  SimpleKeyPairData get _pair => SimpleKeyPairData(
    privateKey,
    publicKey: SimplePublicKey(publicKey, type: KeyPairType.x25519),
    type: KeyPairType.x25519,
  );
}

/// The data key sealed for whoever holds the sync key, and the sync key and
/// data key sealed to one device's public key (plan P3).
abstract final class KeyWraps {
  static final _x25519 = X25519();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static const _publicKeyLength = 32;

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

  /// Seals the secrets to [recipientPublicKey] with a fresh ephemeral key,
  /// whose public half leads the blob. Only the holder of the matching
  /// private key can open it, so the relay storing it learns nothing.
  static Future<Uint8List> sealDeviceWrap(
    SyncCipher cipher, {
    required Uint8List recipientPublicKey,
    required Uint8List syncKey,
    required DataKey keys,
  }) async {
    // Checked before sealing: a wrong length authenticates but the
    // recipient rejects it, after it was already published.
    if (syncKey.length != SyncCipher.keyLength) {
      throw ArgumentError.value(syncKey.length, 'syncKey', 'length');
    }
    final ephemeral = await DeviceKeyPair.generate();
    final key = await _sharedKey(
      ephemeral,
      remote: recipientPublicKey,
      ephemeralPublic: ephemeral.publicKey,
      recipientPublic: recipientPublicKey,
    );
    final sealed = await cipher.seal(
      key: key,
      keyVersion: keys.version,
      purpose: SealPurpose.deviceWrap,
      plaintext: [...syncKey, ...keys.key],
    );
    return Uint8List.fromList([...ephemeral.publicKey, ...sealed]);
  }

  static Future<DeviceSecrets> openDeviceWrap(
    SyncCipher cipher, {
    required DeviceKeyPair keyPair,
    required Uint8List blob,
  }) async {
    if (blob.length < _publicKeyLength) {
      throw const SyncCryptoFailure('truncated');
    }
    final ephemeralPublic = Uint8List.sublistView(blob, 0, _publicKeyLength);
    final sealed = Uint8List.sublistView(blob, _publicKeyLength);
    final key = await _sharedKey(
      keyPair,
      remote: ephemeralPublic,
      ephemeralPublic: ephemeralPublic,
      recipientPublic: keyPair.publicKey,
    );
    final clear = await cipher.open(
      sealed,
      purpose: SealPurpose.deviceWrap,
      keyFor: (_) => key,
    );
    if (clear.length != 2 * SyncCipher.keyLength) {
      throw const SyncCryptoFailure('device wrap has the wrong length');
    }
    return DeviceSecrets(
      syncKey: Uint8List.fromList(clear.sublist(0, SyncCipher.keyLength)),
      dataKey: _dataKey(
        Uint8List.fromList(clear.sublist(SyncCipher.keyLength)),
        SyncCipher.keyVersionOf(sealed),
      ),
    );
  }

  /// Both public keys go into the derivation, so a wrap cannot be passed
  /// off as sealed to another device or by another ephemeral key.
  static Future<Uint8List> _sharedKey(
    DeviceKeyPair own, {
    required Uint8List remote,
    required Uint8List ephemeralPublic,
    required Uint8List recipientPublic,
  }) async {
    if (remote.length != _publicKeyLength) {
      throw const SyncCryptoFailure('public key has the wrong length');
    }
    final shared = await _x25519.sharedSecretKey(
      keyPair: own._pair,
      remotePublicKey: SimplePublicKey(remote, type: KeyPairType.x25519),
    );
    final derived = await _hkdf.deriveKey(
      secretKey: shared,
      info: [
        ...utf8.encode('audiflow-sync device wrap v1'),
        ...ephemeralPublic,
        ...recipientPublic,
      ],
    );
    return Uint8List.fromList(await derived.extractBytes());
  }

  static DataKey _dataKey(Uint8List key, int version) {
    if (key.length != SyncCipher.keyLength) {
      throw const SyncCryptoFailure('data key has the wrong length');
    }
    return DataKey(key, version: version);
  }
}
