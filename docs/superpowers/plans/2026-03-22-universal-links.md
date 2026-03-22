# Universal Links & Share Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable sharing episodes and podcasts via universal links that open in Audiflow, with fallback to app stores.

**Architecture:** Two subsystems: (1) outbound sharing via `ShareLinkBuilder` that constructs `https://audiflow.reedom.com/p/{itunesId}/e/{base64url(guid)}` URLs, and (2) inbound deep linking via `DeepLinkResolver` + GoRouter routes that resolve universal links to podcast/episode screens. A static GitHub Pages site serves association files and store redirects.

**Tech Stack:** Flutter, GoRouter deep links, share_plus, Riverpod, Isar, iTunes Lookup API, GitHub Pages

**Spec:** `docs/superpowers/specs/2026-03-22-universal-links-design.md`

---

## File Map

### audiflow_domain (new files)

| File | Responsibility |
|------|---------------|
| `lib/src/features/share/models/deep_link_target.dart` | `@freezed` sealed class with `.podcast()` and `.episode()` variants |
| `lib/src/features/share/services/share_link_builder.dart` | Abstract interface for building share URLs |
| `lib/src/features/share/services/share_link_builder_impl.dart` | Implementation: subscription lookup + Base64url encoding |
| `lib/src/features/share/services/deep_link_resolver.dart` | Abstract interface for resolving inbound URIs |
| `lib/src/features/share/services/deep_link_resolver_impl.dart` | Implementation: URI parsing + local/remote lookup |
| `lib/src/features/share/providers/share_providers.dart` | Riverpod providers for both services |
| `test/features/share/services/share_link_builder_impl_test.dart` | Unit tests for URL construction + encoding |
| `test/features/share/services/deep_link_resolver_impl_test.dart` | Unit tests for URI parsing + resolution |

### audiflow_domain (modified files)

| File | Change |
|------|--------|
| `lib/src/features/feed/repositories/episode_repository.dart` | Add `getByPodcastIdAndGuid(int, String)` method |
| `lib/src/features/feed/repositories/episode_repository_impl.dart` | Implement the new method |
| `lib/audiflow_domain.dart` | Export new share feature files |

### audiflow_app (new files)

| File | Responsibility |
|------|---------------|
| `lib/features/share/presentation/screens/deep_link_screen.dart` | Loading screen during deep link resolution |
| `lib/features/share/presentation/helpers/share_helper.dart` | Shared share logic for episode/podcast |
| `test/features/share/presentation/helpers/share_helper_test.dart` | Tests for share helper fallback logic |

### audiflow_app (modified files)

| File | Change |
|------|--------|
| `lib/routing/app_router.dart` | Add `AppRoutes` constants + 2 top-level deep link routes |
| `lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart` | Wire share button |
| `lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart` | Wire share button |
| `lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart` | Replace share with universal link |
| `lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart` | Add podcast share button |
| `lib/l10n/app_en.arb` | Add 6 l10n keys |
| `lib/l10n/app_ja.arb` | Add 6 l10n keys |

### Platform config (modified files)

| File | Change |
|------|--------|
| `ios/Runner/Runner.entitlements` | Add `applinks:audiflow.reedom.com` |
| `android/app/src/main/AndroidManifest.xml` | Add `autoVerify` intent-filter |

### Static site (separate repo: `audiflow/audiflow-universal-links`)

| File | Responsibility |
|------|---------------|
| `.nojekyll` | Disable Jekyll |
| `.well-known/apple-app-site-association` | iOS Universal Links config |
| `.well-known/assetlinks.json` | Android App Links config |
| `index.html` | Root store redirect |
| `404.html` | Catch-all store redirect for all `/p/...` paths |
| `CNAME` | Custom domain `audiflow.reedom.com` |

---

## Task 1: Add `getByPodcastIdAndGuid` to EpisodeRepository

The deep link resolver needs to look up episodes by podcast ID + GUID. The datasource already has this method but the repository interface doesn't expose it.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart`
- Test: `packages/audiflow_domain/test/features/feed/repositories/episode_repository_impl_test.dart`

- [ ] **Step 1: Write the failing test**

Add to the existing test file:

```dart
test('getByPodcastIdAndGuid returns episode when found', () async {
  // Arrange: insert an episode with known podcastId and guid
  final episode = Episode()
    ..podcastId = 1
    ..guid = 'test-guid-123'
    ..title = 'Test Episode'
    ..audioUrl = 'https://example.com/audio.mp3';
  await isar.writeTxn(() => isar.episodes.put(episode));

  // Act
  final result = await repository.getByPodcastIdAndGuid(1, 'test-guid-123');

  // Assert
  check(result).isNotNull();
  check(result!.guid).equals('test-guid-123');
  check(result.podcastId).equals(1);
});

test('getByPodcastIdAndGuid returns null when not found', () async {
  final result = await repository.getByPodcastIdAndGuid(999, 'nonexistent');
  check(result).isNull();
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/repositories/episode_repository_impl_test.dart`
Expected: FAIL — `getByPodcastIdAndGuid` not defined on interface

- [ ] **Step 3: Add method to interface**

In `episode_repository.dart`, add after `getByAudioUrl`:

