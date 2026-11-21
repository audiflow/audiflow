import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../engine/sync_session.dart';
import '../protocol/sync_messages.dart';
import 'sync_key_backup.dart';

/// What this device holds about its own enrollment: everything that must
/// never leave it (plan P8).
class StoredSyncDevice {
  StoredSyncDevice({
    required this.accountId,
    required this.deviceId,
    required this.name,
    required this.platform,
    required List<int> privateKey,
    this.pendingOpening,
    this.token,
    this.dataKey,
  }) : privateKey = Uint8List.fromList(privateKey).asUnmodifiableView() {
    if (privateKey.length != SyncCipher.keyLength) {
      throw FormatException('device private key length ${privateKey.length}');
    }
  }

  /// The account this record enrolled with; credentials of another
  /// account never resume with it.
  final String accountId;

  /// The device id the enrollment was made with. A different current id
  /// means this record came from another install (the iOS Keychain
  /// outlives an uninstall), so the device enrolls again.
  final String deviceId;
  final String name;
  final String platform;

  /// The X25519 private key; its public half is registered with the relay.
  final Uint8List privateKey;

  /// How the device is to open until the relay hands out a token: a new
  /// account survives a restart before it reached the relay. Null once
  /// enrolled.
  final SyncOpening? pendingOpening;

  /// Null until the relay accepted the device.
  final String? token;
  final DataKey? dataKey;

  /// The record once the relay accepted the device.
  StoredSyncDevice enrolled({required String? token, DataKey? dataKey}) =>
      StoredSyncDevice(
        accountId: accountId,
        deviceId: deviceId,
        name: name,
        platform: platform,
        privateKey: privateKey,
        token: token ?? this.token,
        dataKey: dataKey ?? this.dataKey,
      );

  Future<SyncDevice> toSyncDevice() async => SyncDevice(
    deviceId: deviceId,
    name: name,
    platform: platform,
    publicKey: (await DeviceKeyPair.fromPrivateKey(privateKey)).publicKey,
  );

  String encode() => jsonEncode({
    'accountId': accountId,
    'deviceId': deviceId,
    'name': name,
    'platform': platform,
    'privateKey': encodeBytes(privateKey),
    if (pendingOpening case final o?) 'pendingOpening': o.name,
    'token': ?token,
    if (dataKey case final k?) ...{
      'dataKey': encodeBytes(k.key),
      'dataKeyVersion': k.version,
    },
  });

  /// Throws [FormatException] for anything that is not a stored record.
  static StoredSyncDevice decode(String text) {
    final json = jsonDecode(text);
    if (json is! Map<String, Object?>) {
      throw const FormatException('stored sync device is not an object');
    }
    String str(String key) => switch (json[key]) {
      final String v => v,
      _ => throw FormatException('stored sync device lacks $key'),
    };
    final dataKey = json['dataKey'];
    final version = json['dataKeyVersion'];
    final token = json['token'];
    final pending = json['pendingOpening'];
    return StoredSyncDevice(
      accountId: str('accountId'),
      deviceId: str('deviceId'),
      name: str('name'),
      platform: str('platform'),
      privateKey: decodeBytes(str('privateKey')),
      pendingOpening: SyncOpening.values
          .where((o) => o.name == pending)
          .firstOrNull,
      token: token is String ? token : null,
      dataKey: dataKey is String && version is int
          ? DataKey(decodeBytes(dataKey), version: version)
          : null,
    );
  }

  // Never prints secrets.
  @override
  String toString() => 'StoredSyncDevice($accountId, $deviceId)';
}

/// Keeps the sync keys (plan P8).
///
/// Credentials (account id and sync key) are kept per account and may
/// follow the user to their other devices through the platform's own
/// encrypted channel, so they are never deleted from one device: that
/// would turn sync off on the others. Turning sync off is this device's
/// own record: its [StoredSyncDevice] goes and an opt-out mark stays.
abstract interface class SyncKeyStore {
  /// The credentials of [accountId], or null.
  Future<SyncCredentials?> readCredentials(String accountId);

  /// The credentials stored last, for a device with no enrollment of its
  /// own (a new install the credentials reached), or null.
  Future<SyncCredentials?> readLatestCredentials();

  Future<void> writeCredentials(SyncCredentials credentials);

  Future<StoredSyncDevice?> readDevice();
  Future<void> writeDevice(StoredSyncDevice device);
  Future<void> deleteDevice();

  /// Sync was turned off on this device; credentials that arrive from
  /// other devices do not turn it on again.
  Future<bool> readOptedOut();
  Future<void> writeOptedOut({required bool optedOut});
}

