# Settings Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a full-featured settings page with six category cards (Appearance, Playback, Downloads, Feed Sync, Storage & Data, About) that drill into detail pages.

**Architecture:** Settings stored via `SharedPreferencesDataSource` with a new `AppSettingsRepository` in `audiflow_domain`. Each setting exposed as a Riverpod provider. Category cards on `/settings` navigate to detail sub-pages. Services currently using hard-coded values will read from settings providers instead.

**Tech Stack:** Flutter, Riverpod (code-gen), SharedPreferences, GoRouter, Material 3

**Design doc:** `docs/plans/2026-02-14-settings-page-design.md`

---

## Task 1: Setting Key Constants in audiflow_core

**Files:**
- Create: `packages/audiflow_core/lib/src/constants/settings_keys.dart`
- Modify: `packages/audiflow_core/lib/audiflow_core.dart`
- Test: `packages/audiflow_core/test/constants/settings_keys_test.dart`

**Step 1: Write the test**

```dart
// packages/audiflow_core/test/constants/settings_keys_test.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:test/test.dart';

void main() {
  group('SettingsKeys', () {
    test('keys are unique', () {
      final keys = [
        SettingsKeys.themeMode,
        SettingsKeys.locale,
        SettingsKeys.textScale,
        SettingsKeys.playbackSpeed,
        SettingsKeys.skipForwardSeconds,
        SettingsKeys.skipBackwardSeconds,
        SettingsKeys.autoCompleteThreshold,
        SettingsKeys.continuousPlayback,
        SettingsKeys.wifiOnlyDownload,
        SettingsKeys.autoDeletePlayed,
        SettingsKeys.maxConcurrentDownloads,
        SettingsKeys.autoSync,
        SettingsKeys.syncIntervalMinutes,
        SettingsKeys.wifiOnlySync,
      ];
      expect(keys.toSet().length, equals(keys.length));
    });
  });

  group('SettingsDefaults', () {
    test('playback speed is 1.0', () {
      expect(SettingsDefaults.playbackSpeed, equals(1.0));
    });

    test('skip forward is 30 seconds', () {
      expect(SettingsDefaults.skipForwardSeconds, equals(30));
    });

    test('skip backward is 10 seconds', () {
      expect(SettingsDefaults.skipBackwardSeconds, equals(10));
    });

    test('auto-complete threshold is 0.95', () {
      expect(SettingsDefaults.autoCompleteThreshold, equals(0.95));
    });

    test('continuous playback is true', () {
      expect(SettingsDefaults.continuousPlayback, isTrue);
    });

    test('wifi-only download is true', () {
      expect(SettingsDefaults.wifiOnlyDownload, isTrue);
    });

    test('auto-delete played is false', () {
      expect(SettingsDefaults.autoDeletePlayed, isFalse);
    });

    test('max concurrent downloads is 1', () {
      expect(SettingsDefaults.maxConcurrentDownloads, equals(1));
    });

    test('auto-sync is true', () {
      expect(SettingsDefaults.autoSync, isTrue);
    });

    test('sync interval is 60 minutes', () {
      expect(SettingsDefaults.syncIntervalMinutes, equals(60));
    });

    test('wifi-only sync is false', () {
      expect(SettingsDefaults.wifiOnlySync, isFalse);
    });

    test('text scale is 1.0', () {
      expect(SettingsDefaults.textScale, equals(1.0));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run tests. Expected: FAIL (SettingsKeys and SettingsDefaults not found).

**Step 3: Write the implementation**

```dart
// packages/audiflow_core/lib/src/constants/settings_keys.dart

/// SharedPreferences keys for app settings.
class SettingsKeys {
  SettingsKeys._();

  // Appearance
  static const String themeMode = 'settings_theme_mode';
  static const String locale = 'settings_locale';
  static const String textScale = 'settings_text_scale';

  // Playback
  static const String playbackSpeed = 'settings_playback_speed';
  static const String skipForwardSeconds = 'settings_skip_forward_seconds';
  static const String skipBackwardSeconds = 'settings_skip_backward_seconds';
  static const String autoCompleteThreshold =
      'settings_auto_complete_threshold';
  static const String continuousPlayback = 'settings_continuous_playback';

  // Downloads
  static const String wifiOnlyDownload = 'settings_wifi_only_download';
  static const String autoDeletePlayed = 'settings_auto_delete_played';
  static const String maxConcurrentDownloads =
      'settings_max_concurrent_downloads';