```dart
/// Returns an episode by podcast ID and GUID, or null if not found.
Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid);
```

- [ ] **Step 4: Implement in repository**

In `episode_repository_impl.dart`, add:

```dart
@override
Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) {
  return _localDatasource.getByPodcastIdAndGuid(podcastId, guid);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/repositories/episode_repository_impl_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart packages/audiflow_domain/test/features/feed/repositories/episode_repository_impl_test.dart
git commit -m "feat(domain): add getByPodcastIdAndGuid to EpisodeRepository"
```

---

## Task 2: Create `DeepLinkTarget` model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/share/models/deep_link_target.dart`

- [ ] **Step 1: Create the freezed model**

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../player/models/episode_with_progress.dart';

part 'deep_link_target.freezed.dart';

@freezed
sealed class DeepLinkTarget with _$DeepLinkTarget {
  const factory DeepLinkTarget.podcast({
    required String itunesId,
    required String feedUrl,
    required String title,
    String? artworkUrl,
  }) = PodcastDeepLinkTarget;

  const factory DeepLinkTarget.episode({
    required String itunesId,
    required PodcastItem episode,
    required String podcastTitle,
    String? artworkUrl,
    EpisodeWithProgress? progress,
  }) = EpisodeDeepLinkTarget;
}
```

- [ ] **Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `deep_link_target.freezed.dart`

- [ ] **Step 3: Verify analyze passes**

Run: `cd packages/audiflow_domain && flutter analyze lib/src/features/share/`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/share/
git commit -m "feat(domain): add DeepLinkTarget freezed model"
```

---

