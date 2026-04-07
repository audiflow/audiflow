# Download All Episodes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add batch "download all episodes" to station and season/group pages, with a user-configurable limit (default 25).

**Architecture:** New setting stored in SharedPreferences via existing `AppSettingsRepository` pattern. New `downloadEpisodes()` method in `DownloadService` caps at the configured limit. Station and season/group pages replace their AppBar actions with a `PopupMenuButton`. Season/group page moves search from `SearchableAppBar` to a collapsible `SliverAppBar` bottom slot.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, Isar (existing download infrastructure), Material 3

---

### Task 1: Add Batch Download Limit Setting (Domain Layer)

**Files:**
- Modify: `packages/audiflow_core/lib/src/constants/settings_keys.dart:39-49` (add key + default)
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart:68-86` (add interface methods)
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart:111-141` (add implementation)
- Modify: `packages/audiflow_domain/test/helpers/fake_app_settings_repository.dart` (add fake field + methods)
- Modify: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart` (add provider)

- [ ] **Step 1: Add settings key and default**

In `packages/audiflow_core/lib/src/constants/settings_keys.dart`, add after `maxConcurrentDownloads` key (line 49):

```dart
  /// Maximum number of episodes to batch-download at once.
  static const String batchDownloadLimit = 'settings_batch_download_limit';
```

In `SettingsDefaults`, add after `maxConcurrentDownloads` default (line 116):

```dart
  /// Default batch download limit.
  static const int batchDownloadLimit = 25;
```

- [ ] **Step 2: Add interface methods**

In `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart`, add after `setMaxConcurrentDownloads` (line 86):

```dart
  /// Maximum number of episodes to batch-download at once.
  int getBatchDownloadLimit();

  /// Persists the batch download limit.
  Future<void> setBatchDownloadLimit(int limit);
```

- [ ] **Step 3: Add implementation**

In `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart`, add after `setMaxConcurrentDownloads` (line 141):

```dart
  @override
  int getBatchDownloadLimit() =>
      _ds.getInt(SettingsKeys.batchDownloadLimit) ??
      SettingsDefaults.batchDownloadLimit;

  @override
  Future<void> setBatchDownloadLimit(int limit) async {
    await _ds.setInt(SettingsKeys.batchDownloadLimit, limit);
  }
```

Also add `SettingsKeys.batchDownloadLimit` to `clearAll()` (around line 246):

```dart
      _ds.remove(SettingsKeys.batchDownloadLimit),
```

- [ ] **Step 4: Update fake repository**

In `packages/audiflow_domain/test/helpers/fake_app_settings_repository.dart`, add field (after `maxConcurrentDownloads` line 21):

```dart
  int batchDownloadLimit = 25;
```

Add methods (after `setMaxConcurrentDownloads` line 108):

```dart
  @override
  int getBatchDownloadLimit() => batchDownloadLimit;

  @override
  Future<void> setBatchDownloadLimit(int limit) async =>
      batchDownloadLimit = limit;
```

Add reset in `clearAll()` (after `maxConcurrentDownloads = 1;` line 170):

```dart
    batchDownloadLimit = 25;
```

- [ ] **Step 5: Add Riverpod provider**

In `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`, add after `downloadAutoDeletePlayed` provider (line 36):

```dart
/// Provider for batch download limit setting.
@riverpod
int batchDownloadLimit(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getBatchDownloadLimit();
}
```

- [ ] **Step 6: Run codegen and analyze**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
flutter analyze packages/audiflow_core packages/audiflow_domain
```

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_core/lib/src/constants/settings_keys.dart \
  packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart \
  packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart \
  packages/audiflow_domain/test/helpers/fake_app_settings_repository.dart \
  packages/audiflow_domain/lib/src/features/download/services/download_service.dart \
  packages/audiflow_domain/lib/src/features/download/services/download_service.g.dart