  // Feed Sync
  static const String autoSync = 'settings_auto_sync';
  static const String syncIntervalMinutes = 'settings_sync_interval_minutes';
  static const String wifiOnlySync = 'settings_wifi_only_sync';
}

/// Default values for app settings.
class SettingsDefaults {
  SettingsDefaults._();

  // Appearance
  static const double textScale = 1.0;

  // Playback
  static const double playbackSpeed = 1.0;
  static const int skipForwardSeconds = 30;
  static const int skipBackwardSeconds = 10;
  static const double autoCompleteThreshold = 0.95;
  static const bool continuousPlayback = true;

  // Downloads
  static const bool wifiOnlyDownload = true;
  static const bool autoDeletePlayed = false;
  static const int maxConcurrentDownloads = 1;

  // Feed Sync
  static const bool autoSync = true;
  static const int syncIntervalMinutes = 60;
  static const bool wifiOnlySync = false;
}
```

Add export to `packages/audiflow_core/lib/audiflow_core.dart`:

```dart
export 'src/constants/settings_keys.dart';
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```
feat(core): add settings key constants and defaults
```

---

## Task 2: AppSettingsRepository in audiflow_domain

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart`
- Create: `packages/audiflow_domain/lib/src/features/settings/providers/settings_providers.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Test: `packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart`
- Test: `packages/audiflow_domain/test/features/settings/providers/settings_providers_test.dart`

**Step 1: Write the repository interface**

```dart
// packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart
import 'package:flutter/material.dart';

/// Repository for reading and writing app settings.
abstract class AppSettingsRepository {
  // Appearance
  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);

  String? getLocale();
  Future<void> setLocale(String? locale);

  double getTextScale();
  Future<void> setTextScale(double scale);

  // Playback
  double getPlaybackSpeed();
  Future<void> setPlaybackSpeed(double speed);

  int getSkipForwardSeconds();
  Future<void> setSkipForwardSeconds(int seconds);

  int getSkipBackwardSeconds();
  Future<void> setSkipBackwardSeconds(int seconds);

  double getAutoCompleteThreshold();
  Future<void> setAutoCompleteThreshold(double threshold);

  bool getContinuousPlayback();
  Future<void> setContinuousPlayback(bool enabled);

  // Downloads
  bool getWifiOnlyDownload();
  Future<void> setWifiOnlyDownload(bool enabled);

  bool getAutoDeletePlayed();
  Future<void> setAutoDeletePlayed(bool enabled);

  int getMaxConcurrentDownloads();
  Future<void> setMaxConcurrentDownloads(int count);

  // Feed Sync
  bool getAutoSync();
  Future<void> setAutoSync(bool enabled);

  int getSyncIntervalMinutes();
  Future<void> setSyncIntervalMinutes(int minutes);

  bool getWifiOnlySync();
  Future<void> setWifiOnlySync(bool enabled);

  // Data management
  Future<void> clearAll();
}
```

**Step 2: Write the repository impl test**