## Task 3: Create `ShareLinkBuilder` service

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/share/services/share_link_builder.dart`
- Create: `packages/audiflow_domain/lib/src/features/share/services/share_link_builder_impl.dart`
- Create: `packages/audiflow_domain/test/features/share/services/share_link_builder_impl_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:audiflow_domain/src/features/share/services/share_link_builder.dart';
import 'package:audiflow_domain/src/features/share/services/share_link_builder_impl.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeSubscriptionRepository fakeSubRepo;
  late ShareLinkBuilder builder;

  setUp(() {
    fakeSubRepo = FakeSubscriptionRepository();
    builder = ShareLinkBuilderImpl(subscriptionRepository: fakeSubRepo);
  });

  group('buildPodcastLink', () {
    test('returns URL with itunesId from subscription', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildPodcastLink(subscriptionId: 1);

      check(result).isNotNull();
      check(result!).equals('https://audiflow.reedom.com/p/1234567');
    });

    test('returns null when subscription not found', () async {
      final result = await builder.buildPodcastLink(subscriptionId: 999);
      check(result).isNull();
    });
  });

  group('buildEpisodeLink', () {
    test('returns URL with itunesId and base64url-encoded guid', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildEpisodeLink(
        subscriptionId: 1,
        episodeGuid: 'test-guid',
      );

      check(result).isNotNull();
      // 'test-guid' in base64url without padding = 'dGVzdC1ndWlk'
      check(result!).equals(
        'https://audiflow.reedom.com/p/1234567/e/dGVzdC1ndWlk',
      );
    });

    test('encodes guid with special characters correctly', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildEpisodeLink(
        subscriptionId: 1,
        episodeGuid: 'https://example.com/ep/1?v=2',
      );

      check(result).isNotNull();
      // Must not contain +, /, or = (base64url without padding)
      check(result!).not((it) => it.contains('+'));
      check(result).not((it) => it.contains('/e/').which((s) {
        // The part after /e/ should not contain standard base64 chars
        final encoded = result.split('/e/').last;
        return encoded.contains('+') || encoded.contains('/') || encoded.contains('=');
      }));
    });

    test('returns null when subscription not found', () async {
      final result = await builder.buildEpisodeLink(
        subscriptionId: 999,
        episodeGuid: 'test-guid',
      );
      check(result).isNull();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/share/services/share_link_builder_impl_test.dart`
Expected: FAIL — files don't exist yet

- [ ] **Step 3: Create the interface**

`share_link_builder.dart`:

```dart
/// Builds shareable universal link URLs for podcasts and episodes.
abstract class ShareLinkBuilder {
  /// Build a universal link for a podcast.
  ///
  /// [subscriptionId] is the Isar database `Subscription.id`.
  /// Returns null if the subscription has no known servicer ID.
  Future<String?> buildPodcastLink({required int subscriptionId});

  /// Build a universal link for an episode.
  ///
  /// [subscriptionId] is the Isar database `Subscription.id`.
  /// [episodeGuid] is the RSS GUID for the episode.
  /// Returns null if the subscription has no known servicer ID.
  Future<String?> buildEpisodeLink({
    required int subscriptionId,
    required String episodeGuid,
  });
}
```

- [ ] **Step 4: Create the implementation**

`share_link_builder_impl.dart`:

```dart
import 'dart:convert';

import '../../subscription/repositories/subscription_repository.dart';
import 'share_link_builder.dart';

class ShareLinkBuilderImpl implements ShareLinkBuilder {
  ShareLinkBuilderImpl({required SubscriptionRepository subscriptionRepository})
    : _subscriptionRepository = subscriptionRepository;

  final SubscriptionRepository _subscriptionRepository;

  static const _baseUrl = 'https://audiflow.reedom.com';

  @override
  Future<String?> buildPodcastLink({required int subscriptionId}) async {
    final subscription = await _subscriptionRepository.getById(subscriptionId);
    if (subscription == null) return null;

    return '$_baseUrl/p/${subscription.itunesId}';
  }

  @override
  Future<String?> buildEpisodeLink({
    required int subscriptionId,
    required String episodeGuid,
  }) async {
    final subscription = await _subscriptionRepository.getById(subscriptionId);
    if (subscription == null) return null;

    final encodedGuid = base64Url.encode(utf8.encode(episodeGuid)).replaceAll('=', '');
    return '$_baseUrl/p/${subscription.itunesId}/e/$encodedGuid';
  }
}
```

- [ ] **Step 5: Add FakeSubscriptionRepository helper if needed**

Check the existing test fakes file. If `addSubscription` helper doesn't exist, add it to the fake to support setting `id` and `itunesId`.

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd packages/audiflow_domain && flutter test test/features/share/services/share_link_builder_impl_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/share/services/ packages/audiflow_domain/test/features/share/
git commit -m "feat(domain): add ShareLinkBuilder service with base64url encoding"
```

---

## Task 4: Create `DeepLinkResolver` service

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/share/services/deep_link_resolver.dart`
- Create: `packages/audiflow_domain/lib/src/features/share/services/deep_link_resolver_impl.dart`
- Create: `packages/audiflow_domain/test/features/share/services/deep_link_resolver_impl_test.dart`

- [ ] **Step 1: Write the failing tests**

Focus on URI parsing logic first (no network calls):

```dart
void main() {
  late FakeSubscriptionRepository fakeSubRepo;
  late FakeEpisodeRepository fakeEpisodeRepo;
  late FakeFeedParserService fakeFeedParser;
  late FakeItunesChartsClient fakeItunesClient;
  late DeepLinkResolver resolver;

  setUp(() {
    fakeSubRepo = FakeSubscriptionRepository();
    fakeEpisodeRepo = FakeEpisodeRepository();
    fakeFeedParser = FakeFeedParserService();
    fakeItunesClient = FakeItunesChartsClient();
    resolver = DeepLinkResolverImpl(
      subscriptionRepository: fakeSubRepo,
      episodeRepository: fakeEpisodeRepo,
      feedParserService: fakeFeedParser,
      itunesChartsClient: fakeItunesClient,
    );
  });

  test('returns null for non-audiflow URLs', () async {
    final result = await resolver.resolve(Uri.parse('https://google.com'));
    check(result).isNull();
  });

  test('returns null for http scheme', () async {
    final result = await resolver.resolve(
      Uri.parse('http://audiflow.reedom.com/p/123'),
    );
    check(result).isNull();
  });

  test('returns null for paths not starting with /p/', () async {
    final result = await resolver.resolve(
      Uri.parse('https://audiflow.reedom.com/other/path'),
    );
    check(result).isNull();
  });

  test('resolves podcast link for subscribed podcast', () async {
    fakeSubRepo.addSubscription(
      itunesId: '1234567',
      feedUrl: 'https://example.com/feed.xml',
      title: 'Test Podcast',
      artworkUrl: 'https://example.com/art.jpg',
    );

    final result = await resolver.resolve(
      Uri.parse('https://audiflow.reedom.com/p/1234567'),
    );

    check(result).isA<PodcastDeepLinkTarget>();
    final podcast = result! as PodcastDeepLinkTarget;
    check(podcast.itunesId).equals('1234567');
    check(podcast.feedUrl).equals('https://example.com/feed.xml');
    check(podcast.title).equals('Test Podcast');
  });

  test('resolves podcast link via iTunes API when not subscribed', () async {
    fakeItunesClient.setPodcast(Podcast(
      id: '1234567',
      name: 'Remote Podcast',
      artistName: 'Artist',
      feedUrl: 'https://example.com/feed.xml',
      artworkUrl: 'https://example.com/art.jpg',
    ));

    final result = await resolver.resolve(
      Uri.parse('https://audiflow.reedom.com/p/1234567'),
    );

    check(result).isA<PodcastDeepLinkTarget>();
  });

  test('decodes base64url episode guid correctly', () async {
    fakeSubRepo.addSubscription(
      itunesId: '1234567',
      feedUrl: 'https://example.com/feed.xml',
      title: 'Test Podcast',
    );
    // 'dGVzdC1ndWlk' is base64url of 'test-guid'
    fakeEpisodeRepo.addEpisode(podcastId: 1, guid: 'test-guid');

    final result = await resolver.resolve(
      Uri.parse('https://audiflow.reedom.com/p/1234567/e/dGVzdC1ndWlk'),
    );

    check(result).isA<EpisodeDeepLinkTarget>();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/share/services/deep_link_resolver_impl_test.dart`
Expected: FAIL — files don't exist

- [ ] **Step 3: Create the interface**

`deep_link_resolver.dart`:

```dart
import '../models/deep_link_target.dart';

/// Resolves incoming universal link URIs to navigation targets.
abstract class DeepLinkResolver {
  /// Parse and resolve a universal link URI.
  ///
  /// Returns null if the URI is not a recognized audiflow link.
  /// Throws on network failure.
  Future<DeepLinkTarget?> resolve(Uri uri);
}
```

- [ ] **Step 4: Create the implementation**

`deep_link_resolver_impl.dart`:

```dart
import 'dart:convert';

import 'package:audiflow_search/audiflow_search.dart';

import '../../feed/repositories/episode_repository.dart';
import '../../feed/services/feed_parser_service.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/deep_link_target.dart';
import 'deep_link_resolver.dart';

class DeepLinkResolverImpl implements DeepLinkResolver {
  DeepLinkResolverImpl({
    required SubscriptionRepository subscriptionRepository,
    required EpisodeRepository episodeRepository,
    required FeedParserService feedParserService,
    required ItunesChartsClient itunesChartsClient,
  })  : _subscriptionRepository = subscriptionRepository,
        _episodeRepository = episodeRepository,
        _feedParserService = feedParserService,
        _itunesChartsClient = itunesChartsClient;

  final SubscriptionRepository _subscriptionRepository;
  final EpisodeRepository _episodeRepository;
  final FeedParserService _feedParserService;
  final ItunesChartsClient _itunesChartsClient;

  static const _host = 'audiflow.reedom.com';

  @override
  Future<DeepLinkTarget?> resolve(Uri uri) async {
    if (uri.scheme != 'https' || uri.host != _host) return null;

    final segments = uri.pathSegments;
    // Must be /p/{itunesId} or /p/{itunesId}/e/{encodedGuid}
    if (segments.length < 2 || segments[0] != 'p') return null;

    final itunesId = segments[1];
    final hasEpisode = 4 <= segments.length &&
        segments[2] == 'e' &&
        segments[3].isNotEmpty;

    // 1. Resolve podcast: local subscription first, then iTunes API
    final subscription = await _subscriptionRepository.getSubscription(itunesId);
    String feedUrl;
    String title;
    String? artworkUrl;

    if (subscription != null) {
      feedUrl = subscription.feedUrl;
      title = subscription.title;
      artworkUrl = subscription.artworkUrl;
    } else {
      // audiflow_search Podcast model -> extract fields
      final remotePodcast = await _itunesChartsClient.lookupPodcast(itunesId);
      if (remotePodcast == null) return null;
      feedUrl = remotePodcast.feedUrl ?? '';
      title = remotePodcast.name;
      artworkUrl = remotePodcast.artworkUrl;
      if (feedUrl.isEmpty) return null;
    }

    // 2. Podcast-only link
    if (!hasEpisode) {
      return DeepLinkTarget.podcast(
        itunesId: itunesId,
        feedUrl: feedUrl,
        title: title,
        artworkUrl: artworkUrl,
      );
    }

    // 3. Episode link: decode GUID and resolve
    final encodedGuid = segments[3];
    final guid = utf8.decode(base64Url.decode(base64Url.normalize(encodedGuid)));

    // Try local lookup first (only if we have a subscription with an ID)
    if (subscription != null) {
      final localEpisode = await _episodeRepository.getByPodcastIdAndGuid(
        subscription.id,
        guid,
      );
      if (localEpisode != null) {
        // Convert Isar Episode to PodcastItem for the detail screen
        final podcastItem = PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: localEpisode.audioUrl,
          title: localEpisode.title,
          description: localEpisode.description ?? '',
          publishDate: localEpisode.publishedAt,
          duration: localEpisode.durationMs != null
              ? Duration(milliseconds: localEpisode.durationMs!)
              : null,
          enclosureUrl: localEpisode.audioUrl,
          guid: localEpisode.guid,
          episodeNumber: localEpisode.episodeNumber,
          seasonNumber: localEpisode.seasonNumber,
          images: localEpisode.imageUrl != null
              ? [PodcastImage(url: localEpisode.imageUrl!)]
              : const [],
        );
        // progress is null here; the detail screen will fetch it
        return DeepLinkTarget.episode(
          itunesId: itunesId,
          episode: podcastItem,
          podcastTitle: title,
          artworkUrl: artworkUrl,
        );
      }
    }

    // Fetch feed and find episode by GUID
    final feedResult = await _feedParserService.parseFromUrl(feedUrl);
    final matchingItem = feedResult.episodes.where(
      (ep) => ep.guid == guid,
    ).firstOrNull;

    if (matchingItem == null) {
      // Episode not found in feed, return podcast target instead
      return DeepLinkTarget.podcast(
        itunesId: itunesId,
        feedUrl: feedUrl,
        title: title,
        artworkUrl: artworkUrl,
      );
    }

    return DeepLinkTarget.episode(
      itunesId: itunesId,
      episode: matchingItem,
      podcastTitle: title,
      artworkUrl: artworkUrl,
    );
  }
}
```

Note on model mapping: `audiflow_search.Podcast` (used by iTunes lookup) has fields `id`, `name`, `feedUrl`, `artworkUrl`. These map to `DeepLinkTarget.podcast`'s `itunesId`, `title`, `feedUrl`, `artworkUrl` respectively. The `progress` field on `EpisodeDeepLinkTarget` is left null during deep link resolution; the episode detail screen fetches it independently.

- [ ] **Step 5: Create necessary fakes**

Add `FakeItunesChartsClient` and any missing fakes to test helpers. The fake needs a `setPodcast(Podcast)` method that stores a podcast to return from `lookupPodcast`. Also add `FakeFeedParserService` with a `setFeedResult` method that returns a `FeedParseResult` from `parseFeed()`.

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd packages/audiflow_domain && flutter test test/features/share/services/deep_link_resolver_impl_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/share/services/deep_link_resolver*.dart packages/audiflow_domain/test/features/share/
git commit -m "feat(domain): add DeepLinkResolver service for inbound universal links"
```

---

## Task 5: Create Riverpod providers and export from barrel

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/share/providers/share_providers.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Create providers**

```dart
import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feed/providers/feed_providers.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../services/deep_link_resolver.dart';
import '../services/deep_link_resolver_impl.dart';
import '../services/share_link_builder.dart';
import '../services/share_link_builder_impl.dart';

part 'share_providers.g.dart';

@Riverpod(keepAlive: true)
ItunesChartsClient itunesChartsClient(Ref ref) {
  return ItunesChartsClient();
}

@riverpod
ShareLinkBuilder shareLinkBuilder(Ref ref) {
  return ShareLinkBuilderImpl(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
  );
}

@riverpod
DeepLinkResolver deepLinkResolver(Ref ref) {
  return DeepLinkResolverImpl(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    feedParserService: ref.watch(feedParserServiceProvider),
    itunesChartsClient: ref.watch(itunesChartsClientProvider),
  );
}
```

Note: `ItunesChartsClient` is kept alive to avoid recreating HTTP clients. Check the constructor — if it requires a Dio instance, inject it from the existing `httpClientProvider`.

- [ ] **Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `share_providers.g.dart`

- [ ] **Step 3: Add exports to barrel file**

Add to `audiflow_domain.dart`:

```dart
// Share feature
export 'src/features/share/models/deep_link_target.dart';
export 'src/features/share/services/share_link_builder.dart';
export 'src/features/share/services/deep_link_resolver.dart';
export 'src/features/share/providers/share_providers.dart';
```

- [ ] **Step 4: Verify analyze passes**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/share/providers/ packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add share providers and export share feature"
```

---

## Task 6: Add localization keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English keys**

Add to `app_en.arb`:

```json
"deepLinkPodcastNotFound": "Podcast not found",
"@deepLinkPodcastNotFound": { "description": "Snackbar when deep link podcast resolution fails" },
"deepLinkEpisodeNotFound": "Episode not found",
"@deepLinkEpisodeNotFound": { "description": "Snackbar when episode resolution fails" },
"deepLinkNetworkError": "Could not load, check your connection",
"@deepLinkNetworkError": { "description": "Snackbar on network failure during deep link resolution" },
"deepLinkLoading": "Opening link...",
"@deepLinkLoading": { "description": "Loading screen text during deep link resolution" },
"sharePodcast": "Share podcast",
"@sharePodcast": { "description": "Tooltip for podcast share button" },
"shareEpisode": "Share episode",
"@shareEpisode": { "description": "Tooltip for episode share button" }
```

- [ ] **Step 2: Add Japanese keys**

Add to `app_ja.arb`:

```json
"deepLinkPodcastNotFound": "ポッドキャストが見つかりません",
"deepLinkEpisodeNotFound": "エピソードが見つかりません",
"deepLinkNetworkError": "読み込めませんでした。接続を確認してください",
"deepLinkLoading": "リンクを開いています...",
"sharePodcast": "ポッドキャストを共有",
"shareEpisode": "エピソードを共有"
```

- [ ] **Step 3: Regenerate localizations**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Generates updated `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ja.dart`

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add universal link localization keys (en, ja)"
```

---

## Task 7: Create `DeepLinkScreen` and GoRouter routes

**Files:**
- Create: `packages/audiflow_app/lib/features/share/presentation/screens/deep_link_screen.dart`
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

- [ ] **Step 1: Create `DeepLinkScreen`**

A `ConsumerStatefulWidget` that resolves a universal link URI and navigates to the target screen.

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';

class DeepLinkScreen extends ConsumerStatefulWidget {
  const DeepLinkScreen({super.key, required this.uri});

  final Uri uri;

  @override
  ConsumerState<DeepLinkScreen> createState() => _DeepLinkScreenState();
}

class _DeepLinkScreenState extends ConsumerState<DeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to ensure Localizations widget is accessible
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final l10n = AppLocalizations.of(context);
    try {
      final target = await ref.read(deepLinkResolverProvider).resolve(widget.uri);
      if (!mounted) return;

      if (target == null) {
        _showErrorAndGoHome(l10n.deepLinkPodcastNotFound);
        return;
      }

      switch (target) {
        case PodcastDeepLinkTarget(:final itunesId, :final feedUrl, :final title, :final artworkUrl):
          // Construct a Podcast model (audiflow_search) for PodcastDetailScreen
          final podcast = Podcast(
            id: itunesId,
            name: title,
            artistName: '',
            feedUrl: feedUrl,
            artworkUrl: artworkUrl,
          );
          context.go(
            '${AppRoutes.search}/podcast/$itunesId',
            extra: podcast,
          );

        case EpisodeDeepLinkTarget(:final episode, :final podcastTitle, :final artworkUrl, :final progress):
          // Navigate to podcast detail first, then push episode detail
          // The episode detail screen expects extra as Map
          context.go(
            '${AppRoutes.search}/podcast/${target.itunesId}',
            extra: Podcast(
              id: target.itunesId,
              name: podcastTitle,
              artistName: '',
              artworkUrl: artworkUrl,
            ),
          );
          // Push episode detail on top
          context.push(
            '${AppRoutes.search}/podcast/${target.itunesId}/${AppRoutes.episodeDetail}'
                .replaceAll(':episodeGuid', Uri.encodeComponent(episode.guid ?? '')),
            extra: <String, dynamic>{
              'episode': episode,
              'podcastTitle': podcastTitle,
              'artworkUrl': artworkUrl,
              'progress': progress,
            },
          );
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorAndGoHome(l10n.deepLinkNetworkError);
    }
  }

  void _showErrorAndGoHome(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    context.go(AppRoutes.search);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.deepLinkLoading),
          ],
        ),
      ),
    );
  }
}
```

This constructs a `Podcast` (from `audiflow_search`) since `PodcastDetailScreen` expects that type. For episodes, it navigates to the podcast screen first then pushes the episode detail on top, matching the existing navigation pattern.

- [ ] **Step 2: Add route constants to `AppRoutes`**

```dart
static const String deepLinkPodcast = '/p/:itunesId';
static const String deepLinkEpisode = '/p/:itunesId/e/:encodedGuid';
```

- [ ] **Step 3: Add top-level routes to `createAppRouter`**

Add after the existing `GoRoute` for `AppRoutes.transcript` (line 282-286 of `app_router.dart`):

```dart
GoRoute(
  parentNavigatorKey: rootNavigatorKey,
  path: '/p/:itunesId',
  builder: (context, state) {
    return DeepLinkScreen(uri: state.uri);
  },
  routes: [
    GoRoute(
      path: 'e/:encodedGuid',
      builder: (context, state) {
        return DeepLinkScreen(uri: state.uri);
      },
    ),
  ],
),
```

- [ ] **Step 4: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/share/ packages/audiflow_app/lib/routing/app_router.dart
git commit -m "feat(app): add DeepLinkScreen and GoRouter routes for universal links"
```