/// [SyncKeyStore] on `flutter_secure_storage`.
///
/// iOS: the Keychain, readable after the first unlock so background
/// playback can sync. Credentials are synchronizable, so iCloud Keychain
/// brings them to the user's other devices (C2); the device record and the
/// opt-out mark are `ThisDeviceOnly`.
///
/// Android: values encrypted with keys in the Android Keystore. The
/// backup rules exclude the storage file, since a restored copy could not
/// be decrypted without those keys. Carrying the credentials to a new
/// phone through Block Store comes separately.
class SecureSyncKeyStore implements SyncKeyStore {
  SecureSyncKeyStore({
    this._storage = const FlutterSecureStorage(),
    this._backup,
    this._onBackupError,
  });

  final FlutterSecureStorage _storage;

  /// Mirrors the credentials, so a new install finds them when its own
  /// storage is empty. Best effort: without Play services, backup, or a
  /// screen lock it fails, and sync still works on this device.
  final SyncKeyBackup? _backup;
  final void Function(Object error, StackTrace stack)? _onBackupError;

  static const credentialsKeyPrefix = 'audiflow_sync_account_';
  static const deviceKey = 'audiflow_sync_device';
  static const optedOutKey = 'audiflow_sync_off';

  static const _synced = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );
  static const _deviceOnly = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  @override
  Future<SyncCredentials?> readCredentials(String accountId) async {
    final key = '$credentialsKeyPrefix$accountId';
    final text =
        await _storage.read(key: key, iOptions: _synced) ??
        (await _readBackup())[key];
    if (text == null) return null;
    return _StoredCredentials.decode(text).credentials;
  }

  @override
  Future<SyncCredentials?> readLatestCredentials() async {
    final all = [
      ...(await _storage.readAll(iOptions: _synced)).entries,
      ...(await _readBackup()).entries,
    ];
    _StoredCredentials? latest;
    for (final MapEntry(:key, :value) in all) {
      if (!key.startsWith(credentialsKeyPrefix)) continue;
      final _StoredCredentials stored;
      try {
        stored = _StoredCredentials.decode(value);
      } on FormatException {
        continue;
      }
      if (latest == null || latest.storedAt < stored.storedAt) latest = stored;
    }
    return latest?.credentials;
  }

  @override
  Future<void> writeCredentials(SyncCredentials credentials) async {
    final key = '$credentialsKeyPrefix${credentials.accountIdText}';
    final value = _StoredCredentials(
      credentials,
      DateTime.now().millisecondsSinceEpoch,
    ).encode();
    await _storage.write(key: key, value: value, iOptions: _synced);
    final backup = _backup;
    if (backup == null) return;
    try {
      await backup.write(key, value);
    } on Object catch (e, stack) {
      _onBackupError?.call(e, stack);
    }
  }

  Future<Map<String, String>> _readBackup() async {
    final backup = _backup;
    if (backup == null) return const {};
    try {
      return await backup.readAll();
    } on Object catch (e, stack) {
      _onBackupError?.call(e, stack);
      return const {};
    }
  }

  @override
  Future<StoredSyncDevice?> readDevice() async {
    final text = await _storage.read(key: deviceKey, iOptions: _deviceOnly);
    if (text == null) return null;
    return StoredSyncDevice.decode(text);
  }

  @override
  Future<void> writeDevice(StoredSyncDevice device) => _storage.write(
    key: deviceKey,
    value: device.encode(),
    iOptions: _deviceOnly,
  );

  @override
  Future<void> deleteDevice() =>
      _storage.delete(key: deviceKey, iOptions: _deviceOnly);

  @override
  Future<bool> readOptedOut() async =>
      await _storage.read(key: optedOutKey, iOptions: _deviceOnly) != null;

  @override
  Future<void> writeOptedOut({required bool optedOut}) => optedOut
      ? _storage.write(key: optedOutKey, value: '1', iOptions: _deviceOnly)
      : _storage.delete(key: optedOutKey, iOptions: _deviceOnly);
}

/// Credentials with the time they were stored, so a device with no
/// enrollment picks the account the user set up last.
class _StoredCredentials {
  const _StoredCredentials(this.credentials, this.storedAt);

  final SyncCredentials credentials;
  final int storedAt;

  String encode() => jsonEncode({
    'qr': PairingCodec.encodeQr(credentials),
    'storedAt': storedAt,
  });

  static _StoredCredentials decode(String text) {
    final json = jsonDecode(text);
    if (json case {'qr': final String qr, 'storedAt': final int at}) {
      return _StoredCredentials(PairingCodec.decodeQr(qr), at);
    }
    throw const FormatException('stored credentials malformed');
  }
}