```dart
// packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

// Import impl directly since it may not be exported
import 'package:audiflow_domain/src/features/settings/repositories/app_settings_repository_impl.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesDataSource dataSource;
  late AppSettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
    repository = AppSettingsRepositoryImpl(dataSource);
  });

  group('Theme mode', () {
    test('returns system by default', () {
      expect(repository.getThemeMode(), equals(ThemeMode.system));
    });

    test('persists and reads dark mode', () async {
      await repository.setThemeMode(ThemeMode.dark);
      expect(repository.getThemeMode(), equals(ThemeMode.dark));
    });

    test('persists and reads light mode', () async {
      await repository.setThemeMode(ThemeMode.light);
      expect(repository.getThemeMode(), equals(ThemeMode.light));
    });
  });

  group('Locale', () {
    test('returns null by default', () {
      expect(repository.getLocale(), isNull);
    });

    test('persists and reads locale', () async {
      await repository.setLocale('ja');
      expect(repository.getLocale(), equals('ja'));
    });

    test('clears locale when set to null', () async {
      await repository.setLocale('ja');
      await repository.setLocale(null);
      expect(repository.getLocale(), isNull);
    });
  });

  group('Text scale', () {
    test('returns 1.0 by default', () {
      expect(
        repository.getTextScale(),
        equals(SettingsDefaults.textScale),
      );
    });

    test('persists and reads value', () async {
      await repository.setTextScale(1.15);
      expect(repository.getTextScale(), equals(1.15));
    });
  });

  group('Playback speed', () {
    test('returns 1.0 by default', () {
      expect(
        repository.getPlaybackSpeed(),
        equals(SettingsDefaults.playbackSpeed),
      );
    });

    test('persists and reads value', () async {
      await repository.setPlaybackSpeed(1.5);
      expect(repository.getPlaybackSpeed(), equals(1.5));
    });
  });

  group('Skip forward', () {
    test('returns 30 by default', () {
      expect(
        repository.getSkipForwardSeconds(),
        equals(SettingsDefaults.skipForwardSeconds),
      );
    });

    test('persists and reads value', () async {
      await repository.setSkipForwardSeconds(15);
      expect(repository.getSkipForwardSeconds(), equals(15));
    });
  });

  group('Skip backward', () {
    test('returns 10 by default', () {
      expect(
        repository.getSkipBackwardSeconds(),
        equals(SettingsDefaults.skipBackwardSeconds),
      );
    });

    test('persists and reads value', () async {
      await repository.setSkipBackwardSeconds(30);
      expect(repository.getSkipBackwardSeconds(), equals(30));
    });
  });

  group('Auto-complete threshold', () {
    test('returns 0.95 by default', () {
      expect(
        repository.getAutoCompleteThreshold(),
        equals(SettingsDefaults.autoCompleteThreshold),
      );
    });

    test('persists and reads value', () async {
      await repository.setAutoCompleteThreshold(0.9);
      expect(repository.getAutoCompleteThreshold(), equals(0.9));
    });
  });

  group('Continuous playback', () {
    test('returns true by default', () {
      expect(
        repository.getContinuousPlayback(),
        equals(SettingsDefaults.continuousPlayback),
      );
    });

    test('persists and reads value', () async {
      await repository.setContinuousPlayback(false);
      expect(repository.getContinuousPlayback(), isFalse);
    });
  });

  group('WiFi-only download', () {
    test('returns true by default', () {
      expect(
        repository.getWifiOnlyDownload(),
        equals(SettingsDefaults.wifiOnlyDownload),
      );
    });

    test('persists and reads value', () async {
      await repository.setWifiOnlyDownload(false);
      expect(repository.getWifiOnlyDownload(), isFalse);
    });
  });

  group('Auto-delete played', () {
    test('returns false by default', () {
      expect(
        repository.getAutoDeletePlayed(),
        equals(SettingsDefaults.autoDeletePlayed),
      );
    });

    test('persists and reads value', () async {
      await repository.setAutoDeletePlayed(true);
      expect(repository.getAutoDeletePlayed(), isTrue);
    });
  });

  group('Max concurrent downloads', () {
    test('returns 1 by default', () {
      expect(
        repository.getMaxConcurrentDownloads(),
        equals(SettingsDefaults.maxConcurrentDownloads),
      );
    });

    test('persists and reads value', () async {
      await repository.setMaxConcurrentDownloads(3);
      expect(repository.getMaxConcurrentDownloads(), equals(3));
    });
  });

  group('Auto sync', () {
    test('returns true by default', () {
      expect(repository.getAutoSync(), equals(SettingsDefaults.autoSync));
    });

    test('persists and reads value', () async {
      await repository.setAutoSync(false);
      expect(repository.getAutoSync(), isFalse);
    });
  });

  group('Sync interval', () {
    test('returns 60 by default', () {
      expect(
        repository.getSyncIntervalMinutes(),
        equals(SettingsDefaults.syncIntervalMinutes),
      );
    });

    test('persists and reads value', () async {
      await repository.setSyncIntervalMinutes(30);
      expect(repository.getSyncIntervalMinutes(), equals(30));
    });
  });

  group('WiFi-only sync', () {
    test('returns false by default', () {
      expect(
        repository.getWifiOnlySync(),
        equals(SettingsDefaults.wifiOnlySync),
      );
    });

    test('persists and reads value', () async {
      await repository.setWifiOnlySync(true);
      expect(repository.getWifiOnlySync(), isTrue);
    });
  });

  group('clearAll', () {
    test('resets all settings to defaults', () async {
      await repository.setThemeMode(ThemeMode.dark);
      await repository.setPlaybackSpeed(2.0);
      await repository.setAutoSync(false);

      await repository.clearAll();

      expect(repository.getThemeMode(), equals(ThemeMode.system));
      expect(
        repository.getPlaybackSpeed(),
        equals(SettingsDefaults.playbackSpeed),
      );
      expect(repository.getAutoSync(), equals(SettingsDefaults.autoSync));
    });
  });
}
```

