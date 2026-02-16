import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Screen for configuring feed sync settings: auto-sync,
/// sync interval, and WiFi-only sync.
class FeedSyncSettingsScreen extends ConsumerWidget {
  const FeedSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final autoSync = repo.getAutoSync();
    final interval = repo.getSyncIntervalMinutes();
    final wifiOnly = repo.getWifiOnlySync();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFeedSyncTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.feedSyncAutoSyncTitle),
            subtitle: Text(l10n.feedSyncAutoSyncSubtitle),
            value: autoSync,
            onChanged: (v) => _update(ref, () => repo.setAutoSync(v)),
          ),
          Visibility(
            visible: autoSync,
            child: ListTile(
              title: Text(l10n.feedSyncInterval),
              trailing: DropdownButton<int>(
                value: interval,
                onChanged: (v) {
                  if (v != null) {
                    _update(ref, () => repo.setSyncIntervalMinutes(v));
                  }
                },
                items: [
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
                    value: 240,
                    child: Text(l10n.feedSyncInterval4hours),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.feedSyncWifiOnlyTitle),
            subtitle: Text(l10n.feedSyncWifiOnlySubtitle),
            value: wifiOnly,
            onChanged: (v) => _update(ref, () => repo.setWifiOnlySync(v)),
          ),
        ],
      ),
    );
  }

  void _update(WidgetRef ref, Future<void> Function() setter) {
    setter();
    ref.invalidate(appSettingsRepositoryProvider);
  }
}