---

## Task 8: Create share helper and wire share buttons

**Files:**
- Create: `packages/audiflow_app/lib/features/share/presentation/helpers/share_helper.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart`
- Create: `packages/audiflow_app/test/features/share/presentation/helpers/share_helper_test.dart`

- [ ] **Step 1: Write failing test for share helper**

Since `SharePlus.instance.share()` is a platform call, test the URL construction logic separately. The share helper is thin glue — focus on testing `buildShareUrl` (a pure function that returns the URL string or null):

```dart
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import 'package:audiflow_app/features/share/presentation/helpers/share_helper.dart';

void main() {
  late FakeShareLinkBuilder fakeBuilder;

  setUp(() {
    fakeBuilder = FakeShareLinkBuilder();
  });

  group('buildEpisodeShareUrl', () {
    test('returns universal link when subscriptionId and guid available', () async {
      fakeBuilder.episodeLinkResult = 'https://audiflow.reedom.com/p/123/e/abc';

      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: fakeBuilder,
        subscriptionId: 1,
        episodeGuid: 'test-guid',
        fallbackLink: 'https://example.com/ep1',
      );

      check(result).equals('https://audiflow.reedom.com/p/123/e/abc');
    });

    test('falls back to fallbackLink when guid is null', () async {
      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: fakeBuilder,
        subscriptionId: 1,
        episodeGuid: null,
        fallbackLink: 'https://example.com/ep1',
      );

      check(result).equals('https://example.com/ep1');
    });

    test('falls back to fallbackLink when builder returns null', () async {
      fakeBuilder.episodeLinkResult = null;

      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: fakeBuilder,
        subscriptionId: 1,
        episodeGuid: 'test-guid',
        fallbackLink: 'https://example.com/ep1',
      );

      check(result).equals('https://example.com/ep1');
    });

    test('returns null when all sources are null', () async {
      final result = await buildEpisodeShareUrl(
        shareLinkBuilder: fakeBuilder,
        subscriptionId: null,
        episodeGuid: null,
        fallbackLink: null,
      );

      check(result).isNull();
    });
  });
}
```

