import 'package:flutter/services.dart';

/// A second place for the account's sync key that outlives the app's own
/// storage: Block Store on Android, which carries it to a new phone and
/// through a reinstall (plan P8). iOS needs none; the synchronizable
/// Keychain item already travels.
abstract interface class SyncKeyBackup {
  Future<void> write(String key, String value);

  Future<Map<String, String>> readAll();
}

/// [SyncKeyBackup] over the app's `audiflow/block_store` channel
/// (`BlockStoreChannel.kt`).
class BlockStoreSyncKeyBackup implements SyncKeyBackup {
  const BlockStoreSyncKeyBackup([
    this._channel = const MethodChannel('audiflow/block_store'),
  ]);

  final MethodChannel _channel;

  @override
  Future<void> write(String key, String value) =>
      _channel.invokeMethod<void>('write', {'key': key, 'value': value});

  @override
  Future<Map<String, String>> readAll() async {
    final values = await _channel.invokeMapMethod<String, String>('readAll');
    return values ?? const {};
  }
}
