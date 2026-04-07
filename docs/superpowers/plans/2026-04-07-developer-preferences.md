# Developer Preferences Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Developer settings screen with smart playlist pattern browsing, a contribute link, and a toggle that shows RSS feed URL + pattern links at the bottom of episode detail screens.

**Architecture:** New settings sub-screen at `/settings/developer` following the existing settings pattern (ConsumerWidget + SharedPreferences + GoRouter). Reuses the existing `patternSummariesProvider` and `SmartPlaylistConfigRepository` for pattern data. A new `devShowDeveloperInfoProvider` backed by SharedPreferences controls visibility of a new `EpisodeDevInfoWidget` at the bottom of the episode detail screen.

**Tech Stack:** Flutter, Riverpod (code gen), GoRouter, SharedPreferences, url_launcher, material_symbols_icons

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `packages/audiflow_core/lib/src/constants/smart_playlist_urls.dart` | GitHub repo URL constants |
| Modify | `packages/audiflow_core/lib/audiflow_core.dart` | Export new constants file |
| Create | `packages/audiflow_domain/lib/src/features/settings/providers/developer_settings_provider.dart` | `devShowDeveloperInfoProvider` Notifier backed by SharedPreferences |
| Modify | `packages/audiflow_domain/lib/audiflow_domain.dart` | Export new provider |
| Create | `packages/audiflow_app/lib/features/settings/presentation/screens/developer_settings_screen.dart` | Developer settings screen |
| Create | `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart` | Conditional dev info widget for episode detail |
| Modify | `packages/audiflow_app/lib/routing/app_router.dart:33,256-293` | Add `settingsDeveloper` route constant + GoRoute |
| Modify | `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart:41-84` | Add Developer card to grid |
| Modify | `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart:312-317` | Insert `EpisodeDevInfoWidget` after stats section |
| Modify | `packages/audiflow_app/lib/l10n/app_en.arb` | English localization keys |
| Modify | `packages/audiflow_app/lib/l10n/app_ja.arb` | Japanese localization keys |
| Create | `packages/audiflow_domain/test/features/settings/providers/developer_settings_provider_test.dart` | Unit tests for provider |
| Create | `packages/audiflow_app/test/features/settings/presentation/screens/developer_settings_screen_test.dart` | Widget tests for settings screen |
| Create | `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart` | Widget tests for dev info widget |

---

### Task 1: Constants — Smart Playlist Repo URLs

**Files:**
- Create: `packages/audiflow_core/lib/src/constants/smart_playlist_urls.dart`
- Modify: `packages/audiflow_core/lib/audiflow_core.dart`

- [ ] **Step 1: Create the constants file**

```dart
// packages/audiflow_core/lib/src/constants/smart_playlist_urls.dart

/// URL constants for the audiflow-smartplaylist GitHub repository.
class SmartPlaylistUrls {
  SmartPlaylistUrls._();

  /// Base repository URL.
  static const String repo =
      'https://github.com/audiflow/audiflow-smartplaylist';

  /// Returns the URL to a specific pattern's directory in the repo.
  static String patternDir(String patternId) =>
      '$repo/tree/main/$patternId/';
}
```

- [ ] **Step 2: Export from audiflow_core barrel**

In `packages/audiflow_core/lib/audiflow_core.dart`, add this export alongside the other constants exports:

```dart
export 'src/constants/smart_playlist_urls.dart';
```

- [ ] **Step 3: Verify analyze passes**