- [ ] **Step 2: Create share helper**

`share_helper.dart` — split into a pure URL builder (testable) and a thin share wrapper:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Pure function: builds episode share URL with fallback chain.
/// Universal link > fallbackLink > null.
Future<String?> buildEpisodeShareUrl({
  required ShareLinkBuilder shareLinkBuilder,
  required int? subscriptionId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  if (subscriptionId != null && episodeGuid != null) {
    final url = await shareLinkBuilder.buildEpisodeLink(
      subscriptionId: subscriptionId,
      episodeGuid: episodeGuid,
    );
    if (url != null) return url;
  }
  return fallbackLink;
}

/// Shares an episode via universal link with fallback to fallbackLink.
Future<void> shareEpisode({
  required WidgetRef ref,
  required int? subscriptionId,
  required String? episodeGuid,
  required String? fallbackLink,
}) async {
  final url = await buildEpisodeShareUrl(
    shareLinkBuilder: ref.read(shareLinkBuilderProvider),
    subscriptionId: subscriptionId,
    episodeGuid: episodeGuid,
    fallbackLink: fallbackLink,
  );
  if (url == null) return;

  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}

/// Shares a podcast via universal link.
Future<void> sharePodcast({
  required WidgetRef ref,
  required int? subscriptionId,
}) async {
  if (subscriptionId == null) return;

  final url = await ref
      .read(shareLinkBuilderProvider)
      .buildPodcastLink(subscriptionId: subscriptionId);
  if (url == null) return;

  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}
```

- [ ] **Step 3: Wire `EpisodeListTile._buildShareButton`**

`EpisodeListTile` is a `ConsumerWidget` so `ref` is available in `build()`. Changes needed:

1. Add `final int? subscriptionId;` constructor param
2. Change `_buildShareButton(context)` to `_buildShareButton(context, ref)`
3. Update the method body:

```dart
Widget _buildShareButton(BuildContext context, WidgetRef ref) {
  return IconButton(
    icon: const Icon(Icons.share, size: 20),
    iconSize: 20,
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 6),
    tooltip: AppLocalizations.of(context).shareEpisode,
    onPressed: () => shareEpisode(
      ref: ref,
      subscriptionId: subscriptionId,
      episodeGuid: episode.guid,
      fallbackLink: episode.link,
    ),
  );
}
```

**Call sites to update (pass `subscriptionId`):**
- `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart` — where `EpisodeListTile` is created in the episode list builder. The subscription is available via `subscriptionByFeedUrlProvider` (already watched in this screen). Pass `subscription?.id`.
- Search for any other `EpisodeListTile(` constructors and add `subscriptionId:` to each.

- [ ] **Step 4: Wire `SmartPlaylistEpisodeListTile._buildShareButton`**

`SmartPlaylistEpisodeListTile` works with `Episode` (Isar model), not `PodcastItem`. Key differences:
- `Episode.guid` is `late String` (non-nullable) — always available
- `Episode` has no `link` field — use `null` as fallback (no web link available)

1. Add `final int? subscriptionId;` constructor param
2. Change `_buildShareButton(context)` to `_buildShareButton(context, ref)`
3. Update the method body:

```dart
Widget _buildShareButton(BuildContext context, WidgetRef ref) {
  return IconButton(
    icon: const Icon(Icons.share, size: 20),
    iconSize: 20,
    constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
    padding: EdgeInsets.zero,
    tooltip: AppLocalizations.of(context).shareEpisode,
    onPressed: () => shareEpisode(
      ref: ref,
      subscriptionId: subscriptionId,
      episodeGuid: episode.guid,
      fallbackLink: null, // Episode model has no web link
    ),
  );
}
```

**Call sites to update:** Search for `SmartPlaylistEpisodeListTile(` and add `subscriptionId:`. These are in the smart playlist screens. The subscription is available from the parent podcast context.

- [ ] **Step 5: Update `EpisodeDetailScreen` share button**

`EpisodeDetailScreen` needs `subscriptionId`. Add it as an optional constructor param:

```dart
class EpisodeDetailScreen extends ConsumerWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
    this.subscriptionId,  // NEW
  });

  // ... existing fields
  final int? subscriptionId;  // NEW
