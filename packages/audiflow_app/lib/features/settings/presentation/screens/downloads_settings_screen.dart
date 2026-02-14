import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for configuring download settings: WiFi-only,
/// auto-delete, and max concurrent downloads.
class DownloadsSettingsScreen extends ConsumerWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appSettingsRepositoryProvider);
    final wifiOnly = repo.getWifiOnlyDownload();
    final autoDelete = repo.getAutoDeletePlayed();
    final maxConcurrent = repo.getMaxConcurrentDownloads();

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('WiFi-Only Downloads'),
            subtitle: const Text('Only download episodes over WiFi'),
            value: wifiOnly,
            onChanged: (v) => _update(ref, () => repo.setWifiOnlyDownload(v)),
          ),
          SwitchListTile(
            title: const Text('Auto-Delete After Played'),
            subtitle: const Text('Remove downloaded episodes after playback'),
            value: autoDelete,
            onChanged: (v) => _update(ref, () => repo.setAutoDeletePlayed(v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Max Concurrent Downloads',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('1')),
                      ButtonSegment(value: 2, label: Text('2')),
                      ButtonSegment(value: 3, label: Text('3')),
                    ],
                    selected: {maxConcurrent},
                    onSelectionChanged: (set) => _update(
                      ref,
                      () => repo.setMaxConcurrentDownloads(set.first),
                    ),
                  ),
                ),
              ],
            ),
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
