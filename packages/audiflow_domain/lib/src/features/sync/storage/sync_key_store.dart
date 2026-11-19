import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../protocol/sync_messages.dart';

/// What this device holds about its own enrollment: everything that must
/// never leave it (plan P8).
class StoredSyncDevice {
  StoredSyncDevice({
    required this.deviceId,
    required this.name,
    required this.platform,
    required List<int> privateKey,
    this.token,
    this.dataKey,
  }) : privateKey = Uint8List.fromList(privateKey).asUnmodifiableView();

  /// The device id the enrollment was made with. A different current id
  /// means this record came from another install (the iOS Keychain
  /// outlives an uninstall), so the device enrolls again.
  final String deviceId;
  final String name;
  final String platform;

  /// The X25519 private key; its public half is registered with the relay.
  final Uint8List privateKey;

  /// Null until the relay accepted the device.
  final String? token;
  final DataKey? dataKey;

  StoredSyncDevice copyWith({String? token, DataKey? dataKey}) =>
      StoredSyncDevice(
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
    'deviceId': deviceId,
    'name': name,
    'platform': platform,
    'privateKey': encodeBytes(privateKey),
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
    return StoredSyncDevice(
      deviceId: str('deviceId'),
      name: str('name'),
      platform: str('platform'),
      privateKey: decodeBytes(str('privateKey')),
      token: token is String ? token : null,
      dataKey: dataKey is String && version is int
          ? DataKey(decodeBytes(dataKey), version: version)
          : null,
    );
  }

  // Never prints secrets.
  @override
  String toString() => 'StoredSyncDevice($deviceId)';
}

/// Keeps the sync secrets (plan P8).
///
/// The credentials (account id and sync key) may follow the user to a new
/// device through the platform's own encrypted channel; everything in
/// [StoredSyncDevice] stays on this one.
abstract interface class SyncKeyStore {
  Future<SyncCredentials?> readCredentials();
  Future<void> writeCredentials(SyncCredentials credentials);
  Future<StoredSyncDevice?> readDevice();
  Future<void> writeDevice(StoredSyncDevice device);

  /// Forgets everything: sync is off on this device.
  Future<void> clear();
}

/// [SyncKeyStore] on `flutter_secure_storage`.
///
/// iOS: the Keychain, readable after the first unlock so background
/// playback can sync. The credentials are synchronizable, so iCloud
/// Keychain brings them to the user's other devices (C2); the device
/// record is `ThisDeviceOnly`.
///
/// Android: values encrypted with keys in the Android Keystore. The
/// backup rules exclude the storage file, since a restored copy could not
/// be decrypted without those keys. Carrying the credentials to a new
/// phone through Block Store comes separately.
class SecureSyncKeyStore implements SyncKeyStore {
  SecureSyncKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const credentialsKey = 'audiflow_sync_credentials';
  static const deviceKey = 'audiflow_sync_device';

  static const _synced = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );
  static const _deviceOnly = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  @override
  Future<SyncCredentials?> readCredentials() async {
    final text = await _storage.read(key: credentialsKey, iOptions: _synced);
    if (text == null) return null;
    return PairingCodec.decodeQr(text);
  }

  @override
  Future<void> writeCredentials(SyncCredentials credentials) => _storage.write(
    key: credentialsKey,
    value: PairingCodec.encodeQr(credentials),
    iOptions: _synced,
  );

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
  Future<void> clear() async {
    await _storage.delete(key: deviceKey, iOptions: _deviceOnly);
    await _storage.delete(key: credentialsKey, iOptions: _synced);
  }
}