Run: `dart analyze packages/audiflow_core`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_core/lib/src/constants/smart_playlist_urls.dart packages/audiflow_core/lib/audiflow_core.dart
git commit -m "feat(core): add smart playlist repo URL constants"
```

---

### Task 2: Provider — devShowDeveloperInfoProvider

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/settings/providers/developer_settings_provider.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Test: `packages/audiflow_domain/test/features/settings/providers/developer_settings_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/settings/providers/developer_settings_provider_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DevShowDeveloperInfo', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to false', () {
      final value = container.read(devShowDeveloperInfoProvider);
      check(value).equals(false);
    });

    test('persists true after toggle', () async {
      container
          .read(devShowDeveloperInfoProvider.notifier)
          .toggle();
      check(container.read(devShowDeveloperInfoProvider)).equals(true);

      // Verify persisted to SharedPreferences
      final prefs = container.read(sharedPreferencesProvider);
      check(prefs.getBool('dev_show_developer_info')).equals(true);
    });

    test('reads persisted value on rebuild', () async {
      SharedPreferences.setMockInitialValues(
        {'dev_show_developer_info': true},
      );
      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container2.dispose);

      check(container2.read(devShowDeveloperInfoProvider)).equals(true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/settings/providers/developer_settings_provider_test.dart`
Expected: FAIL — `devShowDeveloperInfoProvider` not found

- [ ] **Step 3: Write the provider**

```dart
// packages/audiflow_domain/lib/src/features/settings/providers/developer_settings_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/platform_providers.dart';

part 'developer_settings_provider.g.dart';

/// SharedPreferences key for the developer info toggle.
const _key = 'dev_show_developer_info';

/// Controls visibility of developer info in episode detail screens.
///
/// Backed by SharedPreferences. Defaults to false.
@Riverpod(keepAlive: true)
class DevShowDeveloperInfo extends _$DevShowDeveloperInfo {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  /// Toggles the current value and persists it.
  void toggle() {
    final next = !state;
    ref.read(sharedPreferencesProvider).setBool(_key, next);
    state = next;
  }
}
```

- [ ] **Step 4: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `developer_settings_provider.g.dart`

- [ ] **Step 5: Export from audiflow_domain barrel**

In `packages/audiflow_domain/lib/audiflow_domain.dart`, add alongside the existing settings provider export:

```dart
export 'src/features/settings/providers/developer_settings_provider.dart';
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/settings/providers/developer_settings_provider_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/settings/providers/developer_settings_provider.dart packages/audiflow_domain/lib/src/features/settings/providers/developer_settings_provider.g.dart packages/audiflow_domain/lib/audiflow_domain.dart packages/audiflow_domain/test/features/settings/providers/developer_settings_provider_test.dart
git commit -m "feat(domain): add devShowDeveloperInfo provider"
```

---

### Task 3: Localization — Add All l10n Keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English keys to app_en.arb**

Add these entries at the end of the JSON object (before the closing `}`):

```json
  "settingsDeveloperTitle": "Developer",
  "@settingsDeveloperTitle": {"description": "Settings grid card title for developer preferences"},
  "settingsDeveloperSubtitle": "Smart playlist patterns and debug info",
  "@settingsDeveloperSubtitle": {"description": "Settings grid card subtitle for developer preferences"},
  "developerContributeLabel": "Contribute smart playlist patterns",
  "@developerContributeLabel": {"description": "Tappable row label linking to the smartplaylist repo"},
  "developerContributeRepo": "audiflow/audiflow-smartplaylist",
  "@developerContributeRepo": {"description": "Short repo name shown below the contribute link"},
  "developerShowInfoTitle": "Show developer info",
  "@developerShowInfoTitle": {"description": "Toggle title for developer info in episode detail"},
  "developerShowInfoSubtitle": "Display RSS feed URL and pattern links in episode details",
  "@developerShowInfoSubtitle": {"description": "Toggle subtitle explaining what developer info shows"},
  "developerPatternsHeader": "Smart Playlist Patterns",
  "@developerPatternsHeader": {"description": "Section header for the pattern list"},
  "developerSectionLabel": "Developer",
  "@developerSectionLabel": {"description": "Section label in episode detail for developer info"},
  "developerRssFeedUrl": "RSS Feed URL",
  "@developerRssFeedUrl": {"description": "Label for the RSS feed URL field"},
  "developerCopyLabel": "Copy",
  "@developerCopyLabel": {"description": "Copy button label"},
  "developerCopied": "Copied to clipboard",
  "@developerCopied": {"description": "Snackbar message after copying RSS URL"},
  "developerPatternLabel": "Smart Playlist Pattern",
  "@developerPatternLabel": {"description": "Label for the pattern link field"},
  "developerPatternNotDefined": "Not defined \u2014 add one?",
  "@developerPatternNotDefined": {"description": "Shown when no smart playlist pattern matches the podcast"}
```

- [ ] **Step 2: Add Japanese keys to app_ja.arb**

Add these entries at the end of the JSON object (before the closing `}`):

```json
  "settingsDeveloperTitle": "\u958b\u767a",
  "settingsDeveloperSubtitle": "\u30b9\u30de\u30fc\u30c8\u30d7\u30ec\u30a4\u30ea\u30b9\u30c8\u30d1\u30bf\u30fc\u30f3\u3068\u30c7\u30d0\u30c3\u30b0\u60c5\u5831",
  "developerContributeLabel": "\u30b9\u30de\u30fc\u30c8\u30d7\u30ec\u30a4\u30ea\u30b9\u30c8\u30d1\u30bf\u30fc\u30f3\u3092\u8ca2\u732e",
  "developerContributeRepo": "audiflow/audiflow-smartplaylist",
  "developerShowInfoTitle": "\u958b\u767a\u8005\u60c5\u5831\u3092\u8868\u793a",
  "developerShowInfoSubtitle": "\u30a8\u30d4\u30bd\u30fc\u30c9\u8a73\u7d30\u306bRSS\u30d5\u30a3\u30fc\u30c9URL\u3068\u30d1\u30bf\u30fc\u30f3\u30ea\u30f3\u30af\u3092\u8868\u793a",
  "developerPatternsHeader": "\u30b9\u30de\u30fc\u30c8\u30d7\u30ec\u30a4\u30ea\u30b9\u30c8\u30d1\u30bf\u30fc\u30f3",
  "developerSectionLabel": "\u958b\u767a\u8005",
  "developerRssFeedUrl": "RSS\u30d5\u30a3\u30fc\u30c9URL",
  "developerCopyLabel": "\u30b3\u30d4\u30fc",
  "developerCopied": "\u30af\u30ea\u30c3\u30d7\u30dc\u30fc\u30c9\u306b\u30b3\u30d4\u30fc\u3057\u307e\u3057\u305f",
  "developerPatternLabel": "\u30b9\u30de\u30fc\u30c8\u30d7\u30ec\u30a4\u30ea\u30b9\u30c8\u30d1\u30bf\u30fc\u30f3",
  "developerPatternNotDefined": "\u672a\u5b9a\u7fa9 \u2014 \u8ffd\u52a0\u3057\u307e\u305b\u3093\u304b\uff1f"
