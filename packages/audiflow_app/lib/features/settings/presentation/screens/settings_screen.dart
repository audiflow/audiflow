import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../widgets/settings_category_card.dart';

/// Main settings screen with category cards.
///
/// Displays a grid of setting categories that navigate
/// to their respective detail screens.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = ResponsiveGrid.columnCount(
            availableWidth: constraints.maxWidth,
            itemWidth: 180,
          );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LayoutConstants.contentMaxWidth * 1.5,
              ),
              child: GridView.count(
                crossAxisCount: columnCount,
                padding: const EdgeInsets.all(Spacing.md),
                mainAxisSpacing: Spacing.sm,
                crossAxisSpacing: Spacing.sm,
                childAspectRatio: 0.95,
                children: [
                  SettingsCategoryCard(
                    icon: Icons.palette,
                    title: l10n.settingsAppearanceTitle,
                    subtitle: l10n.settingsAppearanceSubtitle,
                    onTap: () => context.go(AppRoutes.settingsAppearance),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.play_circle,
                    title: l10n.settingsPlaybackTitle,
                    subtitle: l10n.settingsPlaybackSubtitle,
                    onTap: () => context.go(AppRoutes.settingsPlayback),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.download,
                    title: l10n.settingsDownloadsTitle,
                    subtitle: l10n.settingsDownloadsSubtitle,
                    onTap: () => context.go(AppRoutes.settingsDownloads),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.sync,
                    title: l10n.settingsFeedSyncTitle,
                    subtitle: l10n.settingsFeedSyncSubtitle,
                    onTap: () => context.go(AppRoutes.settingsFeedSync),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.storage,
                    title: l10n.settingsStorageTitle,
                    subtitle: l10n.settingsStorageSubtitle,
                    onTap: () => context.go(AppRoutes.settingsStorage),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.mic,
                    title: l10n.settingsVoiceTitle,
                    subtitle: l10n.settingsVoiceSubtitle,
                    onTap: () => context.go(AppRoutes.settingsVoice),
                  ),
                  SettingsCategoryCard(
                    icon: Icons.info,
                    title: l10n.settingsAboutTitle,
                    subtitle: l10n.settingsAboutSubtitle,
                    onTap: () => context.go(AppRoutes.settingsAbout),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