**Step 3: Run test to verify it fails**

**Step 4: Write the repository impl**

```dart
// packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import 'app_settings_repository.dart';

/// SharedPreferences-backed implementation of [AppSettingsRepository].
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  const AppSettingsRepositoryImpl(this._ds);

  final SharedPreferencesDataSource _ds;

  // Appearance

  @override
  ThemeMode getThemeMode() {
    final value = _ds.getString(SettingsKeys.themeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) => _ds.setString(
    SettingsKeys.themeMode,
    mode.name,
  );

  @override
  String? getLocale() => _ds.getString(SettingsKeys.locale);

  @override
  Future<void> setLocale(String? locale) async {
    if (locale == null) {
      await _ds.remove(SettingsKeys.locale);
    } else {
      await _ds.setString(SettingsKeys.locale, locale);
    }
  }

  @override
  double getTextScale() =>
      _ds.getDouble(SettingsKeys.textScale) ?? SettingsDefaults.textScale;

  @override
  Future<void> setTextScale(double scale) =>
      _ds.setDouble(SettingsKeys.textScale, scale);

  // Playback

  @override
  double getPlaybackSpeed() =>
      _ds.getDouble(SettingsKeys.playbackSpeed) ??
      SettingsDefaults.playbackSpeed;

  @override
  Future<void> setPlaybackSpeed(double speed) =>
      _ds.setDouble(SettingsKeys.playbackSpeed, speed);

  @override
  int getSkipForwardSeconds() =>
      _ds.getInt(SettingsKeys.skipForwardSeconds) ??
      SettingsDefaults.skipForwardSeconds;

  @override
  Future<void> setSkipForwardSeconds(int seconds) =>
      _ds.setInt(SettingsKeys.skipForwardSeconds, seconds);

  @override
  int getSkipBackwardSeconds() =>
      _ds.getInt(SettingsKeys.skipBackwardSeconds) ??
      SettingsDefaults.skipBackwardSeconds;

  @override
  Future<void> setSkipBackwardSeconds(int seconds) =>
      _ds.setInt(SettingsKeys.skipBackwardSeconds, seconds);

  @override
  double getAutoCompleteThreshold() =>
      _ds.getDouble(SettingsKeys.autoCompleteThreshold) ??
      SettingsDefaults.autoCompleteThreshold;

  @override
  Future<void> setAutoCompleteThreshold(double threshold) =>
      _ds.setDouble(SettingsKeys.autoCompleteThreshold, threshold);

  @override
  bool getContinuousPlayback() =>
      _ds.getBool(SettingsKeys.continuousPlayback) ??
      SettingsDefaults.continuousPlayback;

  @override
  Future<void> setContinuousPlayback(bool enabled) =>
      _ds.setBool(SettingsKeys.continuousPlayback, enabled);

  // Downloads

  @override
  bool getWifiOnlyDownload() =>
      _ds.getBool(SettingsKeys.wifiOnlyDownload) ??
      SettingsDefaults.wifiOnlyDownload;

  @override
  Future<void> setWifiOnlyDownload(bool enabled) =>
      _ds.setBool(SettingsKeys.wifiOnlyDownload, enabled);

  @override
  bool getAutoDeletePlayed() =>
      _ds.getBool(SettingsKeys.autoDeletePlayed) ??
      SettingsDefaults.autoDeletePlayed;

  @override
  Future<void> setAutoDeletePlayed(bool enabled) =>
      _ds.setBool(SettingsKeys.autoDeletePlayed, enabled);

  @override
  int getMaxConcurrentDownloads() =>
      _ds.getInt(SettingsKeys.maxConcurrentDownloads) ??
      SettingsDefaults.maxConcurrentDownloads;

  @override
  Future<void> setMaxConcurrentDownloads(int count) =>
      _ds.setInt(SettingsKeys.maxConcurrentDownloads, count);

  // Feed Sync

  @override
  bool getAutoSync() =>
      _ds.getBool(SettingsKeys.autoSync) ?? SettingsDefaults.autoSync;

  @override
  Future<void> setAutoSync(bool enabled) =>
      _ds.setBool(SettingsKeys.autoSync, enabled);

  @override
  int getSyncIntervalMinutes() =>
      _ds.getInt(SettingsKeys.syncIntervalMinutes) ??
      SettingsDefaults.syncIntervalMinutes;

  @override
  Future<void> setSyncIntervalMinutes(int minutes) =>
      _ds.setInt(SettingsKeys.syncIntervalMinutes, minutes);

  @override
  bool getWifiOnlySync() =>
      _ds.getBool(SettingsKeys.wifiOnlySync) ?? SettingsDefaults.wifiOnlySync;

  @override
  Future<void> setWifiOnlySync(bool enabled) =>
      _ds.setBool(SettingsKeys.wifiOnlySync, enabled);

  // Data management

  @override
  Future<void> clearAll() => _ds.clear();
}
```