```

Replace the existing app bar share button (line 71-77):

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.share),
    tooltip: AppLocalizations.of(context).shareEpisode,
    onPressed: () => shareEpisode(
      ref: ref,
      subscriptionId: subscriptionId,
      episodeGuid: episode.guid,
      fallbackLink: episode.link,
    ),
  ),
],
```

**Route builder update** — in `_buildEpisodeDetailScreen` (app_router.dart line 348):

```dart
final subscriptionId = extra['subscriptionId'] as int?;
return EpisodeDetailScreen(
  episode: episode,
  podcastTitle: podcastTitle,
  artworkUrl: artworkUrl,
  progress: progress,
  subscriptionId: subscriptionId,
);
```

**Navigation call sites to update (pass `subscriptionId` in `extra`):**
- `EpisodeListTile._navigateToDetail` (episode_list_tile.dart line 165) — add `'subscriptionId': subscriptionId` to the extra map
- `SmartPlaylistEpisodeListTile._navigateToDetail` (smart_playlist_episode_list_tile.dart line 151) — add `'subscriptionId': subscriptionId` to the extra map (via MaterialPageRoute)
- Any other places that push to episode detail route (search for `episodeDetail` or `EpisodeDetailScreen(`)

- [ ] **Step 6: Run tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/share/ packages/audiflow_app/lib/features/podcast_detail/ packages/audiflow_app/test/features/share/
git commit -m "feat(app): wire share buttons with universal links and fallback"
```

---

## Task 9: Add podcast share button to podcast detail screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`

