import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          SettingsCategoryCard(
            icon: Symbols.palette,
            title: 'Appearance',
            subtitle: 'Theme, language, text size',
            onTap: () => context.go(AppRoutes.settingsAppearance),
          ),
          SettingsCategoryCard(
            icon: Symbols.play_circle,
            title: 'Playback',
            subtitle: 'Speed, skipping, auto-complete',
            onTap: () => context.go(AppRoutes.settingsPlayback),
          ),
          SettingsCategoryCard(
            icon: Symbols.download,
            title: 'Downloads',
            subtitle: 'WiFi, auto-delete, concurrency',
            onTap: () => context.go(AppRoutes.settingsDownloads),
          ),
          SettingsCategoryCard(
            icon: Symbols.sync,
            title: 'Feed Sync',
            subtitle: 'Refresh interval, background sync',
            onTap: () => context.go(AppRoutes.settingsFeedSync),
          ),
          SettingsCategoryCard(
            icon: Symbols.storage,
            title: 'Storage & Data',
            subtitle: 'Cache, OPML, data management',
            onTap: () => context.go(AppRoutes.settingsStorage),
          ),
          SettingsCategoryCard(
            icon: Symbols.info,
            title: 'About',
            subtitle: 'Version, licenses, support',
            onTap: () => context.go(AppRoutes.settingsAbout),
          ),
        ],
      ),
    );
  }
}