Note: `SharedPreferencesDataSource` needs `getDouble` and `setDouble` methods added. Add them:

```dart
// Add to packages/audiflow_domain/lib/src/common/datasources/shared_preferences_datasource.dart

/// Get double value
double? getDouble(String key) => _prefs.getDouble(key);

/// Set double value
Future<bool> setDouble(String key, double value) =>
    _prefs.setDouble(key, value);
```

**Step 5: Write settings providers**

```dart
// packages/audiflow_domain/lib/src/features/settings/providers/settings_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/app_settings_repository_impl.dart';

part 'settings_providers.g.dart';

/// Provides the [AppSettingsRepository] instance.
@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dataSource = SharedPreferencesDataSource(prefs);
  return AppSettingsRepositoryImpl(dataSource);
}
```

**Step 6: Add exports to `audiflow_domain.dart`**

```dart
// Settings feature
export 'src/features/settings/repositories/app_settings_repository.dart';
export 'src/features/settings/repositories/app_settings_repository_impl.dart';
export 'src/features/settings/providers/settings_providers.dart';
```

**Step 7: Run codegen, then run tests**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 8: Commit**

```
feat(domain): add AppSettingsRepository with SharedPreferences backend
```

---

## Task 3: Initialize SharedPreferences in main.dart

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`

**Step 1: Add SharedPreferences initialization and provider override**

In `main()`, add before `ProviderContainer`:

```dart
final prefs = await SharedPreferences.getInstance();
```

Add to `overrides` list:

```dart
sharedPreferencesProvider.overrideWithValue(prefs),
```

Add import:

```dart
import 'package:shared_preferences/shared_preferences.dart';
```

**Step 2: Commit**

```
feat(app): initialize SharedPreferences at startup
```

---

## Task 4: Settings Routes

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

**Step 1: Add route constants**

Add to `AppRoutes`:

```dart
static const String settingsAppearance = '/settings/appearance';
static const String settingsPlayback = '/settings/playback';
static const String settingsDownloads = '/settings/downloads';
static const String settingsFeedSync = '/settings/feed-sync';
static const String settingsStorage = '/settings/storage';
static const String settingsAbout = '/settings/about';
```

**Step 2: Add sub-routes under the settings branch**

Replace the settings `GoRoute` with:

```dart
GoRoute(
  path: AppRoutes.settings,
  builder: (context, state) => const SettingsScreen(),
  routes: [
    GoRoute(
      path: 'appearance',
      builder: (context, state) =>
          const AppearanceSettingsScreen(),
    ),
    GoRoute(
      path: 'playback',
      builder: (context, state) =>
          const PlaybackSettingsScreen(),
    ),
    GoRoute(
      path: 'downloads',
      builder: (context, state) =>
          const DownloadsSettingsScreen(),
    ),
    GoRoute(
      path: 'feed-sync',
      builder: (context, state) =>
          const FeedSyncSettingsScreen(),
    ),
    GoRoute(
      path: 'storage',
      builder: (context, state) =>
          const StorageSettingsScreen(),
    ),
    GoRoute(
      path: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
),
```

Add imports for the new screens (create placeholder files first if needed).

**Step 3: Commit**

```
feat(app): add settings sub-routes
```

---

## Task 5: Settings Category Cards Screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`
- Create: `packages/audiflow_app/lib/features/settings/presentation/widgets/settings_category_card.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/settings_screen_test.dart` (replace existing)
- Test: `packages/audiflow_app/test/features/settings/presentation/widgets/settings_category_card_test.dart`

**Step 1: Write the SettingsCategoryCard widget**

```dart
// packages/audiflow_app/lib/features/settings/presentation/widgets/settings_category_card.dart
import 'package:flutter/material.dart';

/// A card representing a settings category on the main settings page.
class SettingsCategoryCard extends StatelessWidget {
  const SettingsCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Rewrite SettingsScreen with category cards grid**

```dart
// packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../routing/app_router.dart';
import '../widgets/settings_category_card.dart';

/// Settings screen displaying category cards in a grid.
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
```

**Step 3: Update tests**

Replace existing test file to match the new implementation (test for 6 cards rendered, proper titles, tapping navigates).

**Step 4: Commit**

```
feat(app): replace settings placeholder with category cards grid
```

---

## Task 6: Appearance Settings Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/appearance_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/appearance_settings_screen_test.dart`

**Implementation notes:**
- `ThemeMode` - segmented button (Light/Dark/System)
- `Language` - dropdown (English/Japanese)
- `Text Size` - segmented button (Small 0.85x / Medium 1.0x / Large 1.15x) with live preview text

Uses `ref.watch(appSettingsRepositoryProvider)` to read current values. Calls setter methods on change. After setting theme mode, invalidate a theme provider (or use a `themeModeProvider` that the `MaterialApp` watches).

**Key pattern for all settings screens:**
- `ConsumerWidget`
- Read settings via `ref.watch(appSettingsRepositoryProvider)`
- Write settings via `ref.read(appSettingsRepositoryProvider).setX(value)`
- Each screen is a `Scaffold` with `AppBar` + `ListView` body with `ListTile`-based settings controls

**Commit:**

```
feat(app): add appearance settings screen
```

---

## Task 7: Playback Settings Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/playback_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/playback_settings_screen_test.dart`

**Implementation notes:**
- Default playback speed - dropdown (0.5x to 2.0x)
- Skip forward - segmented button (10, 15, 30, 45, 60)
- Skip backward - segmented button (10, 15, 30)
- Auto-complete threshold - `Slider` (0.80 to 0.99, label shows current %)
- Continuous playback - `SwitchListTile`

**Commit:**

```
feat(app): add playback settings screen
```

---

## Task 8: Downloads Settings Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/downloads_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/downloads_settings_screen_test.dart`

**Implementation notes:**
- WiFi-only downloads - `SwitchListTile`
- Auto-delete after played - `SwitchListTile`
- Max concurrent downloads - segmented button (1, 2, 3)

**Commit:**

```
feat(app): add downloads settings screen
```

---

## Task 9: Feed Sync Settings Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/feed_sync_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/feed_sync_settings_screen_test.dart`

**Implementation notes:**
- Auto-sync - `SwitchListTile`
- Sync interval - dropdown (30, 60, 120, 240 minutes), visible only when auto-sync is on. Use `AnimatedCrossFade` or conditional rendering.
- WiFi-only sync - `SwitchListTile`

**Commit:**

```
feat(app): add feed sync settings screen
```

---

## Task 10: Storage & Data Settings Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/storage_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/storage_settings_screen_test.dart`

**Implementation notes:**
- Cache section: show cache size (use `cacheDirProvider` to calculate directory size), "Clear Cache" button with `showDialog` confirmation
- Search history: "Clear Search History" button with confirmation
- OPML section: "Export Subscriptions" and "Import Subscriptions" buttons (stub for now - these are complex features that can be implemented later)
- Data management: show database size, "Reset All Data" with double confirmation (dialog with TextField requiring user to type "RESET")

The reset action should:
1. Call `appSettingsRepository.clearAll()`
2. Clear the database (if a reset method is available)
3. Clear cache directory

**Commit:**

```
feat(app): add storage and data settings screen
```

---

## Task 11: About Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/about_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/about_screen_test.dart`

**Implementation notes:**
- App icon + name at top
- Version/build from `packageInfoProvider` (needs initialization in `main.dart`)
- "Open Source Licenses" - navigates to `showLicensePage(context: context)`
- "Send Feedback" - `launchUrl(Uri.parse('mailto:...'))`
- "Rate the App" - `launchUrl` to store URL (stub for now)

Initialize `packageInfoProvider` in `main.dart`:

```dart
final packageInfo = await PackageInfo.fromPlatform();
// Add to overrides:
packageInfoProvider.overrideWithValue(packageInfo),
```

**Commit:**

```
feat(app): add about screen with version and licenses
```

---

## Task 12: Wire Theme Mode into MaterialApp

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/controllers/theme_controller.dart`
- Modify: `packages/audiflow_app/lib/main.dart`

**Implementation notes:**

Create a Riverpod controller that watches the settings repository for theme mode:

```dart
// packages/audiflow_app/lib/features/settings/presentation/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setThemeMode(mode);
    state = mode;
  }
}

