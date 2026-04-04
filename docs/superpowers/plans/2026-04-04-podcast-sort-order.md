# Podcast Sort Order Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to sort their subscribed podcasts by latest episode pubDate, subscription date, or alphabetically, with the choice persisted across app restarts.

**Architecture:** Add a `PodcastSortOrder` enum and a SharedPreferences-backed repository in `audiflow_domain`. A new Riverpod controller in `audiflow_app` combines the persisted sort order with the subscription stream and episode queries to produce a sorted list. The `SubscriptionsListScreen` gets a `PopupMenuButton` in its AppBar.

**Tech Stack:** Dart, Flutter, Riverpod (code generation), SharedPreferences, Isar

---

## File Map

| File | Role |
|------|------|
| `packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart` | Enum definition |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | Barrel export (add new files) |
| `packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart` | Sorted subscriptions controller + sort order notifier |
| `packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart` | Sort menu in AppBar |
| `packages/audiflow_app/lib/l10n/app_en.arb` | English sort labels |
| `packages/audiflow_app/lib/l10n/app_ja.arb` | Japanese sort labels |
| `packages/audiflow_domain/test/features/feed/models/podcast_sort_order_test.dart` | Enum unit test |
| `packages/audiflow_app/test/features/library/presentation/controllers/library_controller_test.dart` | Sorted subscriptions provider test |
| `packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart` | Widget test for sort menu |

---

### Task 1: PodcastSortOrder Enum

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/podcast_sort_order_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_domain/test/features/feed/models/podcast_sort_order_test.dart`:

```dart
import 'package:checks/checks.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

