import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: [
          SettingsCategoryCard(
            icon: Symbols.palette,
            title: l10n.settingsAppearanceTitle,
            subtitle: l10n.settingsAppearanceSubtitle,
            onTap: () => context.go(AppRoutes.settingsAppearance),
          ),
          SettingsCategoryCard(
            icon: Symbols.play_circle,
            title: l10n.settingsPlaybackTitle,
            subtitle: l10n.settingsPlaybackSubtitle,
            onTap: () => context.go(AppRoutes.settingsPlayback),
          ),
          SettingsCategoryCard(
            icon: Symbols.download,
            title: l10n.settingsDownloadsTitle,
            subtitle: l10n.settingsDownloadsSubtitle,
            onTap: () => context.go(AppRoutes.settingsDownloads),
          ),
          SettingsCategoryCard(
            icon: Symbols.sync,
            title: l10n.settingsFeedSyncTitle,
            subtitle: l10n.settingsFeedSyncSubtitle,
            onTap: () => context.go(AppRoutes.settingsFeedSync),
          ),
          SettingsCategoryCard(
            icon: Symbols.storage,
            title: l10n.settingsStorageTitle,
            subtitle: l10n.settingsStorageSubtitle,
            onTap: () => context.go(AppRoutes.settingsStorage),
          ),
          SettingsCategoryCard(
            icon: Symbols.info,
            title: l10n.settingsAboutTitle,
            subtitle: l10n.settingsAboutSubtitle,
            onTap: () => context.go(AppRoutes.settingsAbout),
          ),
        ],
      ),
    );
  }
}
