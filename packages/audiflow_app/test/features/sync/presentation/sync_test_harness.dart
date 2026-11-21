import 'dart:async';
import 'dart:io';

import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

class MemorySyncKeyStore implements SyncKeyStore {
  final synced = <String, SyncCredentials>{};
  StoredSyncDevice? device;
  bool optedOut = false;

  @override
  Future<SyncCredentials?> readCredentials(String accountId) async =>
      synced[accountId];

  @override
  Future<SyncCredentials?> readLatestCredentials() async =>
      synced.values.lastOrNull;

  @override
  Future<void> writeCredentials(SyncCredentials c) async =>
      synced[c.accountIdText] = c;

  @override
  Future<StoredSyncDevice?> readDevice() async => device;

  @override
  Future<void> writeDevice(StoredSyncDevice d) async => device = d;

  @override
  Future<void> deleteDevice() async => device = null;

  @override
  Future<bool> readOptedOut() async => optedOut;

  @override
  Future<void> writeOptedOut({required bool optedOut}) async =>
      this.optedOut = optedOut;
}

/// A controller that never connects: the app stays inactive, so screens
/// see `off` or `idle` only.
class SyncHarness {
  SyncHarness._(this.isar, this.store, this.controller, this._dir);

  /// Fetches the Isar core library. Call from `setUpAll`: widget tests
  /// replace the HTTP client with one that answers 400 to everything.
  static Future<void> initializeIsar() => HttpOverrides.runWithHttpOverrides(
    () => Isar.initializeIsarCore(download: true),
    _RealHttp(),
  );

  static Future<SyncHarness> open() async {
    final dir = await Directory.systemTemp.createTemp('sync_ui_');
    final isar = await Isar.open(
      isarSchemas,
      directory: dir.path,
      name: 'sync_ui_${DateTime.now().microsecondsSinceEpoch}',
    );
    final store = MemorySyncKeyStore();
    final controller = SyncController(
      isar: isar,
      store: store,
      relayUrl: Uri.parse('https://relay.example.com'),
      deviceId: () async => 'this-device',
      deviceName: 'Test phone',
      platform: 'ios',
      appVersion: () => '1.0.0',
      syncFeeds: (_) async {},
      logger: Logger(level: Level.off),
      openTransport: (_, _) => Completer<SyncTransport>().future,
    );
    await controller.load();
    return SyncHarness._(isar, store, controller, dir);
  }

  final Isar isar;
  final MemorySyncKeyStore store;
  final SyncController controller;
  final Directory _dir;

  Future<void> close() async {
    await controller.dispose();
    await isar.close(deleteFromDisk: true);
    await _dir.delete(recursive: true);
  }

  Widget app(String initial, List<RouteBase> routes) => ProviderScope(
    overrides: [
      syncRelayUrlProvider.overrideWithValue(
        Uri.parse('https://relay.example.com'),
      ),
      syncControllerProvider.overrideWithValue(controller),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(initialLocation: initial, routes: routes),
    ),
  );
}

class _RealHttp extends HttpOverrides {}