void main() {
  group('PodcastSortOrder', () {
    test('has three values', () {
      check(PodcastSortOrder.values).length.equals(3);
    });

    test('fromName returns correct value for valid names', () {
      check(PodcastSortOrder.fromName('latestEpisode'))
          .equals(PodcastSortOrder.latestEpisode);
      check(PodcastSortOrder.fromName('subscribedAt'))
          .equals(PodcastSortOrder.subscribedAt);
      check(PodcastSortOrder.fromName('alphabetical'))
          .equals(PodcastSortOrder.alphabetical);
    });

    test('fromName returns defaultValue for unknown names', () {
      check(PodcastSortOrder.fromName('unknown'))
          .equals(PodcastSortOrder.latestEpisode);
      check(PodcastSortOrder.fromName(''))
          .equals(PodcastSortOrder.latestEpisode);
    });

    test('fromName returns custom defaultValue when provided', () {
      check(
        PodcastSortOrder.fromName(
          'unknown',
          defaultValue: PodcastSortOrder.alphabetical,
        ),
      ).equals(PodcastSortOrder.alphabetical);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/podcast_sort_order_test.dart`
Expected: Compilation error -- `PodcastSortOrder` not found.

- [ ] **Step 3: Write the enum**

Create `packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart`:

```dart
/// Sort order for the podcast subscriptions list.
enum PodcastSortOrder {
  /// Sort by newest episode publishedAt (descending).
  latestEpisode,

  /// Sort by subscription date (descending).
  subscribedAt,

  /// Sort alphabetically by podcast title (ascending, case-insensitive).
  alphabetical;

  /// Parses a [name] string into a [PodcastSortOrder].
  ///
  /// Returns [defaultValue] when [name] does not match any value.
  static PodcastSortOrder fromName(
    String name, {
    PodcastSortOrder defaultValue = PodcastSortOrder.latestEpisode,
  }) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return defaultValue;
  }
}
```

- [ ] **Step 4: Add barrel export**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`, after the existing `podcast_view_mode.dart` export:

```dart
export 'src/features/feed/models/podcast_sort_order.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/podcast_sort_order_test.dart`
Expected: All 4 tests pass.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart \
       packages/audiflow_domain/lib/audiflow_domain.dart \
       packages/audiflow_domain/test/features/feed/models/podcast_sort_order_test.dart
git commit -m "feat(domain): add PodcastSortOrder enum"
```

---

### Task 2: Sorted Subscriptions Controller

**Files:**
- Modify: `packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart`
- Create: `packages/audiflow_app/test/features/library/presentation/controllers/library_controller_test.dart`

This task adds two providers to `library_controller.dart`:
1. `podcastSortOrderController` -- a `@riverpod` Notifier that reads/writes the sort order to SharedPreferences and exposes it as state.
2. `sortedSubscriptions` -- combines the subscription stream, sort order, and episode queries.

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_app/test/features/library/presentation/controllers/library_controller_test.dart`:

```dart
import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

/// Fake [EpisodeRepository] that returns canned newest episodes.
class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository({this.newestEpisodes = const {}});

  /// Map of podcastId -> newest Episode.
  final Map<int, Episode> newestEpisodes;

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async {
    return newestEpisodes[podcastId];
  }

  // -- Unused methods --

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Future<Episode?> getById(int id) => throw UnimplementedError();
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) =>
      throw UnimplementedError();
  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) =>
      throw UnimplementedError();
  @override
  Future<void> upsertEpisodes(List<Episode> episodes) =>
      throw UnimplementedError();
  @override
  Future<void> upsertFromFeedItems(int podcastId, List items,
          {SmartPlaylistEpisodeExtractor? extractor}) =>
      throw UnimplementedError();
  @override
  Future<void> upsertFromFeedItemsWithConfig(int podcastId, List items,
          {required SmartPlaylistPatternConfig config}) =>
      throw UnimplementedError();
  @override
  Future<List<Episode>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
          int podcastId, List mediaMetas) =>
      throw UnimplementedError();
  @override
  Future<List<Episode>> getSubsequentEpisodes(
          {required int podcastId,
          required int? afterEpisodeNumber,
          required int limit}) =>
      throw UnimplementedError();
}

Subscription _sub(int id, String title, DateTime subscribedAt) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/$id'
    ..title = title
    ..artistName = 'Artist $id'
    ..subscribedAt = subscribedAt;
}

Episode _episode(int podcastId, DateTime publishedAt) {
  return Episode()
    ..id = podcastId * 100
    ..podcastId = podcastId
    ..guid = 'guid_$podcastId'
    ..title = 'Episode'
    ..audioUrl = 'https://example.com/$podcastId.mp3'
    ..publishedAt = publishedAt;
}

void main() {
  group('PodcastSortOrderController', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to latestEpisode', () async {
      final order = await container.read(
        podcastSortOrderControllerProvider.future,
      );
      check(order).equals(PodcastSortOrder.latestEpisode);
    });

    test('persists and reads back sort order', () async {
      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.alphabetical);

      final order = await container.read(
        podcastSortOrderControllerProvider.future,
      );
      check(order).equals(PodcastSortOrder.alphabetical);
    });
  });

  group('sortedSubscriptionsProvider', () {
    late ProviderContainer container;
    late StreamController<List<Subscription>> subsController;

    final now = DateTime(2026, 4, 1);
    final podcastA = _sub(1, 'Alpha Podcast', now);
    final podcastB = _sub(2, 'Beta Podcast', now.subtract(const Duration(days: 1)));
    final podcastC = _sub(3, 'Charlie Podcast', now.subtract(const Duration(days: 2)));

    // Episode dates: B has newest episode, then C, then A.
    final episodeA = _episode(1, DateTime(2026, 3, 1));
    final episodeB = _episode(2, DateTime(2026, 3, 30));
    final episodeC = _episode(3, DateTime(2026, 3, 15));

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      subsController = StreamController<List<Subscription>>();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider
              .overrideWith((ref) => subsController.stream),
          episodeRepositoryProvider.overrideWithValue(
            _FakeEpisodeRepository(newestEpisodes: {
              1: episodeA,
              2: episodeB,
              3: episodeC,
            }),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      subsController.close();
    });

    test('sorts by latest episode pubDate (default)', () async {
      subsController.add([podcastA, podcastB, podcastC]);

      // Wait for the provider to process
      await container.read(sortedSubscriptionsProvider.future);

      final result = await container.read(sortedSubscriptionsProvider.future);
      check(result.map((s) => s.id).toList()).deepEquals([2, 3, 1]);
    });

    test('sorts by subscription date', () async {
      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.subscribedAt);

      subsController.add([podcastA, podcastB, podcastC]);
      await container.read(sortedSubscriptionsProvider.future);

      final result = await container.read(sortedSubscriptionsProvider.future);
      // newest subscribedAt first: A (Apr 1), B (Mar 31), C (Mar 30)
      check(result.map((s) => s.id).toList()).deepEquals([1, 2, 3]);
    });

    test('sorts alphabetically', () async {
      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.alphabetical);

      subsController.add([podcastC, podcastA, podcastB]);
      await container.read(sortedSubscriptionsProvider.future);

      final result = await container.read(sortedSubscriptionsProvider.future);
      check(result.map((s) => s.id).toList()).deepEquals([1, 2, 3]);
    });

    test('podcasts with no episodes sort last for latestEpisode', () async {
      final podcastD = _sub(4, 'Delta Podcast', now);
      subsController.add([podcastD, podcastB]);

      await container.read(sortedSubscriptionsProvider.future);

      final result = await container.read(sortedSubscriptionsProvider.future);
      // B has an episode, D does not -> B first, D last
      check(result.map((s) => s.id).toList()).deepEquals([2, 4]);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/library/presentation/controllers/library_controller_test.dart`
Expected: Compilation error -- `podcastSortOrderControllerProvider`, `sortedSubscriptionsProvider` not found.

- [ ] **Step 3: Write the controller**

Replace the contents of `packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_controller.g.dart';

/// SharedPreferences key for persisted podcast sort order.
const _podcastSortOrderKey = 'podcast_sort_order';

/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.
@riverpod
Stream<List<Subscription>> librarySubscriptions(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
}

/// Manages the persisted podcast sort order preference.
@riverpod
class PodcastSortOrderController extends _$PodcastSortOrderController {
  @override
  Future<PodcastSortOrder> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_podcastSortOrderKey);
    if (stored == null) return PodcastSortOrder.latestEpisode;
    return PodcastSortOrder.fromName(stored);
  }

  /// Persists [order] and updates state.
  Future<void> setSortOrder(PodcastSortOrder order) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_podcastSortOrderKey, order.name);
    state = AsyncData(order);
  }
}

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with [podcastSortOrderControllerProvider]
/// and episode data (for latestEpisode sort).
@riverpod
Future<List<Subscription>> sortedSubscriptions(Ref ref) async {
  final subscriptions = await ref.watch(librarySubscriptionsProvider.future);
  final sortOrder = await ref.watch(podcastSortOrderControllerProvider.future);

  switch (sortOrder) {
    case PodcastSortOrder.subscribedAt:
      return _sortBySubscribedAt(subscriptions);
    case PodcastSortOrder.alphabetical:
      return _sortAlphabetically(subscriptions);
    case PodcastSortOrder.latestEpisode:
      final episodeRepo = ref.watch(episodeRepositoryProvider);
      return _sortByLatestEpisode(subscriptions, episodeRepo);
  }
}

List<Subscription> _sortBySubscribedAt(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort((a, b) => b.subscribedAt.compareTo(a.subscribedAt));
  return sorted;
}

List<Subscription> _sortAlphabetically(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort(
    (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  );
  return sorted;
}

Future<List<Subscription>> _sortByLatestEpisode(
  List<Subscription> subscriptions,
  EpisodeRepository episodeRepo,
) async {
  // Fetch newest episode date per podcast in parallel.
  final futures = subscriptions.map((s) async {
    final episode = await episodeRepo.getNewestByPodcastId(s.id);
    return (subscription: s, latestPubDate: episode?.publishedAt);
  });
  final entries = await Future.wait(futures);

  // Sort: podcasts with episodes first (newest episode descending),
  // then podcasts with no episodes (sorted by subscribedAt descending).
  final sorted = List.of(entries);
  sorted.sort((a, b) {
    final aDate = a.latestPubDate;
    final bDate = b.latestPubDate;
    if (aDate != null && bDate != null) return bDate.compareTo(aDate);
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    return b.subscription.subscribedAt.compareTo(a.subscription.subscribedAt);
  });

  return sorted.map((e) => e.subscription).toList();
}
```

- [ ] **Step 4: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `library_controller.g.dart` with new providers.

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/library/presentation/controllers/library_controller_test.dart`
Expected: All tests pass.

- [ ] **Step 6: Run existing library screen test to check for regressions**

Run: `cd packages/audiflow_app && flutter test test/features/library/presentation/screens/library_screen_test.dart`
Expected: All existing tests pass (they use `librarySubscriptionsProvider` which still exists).

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart \
       packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.g.dart \
       packages/audiflow_app/test/features/library/presentation/controllers/library_controller_test.dart
git commit -m "feat(app): add sorted subscriptions controller with persistence"
```

---

### Task 3: Localization Keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English l10n keys**

Add to `packages/audiflow_app/lib/l10n/app_en.arb`, after the `libraryLoadError` entry:

```json
  "librarySortByLatestEpisode": "Latest episode",
  "@librarySortByLatestEpisode": { "description": "Sort podcasts by latest episode date" },
  "librarySortBySubscribedAt": "Subscription date",
  "@librarySortBySubscribedAt": { "description": "Sort podcasts by subscription date" },
  "librarySortByAlphabetical": "Alphabetical",
  "@librarySortByAlphabetical": { "description": "Sort podcasts alphabetically" },
```

- [ ] **Step 2: Add Japanese l10n keys**

Add to `packages/audiflow_app/lib/l10n/app_ja.arb`, after the corresponding library section:

```json
  "librarySortByLatestEpisode": "最新エピソード順",
  "librarySortBySubscribedAt": "登録日順",
  "librarySortByAlphabetical": "名前順",
```

- [ ] **Step 3: Generate l10n**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Generates updated `AppLocalizations` with the new keys.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add podcast sort order labels (en, ja)"
```

---

### Task 4: Sort Menu in SubscriptionsListScreen

**Files:**
- Modify: `packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart`
- Create: `packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart`:

```dart
import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/screens/subscriptions_list_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Subscription _sub(int id, String title) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/$id'
    ..title = title
    ..artistName = 'Artist'
    ..subscribedAt = DateTime(2026, 1, id);
}

void main() {
  group('SubscriptionsListScreen sort menu', () {
    late ProviderContainer container;

    Widget buildTestWidget() {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SubscriptionsListScreen(),
        ),
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sortedSubscriptionsProvider.overrideWith(
            (ref) async => [_sub(1, 'Alpha'), _sub(2, 'Beta')],
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    testWidgets('displays sort icon button in AppBar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('opens popup menu with three sort options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Latest episode'), findsOneWidget);
      expect(find.text('Subscription date'), findsOneWidget);
      expect(find.text('Alphabetical'), findsOneWidget);
    });

    testWidgets('shows check icon on current sort order', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Default is latestEpisode, so check icon appears on that item
      final latestItem = find.ancestor(
        of: find.text('Latest episode'),
        matching: find.byType(PopupMenuItem<PodcastSortOrder>),
      );
      expect(latestItem, findsOneWidget);
      // The check icon should be present in the menu
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/library/presentation/screens/subscriptions_list_screen_test.dart`
Expected: Fail -- `sortedSubscriptionsProvider` not used in screen yet, no sort icon found.

- [ ] **Step 3: Update SubscriptionsListScreen**

Replace `packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/library_controller.dart';
import '../widgets/subscription_list_tile.dart';

/// Full-screen list of podcast subscriptions.
///
/// Extracted from [LibraryScreen] to allow direct navigation from the
/// collapsed subscriptions row in the redesigned Library tab.
class SubscriptionsListScreen extends ConsumerStatefulWidget {
  const SubscriptionsListScreen({super.key});

  @override
  ConsumerState<SubscriptionsListScreen> createState() =>
      _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState
    extends ConsumerState<SubscriptionsListScreen> {
  Future<void> _onRefresh() async {
    final syncService = ref.read(feedSyncServiceProvider);
    final result = await syncService.syncAllSubscriptions(forceRefresh: true);
    if (!mounted) return;

    ref.invalidate(librarySubscriptionsProvider);

    final l10n = AppLocalizations.of(context);

    if (0 < result.errorCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.librarySyncResult(result.successCount, result.errorCount),
          ),
        ),
      );
    } else if (0 < result.successCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.librarySyncSuccess(result.successCount))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final sortOrderAsync = ref.watch(podcastSortOrderControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryYourPodcasts),
        actions: [
          sortOrderAsync.when(
            data: (currentOrder) => _SortMenuButton(
              currentOrder: currentOrder,
              onSelected: (order) {
                ref
                    .read(podcastSortOrderControllerProvider.notifier)
                    .setSortOrder(order);
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) => _buildContent(context, subscriptions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(sortedSubscriptionsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columnCount = ResponsiveGrid.columnCount(
                  availableWidth: constraints.crossAxisExtent,
                );
                if (columnCount <= 3) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final subscription = subscriptions[index];
                      return SubscriptionListTile(
                        key: ValueKey(subscription.itunesId),
                        subscription: subscription,
                        onTap: () {
                          final podcast = subscription.toPodcast();
                          context.push(
                            '${AppRoutes.subscriptions}/podcast/${podcast.id}',
                            extra: podcast,
                          );
                        },
                      );
                    }, childCount: subscriptions.length),
                  );
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: Spacing.sm,
                    crossAxisSpacing: Spacing.sm,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subscription = subscriptions[index];
                    return PodcastArtworkGridItem(
                      artworkUrl: subscription.artworkUrl,
                      title: subscription.title,
                      onTap: () {
                        final podcast = subscription.toPodcast();
                        context.push(
                          '${AppRoutes.subscriptions}/podcast/${podcast.id}',
                          extra: podcast,
                        );
                      },
                    );
                  }, childCount: subscriptions.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(l10n.libraryEmpty, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.libraryEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.libraryLoadError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({
    required this.currentOrder,
    required this.onSelected,
  });

  final PodcastSortOrder currentOrder;
  final ValueChanged<PodcastSortOrder> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<PodcastSortOrder>(
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildItem(
          PodcastSortOrder.latestEpisode,
          l10n.librarySortByLatestEpisode,
        ),
        _buildItem(
          PodcastSortOrder.subscribedAt,
          l10n.librarySortBySubscribedAt,
        ),
        _buildItem(
          PodcastSortOrder.alphabetical,
          l10n.librarySortByAlphabetical,
        ),
      ],
    );
  }

  PopupMenuItem<PodcastSortOrder> _buildItem(
    PodcastSortOrder order,
    String label,
  ) {
    return PopupMenuItem<PodcastSortOrder>(
      value: order,
      child: Row(
        children: [
          if (order == currentOrder)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 20),
            )
          else
            const SizedBox(width: 28),
          Text(label),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/library/presentation/screens/subscriptions_list_screen_test.dart`
Expected: All 3 widget tests pass.

- [ ] **Step 5: Run full test suite for regressions**

Run: `cd packages/audiflow_app && flutter test test/features/library/`
Expected: All library tests pass.

- [ ] **Step 6: Run analyzer**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart \
       packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart
git commit -m "feat(app): add podcast sort menu to subscriptions list screen"
```

---

### Task 5: Final Verification

**Files:** None (verification only)

- [ ] **Step 1: Run full domain test suite**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run full app test suite**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests pass.

- [ ] **Step 3: Run analyzer across workspace**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 4: Run melos test**

Run: `melos run test`
Expected: All packages pass.
