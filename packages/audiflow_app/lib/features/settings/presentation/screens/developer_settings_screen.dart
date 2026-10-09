import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../utils/open_preset_url.dart';
import '../widgets/test_notifications_tile.dart';

/// Settings screen for developer-oriented preferences.
///
/// Shows a contribute link to the contribute guide, a toggle for
/// developer info in episode detail, a test-notification action outside
/// production, design components and haptics previews outside production,
/// and a browsable list of all presets.
class DeveloperSettingsScreen extends ConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devInfoEnabled = ref.watch(devShowDeveloperInfoProvider);
    final summaries = ref.watch(presetSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDeveloperTitle)),
      body: HapticRefreshIndicator(
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
              onTap: () => openPresetUrl(ref, PresetUrls.contribute),
            ),
            const Divider(height: 1),

            // Developer info toggle
            SwitchListTile(
              title: Text(l10n.developerShowInfoTitle),
              subtitle: Text(l10n.developerShowInfoSubtitle),
              value: devInfoEnabled,
              onChanged: HapticsScope.of(context).toggleHaptic(
                (_) => unawaited(
                  ref.read(devShowDeveloperInfoProvider.notifier).toggle(),
                ),
              ),
            ),
            const Divider(height: 1),

            // Debug aid for notification changes; not offered in production.
            if (FlavorConfig.current.flavor != Flavor.prod) ...[
              const TestNotificationsTile(),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.developerDesignGalleryTitle),
                subtitle: Text(l10n.developerDesignGallerySubtitle),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () => context.push(AppRoutes.settingsDesignGallery),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.developerHapticsCatalogTitle),
                subtitle: Text(l10n.developerHapticsCatalogSubtitle),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () => context.push(AppRoutes.settingsHapticsCatalog),
              ),
              const Divider(height: 1),
            ],

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
              return ListTile(
                title: Text(summary.displayName),
                dense: true,
                trailing: Icon(
                  Symbols.open_in_new,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                onTap: () =>
                    openPresetUrl(ref, PresetUrls.presetDir(summary.id)),
              );
            }),
          ],
        ),
      ),
    );
  }
}