@Riverpod(keepAlive: true)
class TextScaleController extends _$TextScaleController {
  @override
  double build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getTextScale();
  }

  Future<void> setTextScale(double scale) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setTextScale(scale);
    state = scale;
  }
}
```

Make `MyApp` a `ConsumerWidget` and watch theme mode:

```dart
class MyApp extends ConsumerStatefulWidget {
  // Watch themeModeControllerProvider for ThemeMode
  // Watch textScaleControllerProvider for text scaling
  // Apply themeMode to MaterialApp.router
  // Wrap with MediaQuery for text scale
}
```

Run codegen, then commit:

```
feat(app): wire theme mode and text scale to MaterialApp
```

---

## Task 13: Wire Settings into Services

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`
- Modify: existing tests for these services

**Step 1: FeedSyncService - use settings for sync interval**

Replace `static const _syncInterval = Duration(hours: 1);` with a read from `appSettingsRepositoryProvider`:

```dart
Duration get _syncInterval {
  final repo = _ref.read(appSettingsRepositoryProvider);
  return Duration(minutes: repo.getSyncIntervalMinutes());
}
```

Also check `getAutoSync()` before syncing, and `getWifiOnlySync()` to skip sync on cellular.

**Step 2: PlaybackHistoryService - use settings for completion threshold**

