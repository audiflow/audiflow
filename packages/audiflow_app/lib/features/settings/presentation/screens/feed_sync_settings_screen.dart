import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for configuring feed sync settings: auto-sync,
/// sync interval, and WiFi-only sync.
class FeedSyncSettingsScreen extends ConsumerWidget {
  const FeedSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appSettingsRepositoryProvider);
    final autoSync = repo.getAutoSync();
    final interval = repo.getSyncIntervalMinutes();
    final wifiOnly = repo.getWifiOnlySync();

    return Scaffold(
      appBar: AppBar(title: const Text('Feed Sync')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Auto-Sync'),
            subtitle: const Text('Automatically refresh podcast feeds'),
            value: autoSync,
            onChanged: (v) => _update(ref, () => repo.setAutoSync(v)),
          ),
          Visibility(
            visible: autoSync,
            child: ListTile(
              title: const Text('Sync Interval'),
              trailing: DropdownButton<int>(
                value: interval,
                onChanged: (v) {
                  if (v != null) {
                    _update(ref, () => repo.setSyncIntervalMinutes(v));
                  }
                },
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 min')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                  DropdownMenuItem(value: 120, child: Text('2 hours')),
                  DropdownMenuItem(value: 240, child: Text('4 hours')),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('WiFi-Only Sync'),
            subtitle: const Text('Only sync feeds over WiFi'),
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
