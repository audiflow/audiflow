import 'package:flutter/services.dart';

/// Small string values that never leave this device: not in OS backups, not
/// in device-to-device migration, not in iCloud Keychain.
///
/// iOS keeps them in the Keychain with a `ThisDeviceOnly` accessibility;
/// Android keeps them under `noBackupFilesDir`. See
/// docs/architecture/user-data-sync.md (device continuity).
///
/// iOS Keychain items outlive an app uninstall, so callers must not treat a
/// stored value as belonging to the current install on its own; see
/// `DeviceScopedIdStore`.
abstract interface class DeviceOnlyStore {
  /// Returns the value for [key], or null when none is stored.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value);
}

/// [DeviceOnlyStore] backed by the native `audiflow/device_only_store`
/// channel (iOS `AppDelegate`, Android `DeviceOnlyStoreChannel`).
///
/// The channel is registered on the main engine only, so this works in the
/// main isolate, not in background isolates.
class MethodChannelDeviceOnlyStore implements DeviceOnlyStore {
  const MethodChannelDeviceOnlyStore([
    this._channel = const MethodChannel(channelName),
  ]);

  static const channelName = 'audiflow/device_only_store';

  final MethodChannel _channel;

  @override
  Future<String?> read(String key) =>
      _channel.invokeMethod<String>('read', {'key': key});

  @override
  Future<void> write(String key, String value) =>
      _channel.invokeMethod<void>('write', {'key': key, 'value': value});
}