- [ ] **Step 1: Add share button to app bar**

The `PodcastDetailScreen` already has a `Scaffold` with an app bar. Add a share `IconButton` to the app bar actions. The subscription is available via `subscriptionByFeedUrlProvider`.

```dart
IconButton(
  icon: const Icon(Icons.share),
  tooltip: l10n.sharePodcast,
  onPressed: () => sharePodcast(
    ref: ref,
    subscriptionId: subscription?.id,
  ),
),
```

- [ ] **Step 2: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/
git commit -m "feat(app): add share button to podcast detail screen"
```

---

## Task 10: Platform configuration (iOS + Android)

**Files:**
- Modify: `packages/audiflow_app/ios/Runner/Runner.entitlements`
- Modify: `packages/audiflow_app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add Associated Domains to iOS entitlements**

Add to `Runner.entitlements` inside the `<dict>`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:audiflow.reedom.com</string>
</array>
```

- [ ] **Step 2: Add intent-filter to Android manifest**

Add after the existing OPML intent-filters (after line 40), inside the `<activity>`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https" android:host="audiflow.reedom.com" android:pathPrefix="/p/"/>
</intent-filter>
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/ios/Runner/Runner.entitlements packages/audiflow_app/android/app/src/main/AndroidManifest.xml
git commit -m "feat(platform): add universal links config for iOS and Android"
```

