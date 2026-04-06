import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';

/// Screen for configuring download settings: WiFi-only,
/// auto-delete, and max concurrent downloads.
class DownloadsSettingsScreen extends ConsumerWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final wifiOnly = repo.getWifiOnlyDownload();
    final autoDelete = repo.getAutoDeletePlayed();
    final maxConcurrent = repo.getMaxConcurrentDownloads();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDownloadsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(AppLocalizations.of(context).downloadManageTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.settingsDownloadManagement),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.downloadsWifiOnlyTitle),
            subtitle: Text(l10n.downloadsWifiOnlySubtitle),
            value: wifiOnly,
            onChanged: (v) => _update(ref, () => repo.setWifiOnlyDownload(v)),
          ),
          SwitchListTile(
            title: Text(l10n.downloadsAutoDeleteTitle),
            subtitle: Text(l10n.downloadsAutoDeleteSubtitle),
            value: autoDelete,
            onChanged: (v) => _update(ref, () => repo.setAutoDeletePlayed(v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.downloadsMaxConcurrent,
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

  Future<void> _update(WidgetRef ref, Future<void> Function() setter) async {
    await setter();
    ref.invalidate(appSettingsRepositoryProvider);
  }
}
