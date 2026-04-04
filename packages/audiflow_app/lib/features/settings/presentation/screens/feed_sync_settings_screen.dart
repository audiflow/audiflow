import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/background/background_task_registrar.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for configuring feed sync settings: auto-sync,
/// sync interval, WiFi-only sync, and new episode notifications.
class FeedSyncSettingsScreen extends ConsumerStatefulWidget {
  const FeedSyncSettingsScreen({super.key});

  @override
  ConsumerState<FeedSyncSettingsScreen> createState() =>
      _FeedSyncSettingsScreenState();
}

class _FeedSyncSettingsScreenState
    extends ConsumerState<FeedSyncSettingsScreen> {
  Future<void> _update(
    AppSettingsRepository repo,
    Future<void> Function() setter, {
    bool replaceExisting = false,
  }) async {
    await setter();
    ref.invalidate(appSettingsRepositoryProvider);
    await _updateBackgroundRegistration(repo, replaceExisting: replaceExisting);
  }

  // Use [replaceExisting] true when the scheduling parameters or background
  // behavior settings change (interval, wifi-only, notifications). Passing
  // true resets the periodic task timer, so avoid it for cosmetic changes.
  Future<void> _updateBackgroundRegistration(
    AppSettingsRepository repo, {
    bool replaceExisting = false,
  }) async {
    if (repo.getAutoSync()) {
      await BackgroundTaskRegistrar.register(
        intervalMinutes: repo.getSyncIntervalMinutes(),
        wifiOnly: repo.getWifiOnlySync(),
        inputData: BackgroundTaskRegistrar.buildInputData(repo),
        replaceExisting: replaceExisting,
      );
    } else {
      await BackgroundTaskRegistrar.cancel();
    }
  }

  Future<void> _onNotifyToggleChanged(
    AppSettingsRepository repo,
    bool enabled,
  ) async {
    if (!enabled) {
      await _update(
        repo,
        () => repo.setNotifyNewEpisodes(false),
        replaceExisting: true,
      );
      return;
    }

    final status = await Permission.notification.status;
    if (status.isGranted) {
      await _update(
        repo,
        () => repo.setNotifyNewEpisodes(true),
        replaceExisting: true,
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.notificationPermissionRequiredTitle),
          content: Text(l10n.notificationPermissionRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: Text(l10n.notificationPermissionOpenSettings),
            ),
          ],
        ),
      );
      return;
    }

    final result = await Permission.notification.request();
    if (result.isGranted) {
      await _update(
        repo,
        () => repo.setNotifyNewEpisodes(true),
        replaceExisting: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final autoSync = repo.getAutoSync();
    final interval = repo.getSyncIntervalMinutes();
    final wifiOnly = repo.getWifiOnlySync();
    final notifyNewEpisodes = repo.getNotifyNewEpisodes();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFeedSyncTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.feedSyncAutoSyncTitle),
            subtitle: Text(l10n.feedSyncAutoSyncSubtitle),
            value: autoSync,
            onChanged: (v) => _update(repo, () => repo.setAutoSync(v)),
          ),
          Visibility(
            visible: autoSync,
            child: ListTile(
              title: Text(l10n.feedSyncInterval),
              trailing: DropdownButton<int>(
                value: interval,
                onChanged: (v) {
                  if (v != null) {
                    _update(
                      repo,
                      () => repo.setSyncIntervalMinutes(v),
                      replaceExisting: true,
                    );
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: 15,
                    child: Text(l10n.feedSyncInterval15min),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text(l10n.feedSyncInterval30min),
                  ),
                  DropdownMenuItem(
                    value: 60,
                    child: Text(l10n.feedSyncInterval1hour),
                  ),
                  DropdownMenuItem(
                    value: 120,
                    child: Text(l10n.feedSyncInterval2hours),
                  ),
                  DropdownMenuItem(
                    value: 180,
                    child: Text(l10n.feedSyncInterval3hours),
                  ),
                  DropdownMenuItem(
                    value: 240,
                    child: Text(l10n.feedSyncInterval4hours),
                  ),
                  DropdownMenuItem(
                    value: 360,
                    child: Text(l10n.feedSyncInterval6hours),
                  ),
                  DropdownMenuItem(
                    value: 720,
                    child: Text(l10n.feedSyncInterval12hours),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.feedSyncWifiOnlyTitle),
            subtitle: Text(l10n.feedSyncWifiOnlySubtitle),
            value: wifiOnly,
            onChanged: (v) => _update(
              repo,
              () => repo.setWifiOnlySync(v),
              replaceExisting: true,
            ),
          ),
          Visibility(
            visible: autoSync,
            child: SwitchListTile(
              title: Text(l10n.feedSyncNotifyNewEpisodesTitle),
              subtitle: Text(l10n.feedSyncNotifyNewEpisodesSubtitle),
              value: notifyNewEpisodes,
              onChanged: (v) => _onNotifyToggleChanged(repo, v),
            ),
          ),
        ],
      ),
    );
  }
}
