import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:riverpod/misc.dart' show ProviderBase;
import 'package:riverpod/riverpod.dart';

import '../../../helpers/isar_test_helper.dart';
import 'smart_playlist_provider_test_support.dart';

PresetSummary _summary(int dataVersion) => PresetSummary(
  id: 'test-pattern',
  dataVersion: dataVersion,
  displayName: 'Test Pattern',
  feedUrlHint: 'example.com',
  playlistCount: 1,
);

final _config = PresetConfig(
  id: 'test-pattern',
  feedUrls: ['https://example.com/feed.xml'],
  playlists: [
    const SmartPlaylistDefinition(
      id: 'regular',
      displayName: 'Regular Series',
      grouping: GroupingConfig(by: 'seasonNumber'),
      priority: 0,
    ),
  ],
);

Episode _episode(int id, int season) => testEpisode(
  id: id,
  title: 'Season $season episode $id',
  seasonNumber: season,
  episodeNumber: id,
  publishedAt: DateTime(2026, 1, id),
);

/// Records provider failures, which the app forwards to Sentry.
final class _FailureObserver extends ProviderObserver {
  final failures = <Object>[];

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    failures.add(error);
  }
}

/// Polls [condition] until it holds, failing with [what] instead of
/// hanging until the global test timeout.
Future<void> _waitUntil(bool Function() condition, String what) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (deadline.isBefore(DateTime.now())) {
      fail('Timed out waiting until $what');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late Isar isar;
  late SmartPlaylistLocalDatasource datasource;
  late FakeSubscriptionRepository subscriptionRepo;
  late FakeEpisodeRepository episodeRepo;
  late FakeConfigRepository configRepo;
  late _FailureObserver observer;
  late ProviderContainer container;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SmartPlaylistEntitySchema,
      SmartPlaylistGroupEntitySchema,
    ]);
    datasource = SmartPlaylistLocalDatasource(isar);
    subscriptionRepo = FakeSubscriptionRepository(testSubscription());
    episodeRepo = FakeEpisodeRepository([_episode(1, 1), _episode(2, 1)]);
    configRepo = FakeConfigRepository(summary: _summary(1), config: _config);
    observer = _FailureObserver();
    container = ProviderContainer(
      observers: [observer],
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(subscriptionRepo),
        episodeRepositoryProvider.overrideWithValue(episodeRepo),
        smartPlaylistLocalDatasourceProvider.overrideWithValue(datasource),
        presetConfigRepositoryProvider.overrideWithValue(configRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  /// Listens to [provider] until [paused] reports the build is held
  /// at [gate], disposes the provider there (the user left the
  /// screen), then lets the abandoned build resume.
  Future<void> disposeWhilePaused(
    ProviderBase<Object?> provider,
    Completer<void> gate,
    bool Function() paused,
  ) async {
    container.invalidate(provider);
    final sub = container.listen(provider, (_, _) {});
    await _waitUntil(paused, 'the build reaches the gate');
    sub.close();
    await _waitUntil(
      () => !container.exists(provider),
      'the provider disposes',
    );
    gate.complete();
    // Nothing awaits the abandoned build; give it time to finish.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  Future<void> disposeDuringConfigLoad() {
    final gate = Completer<void>();
    configRepo.getConfigGate = gate;
    final callsBefore = configRepo.getConfigCalls;
    final provider = podcastSmartPlaylistsProvider(1);
    return disposeWhilePaused(
      provider,
      gate,
      () => callsBefore < configRepo.getConfigCalls,
    );
  }

  Future<void> disposeDuringFeedUrlLookup(ProviderBase<Object?> provider) {
    final gate = Completer<void>();
    subscriptionRepo.getByFeedUrlGate = gate;
    final callsBefore = subscriptionRepo.getByFeedUrlCalls;
    return disposeWhilePaused(
      provider,
      gate,
      () => callsBefore < subscriptionRepo.getByFeedUrlCalls,
    );
  }

  group('podcastSmartPlaylists disposed mid-build', () {
    test('re-resolve after episodes changed neither fails nor touches '
        'the cache', () async {
      await readSmartPlaylists(container, 1);
      final cached = await datasource.getByPodcastId(1);
      episodeRepo.episodes.add(_episode(3, 2));

      await disposeDuringConfigLoad();

      check(observer.failures).isEmpty();
      final after = await datasource.getByPodcastId(1);
      check(
        after.map((e) => e.episodeFingerprint),
      ).deepEquals(cached.map((e) => e.episodeFingerprint));
    });

    test('config version migration neither fails nor touches the '
        'cache', () async {
      await readSmartPlaylists(container, 1);
      configRepo.summary = _summary(2);

      await disposeDuringConfigLoad();

      check(observer.failures).isEmpty();
      check(episodeRepo.upserted).isEmpty();
      final after = await datasource.getByPodcastId(1);
      check(after.map((e) => e.configVersion)).deepEquals([1]);
    });
  });

  group('by-feed-URL providers disposed during the subscription lookup', () {
    const feedUrl = 'https://example.com/feed.xml';

    test('podcastSmartPlaylistsByFeedUrl does not fail', () async {
      await disposeDuringFeedUrlLookup(
        podcastSmartPlaylistsByFeedUrlProvider(feedUrl),
      );

      check(observer.failures).isEmpty();
    });

    test('hasSmartPlaylistViewByFeedUrl does not fail', () async {
      await disposeDuringFeedUrlLookup(
        hasSmartPlaylistViewByFeedUrlProvider(feedUrl),
      );

      check(observer.failures).isEmpty();
    });
  });
}