```

- [ ] **Step 3: Generate localization**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Regenerates `AppLocalizations` with new getters

- [ ] **Step 4: Verify analyze passes**

Run: `dart analyze packages/audiflow_app`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/l10n/app_en.arb packages/audiflow_app/lib/l10n/app_ja.arb packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add developer settings localization keys"
```

---

### Task 4: Screen — DeveloperSettingsScreen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/developer_settings_screen.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/developer_settings_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// packages/audiflow_app/test/features/settings/presentation/screens/developer_settings_screen_test.dart
import 'package:audiflow_app/features/settings/presentation/screens/developer_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp({
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: DeveloperSettingsScreen(),
    ),
  );
}

void main() {
  group('DeveloperSettingsScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('renders contribute link', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Contribute smart playlist patterns').evaluate())
          .isNotEmpty();
      check(find.text('audiflow/audiflow-smartplaylist').evaluate())
          .isNotEmpty();
    });

    testWidgets('renders toggle defaulting to off', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      check(switchFinder.evaluate()).isNotEmpty();
      final switchWidget = tester.widget<Switch>(switchFinder);
      check(switchWidget.value).equals(false);
    });

    testWidgets('toggle persists state', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      check(prefs.getBool('dev_show_developer_info')).equals(true);
    });

    testWidgets('renders pattern list when summaries available',
        (tester) async {
      final summaries = [
        PatternSummary(
          id: 'coten_radio',
          displayName: 'Coten Radio',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
        PatternSummary(
          id: 'news_connect',
          displayName: 'News Connect',
          feedUrlHint: 'feeds.example.com',
          playlistCount: 2,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            patternSummariesProvider.overrideWith(
              () => _FakePatternSummaries(summaries),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Coten Radio').evaluate()).isNotEmpty();
      check(find.text('News Connect').evaluate()).isNotEmpty();
    });
  });
}

class _FakePatternSummaries extends PatternSummaries {
  _FakePatternSummaries(this._initial);
  final List<PatternSummary> _initial;

  @override
  List<PatternSummary> build() => _initial;
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/settings/presentation/screens/developer_settings_screen_test.dart`
Expected: FAIL — `developer_settings_screen.dart` not found

- [ ] **Step 3: Write the screen**

```dart
// packages/audiflow_app/lib/features/settings/presentation/screens/developer_settings_screen.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// Settings screen for developer-oriented preferences.
///
/// Shows a contribute link to the smartplaylist repo, a toggle
/// for developer info in episode detail, and a browsable list
/// of all smart playlist patterns.
class DeveloperSettingsScreen extends ConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devInfoEnabled = ref.watch(devShowDeveloperInfoProvider);
    final summaries = ref.watch(patternSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDeveloperTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          final repo = ref.read(smartPlaylistConfigRepositoryProvider);
          final rootMeta = await repo.fetchRootMeta();
          ref
              .read(patternSummariesProvider.notifier)
              .setSummaries(rootMeta.patterns);
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
              onTap: () => launchUrl(
                Uri.parse(SmartPlaylistUrls.repo),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const Divider(height: 1),

            // Developer info toggle
            SwitchListTile(
              title: Text(l10n.developerShowInfoTitle),
              subtitle: Text(l10n.developerShowInfoSubtitle),
              value: devInfoEnabled,
              onChanged: (_) => ref
                  .read(devShowDeveloperInfoProvider.notifier)
                  .toggle(),
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
            ...summaries.map(
              (summary) => ListTile(
                title: Text(summary.displayName),
                dense: true,
                trailing: Icon(
                  Symbols.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () => launchUrl(
                  Uri.parse(SmartPlaylistUrls.patternDir(summary.id)),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/settings/presentation/screens/developer_settings_screen_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/settings/presentation/screens/developer_settings_screen.dart packages/audiflow_app/test/features/settings/presentation/screens/developer_settings_screen_test.dart
git commit -m "feat(settings): add developer settings screen"
```

---

### Task 5: Widget — EpisodeDevInfoWidget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart`
- Test: `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// packages/audiflow_app/test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp({
  required String feedUrl,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: EpisodeDevInfoWidget(feedUrl: feedUrl),
      ),
    ),
  );
}

void main() {
  group('EpisodeDevInfoWidget', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('hidden when toggle is off', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          feedUrl: 'https://example.com/feed.xml',
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Developer').evaluate()).isEmpty();
      check(find.text('RSS Feed URL').evaluate()).isEmpty();
    });

    testWidgets('shows RSS URL when toggle is on', (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      await tester.pumpWidget(
        _buildApp(
          feedUrl: 'https://example.com/feed.xml',
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Developer').evaluate()).isNotEmpty();
      check(find.text('https://example.com/feed.xml').evaluate())
          .isNotEmpty();
      check(find.text('Copy').evaluate()).isNotEmpty();
    });

    testWidgets('shows "Not defined" when no pattern matches',
        (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      await tester.pumpWidget(
        _buildApp(
          feedUrl: 'https://unknown.com/feed.xml',
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            patternSummariesProvider.overrideWith(
              () => _EmptyPatternSummaries(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The exact text uses an em dash
      check(find.textContaining('Not defined').evaluate()).isNotEmpty();
    });

    testWidgets('shows pattern name when matched', (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      final summaries = [
        PatternSummary(
          id: 'coten_radio',
          displayName: 'Coten Radio',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            patternSummariesProvider.overrideWith(
              () => _PreloadedPatternSummaries(summaries),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Coten Radio').evaluate()).isNotEmpty();
    });
  });
}

class _EmptyPatternSummaries extends PatternSummaries {
  @override
  List<PatternSummary> build() => [];
}

class _PreloadedPatternSummaries extends PatternSummaries {
  _PreloadedPatternSummaries(this._initial);
  final List<PatternSummary> _initial;

  @override
  List<PatternSummary> build() => _initial;
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart`
Expected: FAIL — `episode_dev_info_widget.dart` not found

- [ ] **Step 3: Write the widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// Displays developer-oriented information at the bottom of an
/// episode detail screen.
///
/// Only rendered when [devShowDeveloperInfoProvider] is true.
/// Shows the podcast RSS feed URL (tap to copy) and a link to
/// the matching smart playlist pattern in the GitHub repo.
class EpisodeDevInfoWidget extends ConsumerWidget {
  const EpisodeDevInfoWidget({
    super.key,
    required this.feedUrl,
  });

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(devShowDeveloperInfoProvider);
    if (!enabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaries = ref.watch(patternSummariesProvider);

    // Find matching pattern by checking feedUrlHint
    final match = summaries
        .where((s) => feedUrl.contains(s.feedUrlHint))
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.developerSectionLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // RSS Feed URL
        _InfoCard(
          label: l10n.developerRssFeedUrl,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  feedUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              ActionChip(
                label: Text(l10n.developerCopyLabel),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: feedUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.developerCopied)),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // Pattern link
        _InfoCard(
          label: l10n.developerPatternLabel,
          child: InkWell(
            onTap: () => launchUrl(
              Uri.parse(
                match != null
                    ? SmartPlaylistUrls.patternDir(match.id)
                    : SmartPlaylistUrls.repo,
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    match?.displayName ?? l10n.developerPatternNotDefined,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: match != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          child,
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart packages/audiflow_app/test/features/podcast_detail/presentation/widgets/episode_dev_info_widget_test.dart
git commit -m "feat(podcast-detail): add episode dev info widget"
```

---

### Task 6: Integration — Routing, Settings Grid, Episode Detail

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart:33,256-293`
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart:41-84`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart:1-9,312-317`

- [ ] **Step 1: Add route constant to AppRoutes**

In `packages/audiflow_app/lib/routing/app_router.dart`, add to the `AppRoutes` class (after line 52, after `settingsVoice`):

```dart
  static const String settingsDeveloper = '/settings/developer';
```

- [ ] **Step 2: Add GoRoute under settings branch**

In `packages/audiflow_app/lib/routing/app_router.dart`, add a new `GoRoute` inside the settings routes list (after the `voice` route at line 293, before the closing `]`):

```dart
                  GoRoute(
                    path: 'developer',
                    builder: (context, state) =>
                        const DeveloperSettingsScreen(),
                  ),
```

Also add the import at the top of the file:

```dart
import '../features/settings/presentation/screens/developer_settings_screen.dart';
```

- [ ] **Step 3: Add Developer card to settings grid**

In `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`, add a new `SettingsCategoryCard` after the About card (before the closing `]` at line 84):

```dart
                  SettingsCategoryCard(
                    icon: Symbols.code,
                    title: l10n.settingsDeveloperTitle,
                    subtitle: l10n.settingsDeveloperSubtitle,
                    onTap: () => context.go(AppRoutes.settingsDeveloper),
                  ),
```

- [ ] **Step 4: Insert EpisodeDevInfoWidget into episode detail**

In `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart`:

Add import at the top:

```dart
import '../widgets/episode_dev_info_widget.dart';
```

After `_EpisodeStatsSection` (line 316), before the closing `]` of the Column children, add:

```dart
                    EpisodeDevInfoWidget(
                      feedUrl: widget.episode.sourceUrl,
                    ),
```

- [ ] **Step 5: Verify analyze passes**

Run: `dart analyze packages/audiflow_app`
Expected: No issues found

- [ ] **Step 6: Run all tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/routing/app_router.dart packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart
git commit -m "feat(settings): integrate developer settings into app routing and UI"
```

---

### Task 7: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `melos run test`
Expected: All packages pass

- [ ] **Step 2: Run full analysis**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: Verify all files are committed**

Run: `git status`
Expected: Clean working tree