---

## Task 11: Static site (`audiflow-universal-links` repo)

This task is in the separate `audiflow/audiflow-universal-links` repository.

**Files:**
- Create: `.nojekyll`
- Create: `.well-known/apple-app-site-association`
- Create: `.well-known/assetlinks.json`
- Create: `index.html`
- Create: `404.html`
- Create: `CNAME`

- [ ] **Step 1: Create `.nojekyll`**

Empty file.

- [ ] **Step 2: Create `apple-app-site-association`**

```json
{
  "applinks": {
    "details": [
      {
        "appID": "{TEAM_ID}.com.reedom.audiflow",
        "paths": ["/p/*"]
      }
    ]
  }
}
```

Replace `{TEAM_ID}` with actual Apple Team ID.

- [ ] **Step 3: Create `assetlinks.json`**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.reedom.audiflow_app",
      "sha256_cert_fingerprints": ["{SIGNING_CERT_SHA256}"]
    }
  }
]
```

Replace `{SIGNING_CERT_SHA256}` with actual signing cert fingerprint.

- [ ] **Step 4: Create `CNAME`**

```
audiflow.reedom.com
```

- [ ] **Step 5: Create `404.html`**

Primary handler for all `/p/...` paths. Detects platform and redirects:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Audiflow</title>
  <script>
    (function() {
      var ua = navigator.userAgent || '';
      var isIOS = /iPad|iPhone|iPod/.test(ua);
      var isAndroid = /Android/.test(ua);

      if (isAndroid) {
        window.location.replace(
          'https://play.google.com/store/apps/details?id=com.reedom.audiflow_app'
        );
      } else {
        // iOS and all others → App Store
        window.location.replace(
          'https://apps.apple.com/app/audiflow/id{APP_STORE_ID}'
        );
      }
    })();
  </script>
</head>
<body>
  <p>Redirecting to app store...</p>
</body>
</html>
```

Replace `{APP_STORE_ID}` with actual App Store ID.

- [ ] **Step 6: Create `index.html`**

Same content as `404.html` (root page also redirects to store).

- [ ] **Step 7: Push and configure GitHub Pages**

Push all files, then enable GitHub Pages in repo settings:
- Source: Deploy from branch (`main`)
- Custom domain: `audiflow.reedom.com`
- Enforce HTTPS: enabled

- [ ] **Step 8: Configure DNS**

Add CNAME record: `audiflow.reedom.com` -> `audiflow.github.io`

- [ ] **Step 9: Verify association files**

```bash
curl -I https://audiflow.reedom.com/.well-known/apple-app-site-association
curl https://audiflow.reedom.com/.well-known/assetlinks.json
```

Expected: 200 OK with `Content-Type: application/json`

- [ ] **Step 10: Commit**

```bash
git add -A && git commit -m "feat: initial static site with association files and store redirect"
git push origin main
```

---

## Task 12: Final verification

- [ ] **Step 1: Run full test suite**

```bash
cd packages/audiflow_domain && flutter test
cd packages/audiflow_app && flutter test
```

Expected: All tests pass

- [ ] **Step 2: Run analyze**

```bash
flutter analyze
```

Expected: Zero issues

- [ ] **Step 3: Verify build**

```bash
cd packages/audiflow_app && flutter build apk --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev
```

Expected: Build succeeds

- [ ] **Step 4: Manual testing checklist**

On a real device with the domain live:
- [ ] Tap a universal link with the app installed → opens correct screen
- [ ] Tap a universal link without the app → redirects to correct store
- [ ] Share button on episode list tile → shares universal link
- [ ] Share button on episode detail → shares universal link
- [ ] Share button on podcast detail → shares universal link
- [ ] Share button when GUID is null → falls back to episode.link
- [ ] Deep link to unsubscribed podcast → fetches via iTunes API and opens

- [ ] **Step 5: Commit any fixes**

```bash
git commit -m "fix(share): address issues found during manual testing"
```
