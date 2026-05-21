import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// Settings screen for developer-oriented preferences.
///
/// Shows a contribute link to the preset repo, a toggle for
/// developer info in episode detail, and a browsable list of
/// all presets.
class DeveloperSettingsScreen extends ConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devInfoEnabled = ref.watch(devShowDeveloperInfoProvider);
    final summaries = ref.watch(presetSummariesProvider);
    final schemaVersion = ref.watch(presetSchemaVersionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDeveloperTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          final repo = ref.read(presetConfigRepositoryProvider);
          final rootMeta = await repo.fetchRootMeta();
          await repo.reconcileCache(rootMeta.presets);
          repo.setPresetSummaries(rootMeta.presets);
          ref
              .read(presetSummariesProvider.notifier)
              .setSummaries(rootMeta.presets);
          ref
              .read(presetSchemaVersionProvider.notifier)
              .setSchemaVersion(rootMeta.schemaVersion);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Contribute link
            ListTile(
              title: Text(l10n.developerContributeLabel),
              subtitle: Text(
                l10n.developerContributeRepo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Symbols.open_in_new,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              onTap: () async {
                try {
                  final ok = await launchUrl(
                    Uri.parse(PresetUrls.repo),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) debugPrint('launchUrl returned false for repo URL');
                } on Exception catch (e) {
                  debugPrint('Failed to launch repo URL: $e');
                }
              },
            ),
            const Divider(height: 1),

            // Developer info toggle
            SwitchListTile(
              title: Text(l10n.developerShowInfoTitle),
              subtitle: Text(l10n.developerShowInfoSubtitle),
              value: devInfoEnabled,
              onChanged: (_) => unawaited(
                ref.read(devShowDeveloperInfoProvider.notifier).toggle(),
              ),
            ),
            const Divider(height: 1),

            // Pattern list header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.developerPatternsHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Pattern items
            ...summaries.map((summary) {
              final enabled = 0 < schemaVersion;
              return ListTile(
                title: Text(summary.displayName),
                dense: true,
                trailing: enabled
                    ? Icon(
                        Symbols.open_in_new,
                        size: 18,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: enabled
                    ? () async {
                        try {
                          final ok = await launchUrl(
                            Uri.parse(
                              PresetUrls.presetDir(
                                summary.id,
                                schemaVersion: schemaVersion,
                              ),
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                          if (!ok) {
                            debugPrint(
                              'launchUrl returned false for preset URL',
                            );
                          }
                        } on Exception catch (e) {
                          debugPrint('Failed to launch preset URL: $e');
                        }
                      }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
