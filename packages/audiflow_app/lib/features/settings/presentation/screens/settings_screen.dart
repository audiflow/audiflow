import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../sync/presentation/controllers/sync_view_providers.dart';
import '../../../sync/presentation/widgets/sync_labels.dart';

/// Main settings screen (redesign 4.8): a large title over three grouped
/// sections of category rows, each with an icon tile, title, one-line
/// subtitle, and a chevron.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final restricted = ref.watch(isRestrictedModeOnProvider);
    final unlocked = ref.watch(isUnlockedProvider);
    final hideDeveloper = restricted && !unlocked;
    // Checked first: a build without a relay never builds the controller.
    final syncPhase = ref.watch(syncRelayUrlProvider) == null
        ? SyncPhase.unavailable
        : ref.watch(syncStatusProvider).phase;

    SettingsRow row(IconData icon, String title, String subtitle, String path) {
      return SettingsRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: const SettingsTrailing.chevron(),
        onTap: () => context.go(path),
      );
    }

    GroupedSection group(List<Widget> rows) => GroupedSection(
      separatorIndent: SettingsRow.separatorIndentWithIcon,
      children: rows,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstants.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.only(bottom: Spacing.xl),
              children: [
                LargeTitle(l10n.settingsTitle),
                const SizedBox(height: Spacing.xs),
                group([
                  row(
                    Symbols.palette,
                    l10n.settingsAppearanceTitle,
                    l10n.settingsAppearanceSubtitle,
                    AppRoutes.settingsAppearance,
                  ),
                  row(
                    Symbols.play_circle,
                    l10n.settingsPlaybackTitle,
                    l10n.settingsPlaybackSubtitle,
                    AppRoutes.settingsPlayback,
                  ),
                  row(
                    Symbols.download,
                    l10n.settingsDownloadsTitle,
                    l10n.settingsDownloadsSubtitle,
                    AppRoutes.settingsDownloads,
                  ),
                  row(
                    Symbols.sync,
                    l10n.settingsFeedSyncTitle,
                    l10n.settingsFeedSyncSubtitle,
                    AppRoutes.settingsFeedSync,
                  ),
                ]),
                const SizedBox(height: Spacing.lg),
                group([
                  // Builds without a relay have nothing to sync with.
                  if (syncPhase != SyncPhase.unavailable)
                    row(
                      Symbols.devices,
                      l10n.settingsDeviceSyncTitle,
                      syncPhase == SyncPhase.off
                          ? l10n.settingsDeviceSyncSubtitle
                          : syncPhaseLabel(l10n, syncPhase),
                      AppRoutes.settingsDeviceSync,
                    ),
                  row(
                    Symbols.storage,
                    l10n.settingsStorageTitle,
                    l10n.settingsStorageSubtitle,
                    AppRoutes.settingsStorage,
                  ),
                  row(
                    Symbols.shield,
                    l10n.settingsPrivacyTitle,
                    l10n.settingsPrivacySubtitle,
                    AppRoutes.settingsPrivacy,
                  ),
                  row(
                    Symbols.lock,
                    l10n.settingsParentalControlTitle,
                    l10n.settingsParentalControlSubtitle,
                    AppRoutes.settingsParentalControl,
                  ),
                ]),
                const SizedBox(height: Spacing.lg),
                group([
                  row(
                    Symbols.school,
                    l10n.settingsGettingStartedTitle,
                    l10n.settingsGettingStartedSubtitle,
                    AppRoutes.settingsGettingStarted,
                  ),
                  if (!hideDeveloper)
                    row(
                      Symbols.code,
                      l10n.settingsDeveloperTitle,
                      l10n.settingsDeveloperSubtitle,
                      AppRoutes.settingsDeveloper,
                    ),
                  row(
                    Symbols.info,
                    l10n.settingsAboutTitle,
                    l10n.settingsAboutSubtitle,
                    AppRoutes.settingsAbout,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