Replace `static const double completionThreshold = 0.95;` with a parameter:

```dart
class PlaybackHistoryService {
  PlaybackHistoryService(this._repository, {required this.getCompletionThreshold});

  final double Function() getCompletionThreshold;
  // ...
}
```

Update the provider to inject the threshold from settings:

```dart
@Riverpod(keepAlive: true)
PlaybackHistoryService playbackHistoryService(Ref ref) {
  final repository = ref.watch(playbackHistoryRepositoryProvider);
  final settingsRepo = ref.watch(appSettingsRepositoryProvider);
  return PlaybackHistoryService(
    repository,
    getCompletionThreshold: settingsRepo.getAutoCompleteThreshold,
  );
}
```

**Step 3: AudioPlayerController - use settings for skip durations**

Read skip forward/backward from settings when calling `skipForward()` and `skipBackward()`:

```dart
Future<void> skipForward() async {
  final settingsRepo = ref.read(appSettingsRepositoryProvider);
  final seconds = settingsRepo.getSkipForwardSeconds();
  await seek(_player.position + Duration(seconds: seconds));
}
```

Remove the default parameter from `skipForward` and `skipBackward`.

**Step 4: DownloadService - use settings providers**

The `downloadWifiOnlyProvider` and `downloadAutoDeletePlayedProvider` already exist. Override them to read from settings:

```dart
@riverpod
bool downloadWifiOnly(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getWifiOnlyDownload();
}

@riverpod
bool downloadAutoDeletePlayed(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getAutoDeletePlayed();
}
```

**Step 5: Update tests for modified services**

Update tests that relied on hard-coded values to now mock or override the settings repository.

**Step 6: Run all tests**

**Step 7: Commit**

```
feat(domain): wire app settings into services replacing hard-coded values
```

---

## Task 14: Post-Implementation Checklist

1. Run `dart_format` on all modified packages
2. Run `analyze_files` - must have zero errors
3. Run `run_tests` - all tests must pass
4. Run `jj bookmark create feat/settings-page`

---

## Summary

| Task | Description | Package |
|------|-------------|---------|
| 1 | Setting key constants and defaults | audiflow_core |
| 2 | AppSettingsRepository (interface + impl + providers) | audiflow_domain |
| 3 | Initialize SharedPreferences in main.dart | audiflow_app |
| 4 | Settings sub-routes | audiflow_app |
| 5 | Settings category cards screen | audiflow_app |
| 6 | Appearance settings screen | audiflow_app |
| 7 | Playback settings screen | audiflow_app |
| 8 | Downloads settings screen | audiflow_app |
| 9 | Feed sync settings screen | audiflow_app |
| 10 | Storage & data settings screen | audiflow_app |
| 11 | About screen | audiflow_app |
| 12 | Wire theme mode into MaterialApp | audiflow_app |
| 13 | Wire settings into services | audiflow_domain |
| 14 | Post-implementation checklist | all |
