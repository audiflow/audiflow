import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../feed/services/feed_sync_service.dart';
import '../../install_id/providers/install_id_providers.dart';
import '../../station/services/station_reconciler_service.dart';
import '../storage/sync_key_backup.dart';
import '../storage/sync_key_store.dart';
import '../transport/web_socket_transport.dart';
import 'sync_controller.dart';

part 'sync_providers.g.dart';

/// Build-time `--dart-define` key for the relay's base URL. Empty in a
/// build without one, which leaves sync unavailable.
const syncRelayUrlEnv = 'SYNC_RELAY_URL';

/// The relay this build syncs with, or null.
@Riverpod(keepAlive: true)
Uri? syncRelayUrl(Ref ref) {
  const value = String.fromEnvironment(syncRelayUrlEnv);
  if (value.isEmpty) return null;
  return Uri.parse(value);
}

@Riverpod(keepAlive: true)
SyncKeyStore syncKeyStore(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('SyncKeys'));
  return SecureSyncKeyStore(
    // iOS needs no backup: the synchronizable Keychain item travels.
    backup: Platform.isAndroid ? const BlockStoreSyncKeyBackup() : null,
    onBackupError: (e, stack) =>
        logger.w('Block Store unavailable', error: e, stackTrace: stack),
  );
}

/// The app's [SyncController]. The app calls `load` at startup and
/// `setActive` as it moves between foreground, playing, and background.
@Riverpod(keepAlive: true)
SyncController syncController(Ref ref) {
  final feedSync = ref.watch(feedSyncServiceProvider);
  final reconciler = ref.watch(stationReconcilerServiceProvider);
  final controller = SyncController(
    isar: ref.watch(isarProvider),
    store: ref.watch(syncKeyStoreProvider),
    relayUrl: ref.watch(syncRelayUrlProvider),
    deviceId: ref.watch(deviceIdRepositoryProvider).getOrCreate,
    // A generic name until the device list lets the user rename it.
    deviceName: Platform.isIOS ? 'iOS device' : 'Android device',
    platform: Platform.isIOS ? 'ios' : 'android',
    // Read per connection: package info is an app-start override.
    appVersion: () => ref.read(packageInfoProvider).version,
    syncFeeds: (urls) async {
      await feedSync.syncFeedsByUrls(urls);
    },
    onStationChanged: reconciler.onStationConfigChanged,
    logger: ref.watch(namedLoggerProvider('Sync')),
    openTransport: WebSocketTransport.connect,
  );
  ref.onDispose(controller.dispose);
  return controller;
}
