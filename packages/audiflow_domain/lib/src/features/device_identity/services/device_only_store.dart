import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Small string values that never leave this device: not in OS backups, not
/// in device-to-device migration, not in iCloud Keychain.
///
/// iOS keeps them in the Keychain with a `ThisDeviceOnly` accessibility;
/// Android keeps them in a directory the backup rules exclude. See
/// docs/architecture/user-data-sync.md (device continuity).
///
/// iOS Keychain items outlive an app uninstall, so callers must not treat a
/// stored value as belonging to the current install on its own; see
/// `DeviceScopedIdStore`.
abstract interface class DeviceOnlyStore {
  /// The store for the current platform.
  factory DeviceOnlyStore.platform() => Platform.isIOS
      ? const MethodChannelDeviceOnlyStore()
      : FileDeviceOnlyStore(
          () async => (await getApplicationSupportDirectory()).path,
        );

  /// Returns the value for [key], or null when none is stored.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value);
}

/// [DeviceOnlyStore] backed by the native `audiflow/device_only_store`
/// channel in the iOS `AppDelegate`, which uses the Keychain.
///
/// The channel is registered whenever the shared engine starts, whichever
/// scene (phone or CarPlay) starts it.
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

/// [DeviceOnlyStore] as one file per key under [directoryName], used on
/// Android.
///
/// On Android the resolved root is the app's `files/` directory, and
/// `data_extraction_rules.xml` / `full_backup_content.xml` exclude
/// `files/device_only_store/` from cloud backup and device transfer.
/// Plain Dart file access works in every engine, including the one
/// audio_service starts for Android Auto before any activity exists.
class FileDeviceOnlyStore implements DeviceOnlyStore {
  FileDeviceOnlyStore(this._resolveRoot);

  /// Must match the exclusion in the Android backup rules.
  static const directoryName = 'device_only_store';

  // Keys are fixed identifiers; anything else could escape the directory,
  // so it is rejected rather than escaped.
  static final _keyPattern = RegExp(r'^[a-z0-9_]{1,64}$');

  final Future<String> Function() _resolveRoot;

  @override
  Future<String?> read(String key) async {
    final file = await _file(key);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String key, String value) async {
    final file = await _file(key);
    await file.parent.create(recursive: true);
    // Through a temporary file, so a crash never leaves a partial id.
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(value, flush: true);
    await temp.rename(file.path);
  }

  Future<File> _file(String key) async {
    if (!_keyPattern.hasMatch(key)) {
      throw ArgumentError.value(key, 'key', 'must match $_keyPattern');
    }
    return File(p.join(await _resolveRoot(), directoryName, key));
  }
}