git commit -m "feat(settings): add batch download limit setting"
```

---

### Task 2: Add `downloadEpisodes()` to DownloadService

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart:67-295` (add method)
- Test: `packages/audiflow_domain/test/features/download/services/download_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create or open `packages/audiflow_domain/test/features/download/services/download_service_test.dart`. Add a test group for `downloadEpisodes`:

```dart
group('downloadEpisodes', () {
  test('queues downloads for given episode IDs up to limit', () async {
    // Arrange: set up 5 episodes, limit of 3
    final episodeIds = [1, 2, 3, 4, 5];
    // ... setup fakes for episodeRepo, downloadRepo, etc.

    final service = DownloadService(
      repository: fakeDownloadRepo,
      queueService: fakeQueueService,
      fileService: fakeFileService,
      episodeRepository: fakeEpisodeRepo,
      logger: Logger(level: Level.off),
      getWifiOnly: () => false,
      getAutoDeletePlayed: () => false,
      getBatchDownloadLimit: () => 3,
    );

    final queued = await service.downloadEpisodes(episodeIds);

    check(queued).equals(3);
    check(fakeDownloadRepo.createDownloadCallCount).equals(3);
  });

  test('returns 0 when episode list is empty', () async {
    final service = DownloadService(/* ... */);
    final queued = await service.downloadEpisodes([]);
    check(queued).equals(0);
  });

  test('skips episodes that already have active downloads', () async {
    // Arrange: createDownload returns null for episode 2 (already downloading)
    final service = DownloadService(/* ... */);
    final queued = await service.downloadEpisodes([1, 2, 3]);
    check(queued).equals(2); // only 1 and 3 queued
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain && flutter test test/features/download/services/download_service_test.dart
```

Expected: FAIL (method does not exist yet)

- [ ] **Step 3: Add `getBatchDownloadLimit` to DownloadService constructor**

In `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`, add to the constructor and field list:

Constructor parameter (after `getAutoDeletePlayed`):

```dart
    required int Function() getBatchDownloadLimit,
```

Field:

```dart
  final int Function() _getBatchDownloadLimit;
```

Update the `downloadService` provider (around line 51) to pass the new parameter:

```dart
    getBatchDownloadLimit: () => ref.read(batchDownloadLimitProvider),
```

- [ ] **Step 4: Implement `downloadEpisodes`**

Add after `downloadSeason` method (line 143):

```dart
  /// Downloads episodes by ID, capped at the user's batch limit.
  ///
  /// Episodes are processed in list order (reflecting display sort).
  /// Returns the number of downloads actually queued.
  Future<int> downloadEpisodes(
    List<int> episodeIds, {
    bool? wifiOnly,
  }) async {
    if (episodeIds.isEmpty) return 0;

    final limit = _getBatchDownloadLimit();
    final capped = episodeIds.length <= limit
        ? episodeIds
        : episodeIds.sublist(0, limit);

    var queued = 0;
    for (final id in capped) {
      final task = await downloadEpisode(id, wifiOnly: wifiOnly);
      if (task != null) queued++;
    }

    _logger.i('Batch download: queued $queued of ${capped.length} episodes');
    return queued;
  }
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd packages/audiflow_domain && flutter test test/features/download/services/download_service_test.dart
```

Expected: PASS

- [ ] **Step 6: Run analyze**

```bash
flutter analyze packages/audiflow_domain
```

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/download/services/download_service.dart \
  packages/audiflow_domain/lib/src/features/download/services/download_service.g.dart \
  packages/audiflow_domain/test/features/download/services/download_service_test.dart
git commit -m "feat(download): add downloadEpisodes batch method"
```

---

### Task 3: Add Localization Keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English l10n keys**

Add to `packages/audiflow_app/lib/l10n/app_en.arb` in the download section (after existing download keys):

```json
  "downloadAllEpisodes": "Download all episodes",
  "@downloadAllEpisodes": { "description": "Menu item to batch download episodes" },
  "downloadAllConfirmTitle": "Download episodes?",
  "@downloadAllConfirmTitle": { "description": "Batch download confirmation dialog title" },
  "downloadAllConfirmContent": "Download {count} episodes.",
  "@downloadAllConfirmContent": {
    "description": "Batch download confirmation body",
    "placeholders": { "count": { "type": "int" } }
  },
  "downloadAllLimitNote": "Limited to first {limit} episodes.",
  "@downloadAllLimitNote": {
    "description": "Note when episode count exceeds batch limit",
    "placeholders": { "limit": { "type": "int" } }
  },
  "downloadAllQueued": "Queued {count} downloads",
  "@downloadAllQueued": {
    "description": "Snackbar after batch download",
    "placeholders": { "count": { "type": "int" } }
  },
  "downloadsBatchLimitTitle": "Max Batch Download",
  "@downloadsBatchLimitTitle": { "description": "Settings label for batch download limit" },
  "downloadsBatchLimitSubtitle": "Maximum number of episodes to download at once",
  "@downloadsBatchLimitSubtitle": { "description": "Settings subtitle for batch download limit" },
```

- [ ] **Step 2: Add Japanese l10n keys**

Add corresponding keys to `packages/audiflow_app/lib/l10n/app_ja.arb`:

```json
  "downloadAllEpisodes": "全エピソードをダウンロード",
  "@downloadAllEpisodes": { "description": "一括ダウンロードメニュー項目" },
  "downloadAllConfirmTitle": "エピソードをダウンロードしますか？",
  "@downloadAllConfirmTitle": { "description": "一括ダウンロード確認ダイアログタイトル" },
  "downloadAllConfirmContent": "{count}件のエピソードをダウンロードします。",
  "@downloadAllConfirmContent": {
    "description": "一括ダウンロード確認本文",
    "placeholders": { "count": { "type": "int" } }
  },
  "downloadAllLimitNote": "最初の{limit}件に制限されます。",
  "@downloadAllLimitNote": {
    "description": "エピソード数が制限を超えた場合の注記",
    "placeholders": { "limit": { "type": "int" } }
  },
  "downloadAllQueued": "{count}件のダウンロードをキューに追加",
  "@downloadAllQueued": {
    "description": "一括ダウンロード後のスナックバー",
    "placeholders": { "count": { "type": "int" } }
  },
  "downloadsBatchLimitTitle": "一括ダウンロード上限",
  "@downloadsBatchLimitTitle": { "description": "一括ダウンロード制限の設定ラベル" },
  "downloadsBatchLimitSubtitle": "一度にダウンロードするエピソードの最大数",
  "@downloadsBatchLimitSubtitle": { "description": "一括ダウンロード制限の設定サブタイトル" },
```

- [ ] **Step 3: Generate l10n**

```bash
cd packages/audiflow_app && flutter gen-l10n
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add download all episodes localization keys"
```

---

### Task 4: Add Batch Download Limit to Settings Screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/downloads_settings_screen.dart`

- [ ] **Step 1: Add text input for batch download limit**

In `packages/audiflow_app/lib/features/settings/presentation/screens/downloads_settings_screen.dart`, read the current value (after line 20):

```dart
    final batchLimit = repo.getBatchDownloadLimit();
```

Add a new `ListTile` with a text field after the `SegmentedButton` Padding widget (after line 71, before the closing `]` of ListView children):

```dart
          ListTile(
            title: Text(l10n.downloadsBatchLimitTitle),
            subtitle: Text(l10n.downloadsBatchLimitSubtitle),
            trailing: SizedBox(
              width: 72,
              child: TextFormField(
                initialValue: batchLimit.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && 1 <= parsed && parsed <= 500) {
                    _update(ref, () => repo.setBatchDownloadLimit(parsed));
                  }
                },
              ),
            ),
          ),
```

- [ ] **Step 2: Verify analyze passes**

```bash
flutter analyze packages/audiflow_app
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/settings/presentation/screens/downloads_settings_screen.dart
git commit -m "feat(settings): add batch download limit input"
```

---

### Task 5: Create Batch Download Action Helper

**Files:**
- Create: `packages/audiflow_app/lib/features/download/presentation/helpers/batch_download_action_helper.dart`

- [ ] **Step 1: Create the helper file**

Create `packages/audiflow_app/lib/features/download/presentation/helpers/batch_download_action_helper.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Shows confirmation dialog and triggers batch download for the given
/// episode IDs.
Future<void> handleBatchDownload({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> episodeIds,
}) async {
  if (episodeIds.isEmpty) return;

  final l10n = AppLocalizations.of(context);
  final limit = ref.read(batchDownloadLimitProvider);
  final downloadCount = episodeIds.length <= limit
      ? episodeIds.length
      : limit;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.downloadAllConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.downloadAllConfirmContent(downloadCount)),
          if (limit < episodeIds.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.downloadAllLimitNote(limit),
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.downloadAllEpisodes),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final downloadService = ref.read(downloadServiceProvider);
  final queued = await downloadService.downloadEpisodes(episodeIds);

  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.downloadAllQueued(queued))),
  );
}
```

- [ ] **Step 2: Verify analyze passes**

```bash
flutter analyze packages/audiflow_app/lib/features/download/presentation/helpers/batch_download_action_helper.dart
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/download/presentation/helpers/batch_download_action_helper.dart
git commit -m "feat(download): add batch download action helper"
```

---

### Task 6: Replace Station Page AppBar with PopupMenuButton

**Files:**
- Modify: `packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart`

- [ ] **Step 1: Add imports**

Add to imports in `station_detail_screen.dart`:

```dart
import '../../../download/presentation/helpers/batch_download_action_helper.dart';
```

- [ ] **Step 2: Replace AppBar actions**

In `_StationDetailContentState.build` (around line 132-143), replace the `actions` list:

```dart
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push(
                    '${AppRoutes.library}/station/${widget.station.id}/edit',
                  );
                case 'download_all':
                  final ids = episodesAsync.value
                      ?.map((se) => se.episodeId)
                      .toList();
                  if (ids != null && ids.isNotEmpty) {
                    handleBatchDownload(
                      context: context,
                      ref: ref,
                      episodeIds: ids,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              final episodeCount = episodesAsync.value?.length ?? 0;
              return [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Symbols.edit),
                    title: Text(l10n.stationEditTooltip),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  enabled: 0 < episodeCount,
                  value: 'download_all',
                  child: ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(l10n.downloadAllEpisodes),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
```

- [ ] **Step 3: Verify analyze passes**

```bash
flutter analyze packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart
git commit -m "feat(station): replace edit button with popup menu"
```

---

### Task 7: Refactor Season/Group Page - Collapsible Search + PopupMenuButton

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart`

This is the largest UI change. The `SearchableAppBar` is replaced with:
1. A standard `AppBar` with title + `PopupMenuButton`
2. A `SliverAppBar` with `floating: true` containing the search field in its `bottom` slot

- [ ] **Step 1: Add imports**

Add to imports:

```dart
import '../../../download/presentation/helpers/batch_download_action_helper.dart';
import '../../../../l10n/app_localizations.dart' show AppLocalizations;
```

Note: `AppLocalizations` may already be imported. Check and add only if missing.

- [ ] **Step 2: Add search state and controller**

Add fields to `_SmartPlaylistGroupEpisodesScreenState` (after `_searchQuery` line 55):

```dart
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
```

Add dispose cleanup (in `dispose()`, before `super.dispose()`):

```dart
    _searchDebounce?.cancel();
    _searchController.dispose();
```

Add import at the top of the file:

```dart
import 'dart:async';
```

Add a search handler method (after `_toggleSortOrder`):

```dart
  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _searchQuery = text),
    );
  }
```

- [ ] **Step 3: Replace SearchableAppBar with AppBar + PopupMenuButton**

Replace the `build` method's `Scaffold` (lines 114-123):

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatGroupTitle()),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'download_all') {
                handleBatchDownload(
                  context: context,
                  ref: ref,
                  episodeIds: _episodeIds,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: _episodeIds.isNotEmpty,
                value: 'download_all',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.downloadAllEpisodes),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: _buildBody(theme),
      ),
    );
  }
```

- [ ] **Step 4: Add collapsible search SliverAppBar**

In `_buildBody`, insert a search sliver at the beginning (before the `SliverToBoxAdapter` with `_GroupHeader`):

```dart
  List<Widget> _buildBody(ThemeData theme) {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));

    final sharedThumbnailUrl = episodesAsync
        .whenData(_resolveSharedThumbnail)
        .value;

    final headerThumbnailUrl = widget.group.thumbnailUrl ?? sharedThumbnailUrl;

    return [
      SliverAppBar(
        floating: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchDebounce?.cancel();
                        setState(() => _searchQuery = '');
                      },
                    );
                  },
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: _GroupHeader(
          title: _formatGroupTitle(),
          podcastTitle: widget.podcastTitle,
          thumbnailUrl: headerThumbnailUrl,
        ),
      ),
      ..._buildEpisodeList(theme, headerThumbnailUrl: sharedThumbnailUrl),
    ];
  }
```

- [ ] **Step 5: Remove SearchableAppBar import**

Remove the import of `SearchableAppBar` (it comes from `audiflow_ui`). Check if `package:audiflow_ui/audiflow_ui.dart` barrel already imports it — if so, it's fine to leave the barrel import. Just ensure `SearchableAppBar` is no longer referenced in this file.

- [ ] **Step 6: Verify analyze passes**

```bash
flutter analyze packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart
```

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart
git commit -m "feat(season): add popup menu with download all and collapsible search"
```

---

### Task 8: Integration Testing

**Files:**
- Test: `packages/audiflow_app/test/features/station/presentation/screens/station_detail_screen_test.dart`
- Test: `packages/audiflow_app/test/features/settings/presentation/screens/downloads_settings_screen_test.dart`

- [ ] **Step 1: Write station page menu test**

Test that the PopupMenuButton renders and contains both edit and download items:

```dart
testWidgets('station detail shows popup menu with edit and download actions',
    (tester) async {
  // Arrange: pump StationDetailScreen with provider overrides
  // Act: tap the popup menu button (three-dot icon)
  // Assert: find 'Edit station' and 'Download all episodes' menu items
});
```

- [ ] **Step 2: Write settings screen batch limit test**

Test that the batch limit text field renders with default value and accepts valid input:

```dart
testWidgets('downloads settings shows batch limit field', (tester) async {
  // Arrange: pump DownloadsSettingsScreen with FakeAppSettingsRepository
  // Assert: find TextFormField with value '25'
});
```

- [ ] **Step 3: Run all tests**

```bash
cd packages/audiflow_app && flutter test
cd packages/audiflow_domain && flutter test
```

- [ ] **Step 4: Run full analyze**

```bash
flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/test/ packages/audiflow_domain/test/
git commit -m "test: add download all episodes integration tests"
```
