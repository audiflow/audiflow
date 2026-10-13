import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
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

void main() {
  late Isar isar;
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
    episodeRepo = FakeEpisodeRepository([_episode(1, 1), _episode(2, 1)]);
    configRepo = FakeConfigRepository(summary: _summary(1), config: _config);
    observer = _FailureObserver();
    container = ProviderContainer(
      observers: [observer],
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(testSubscription()),
        ),
        episodeRepositoryProvider.overrideWithValue(episodeRepo),
        smartPlaylistLocalDatasourceProvider.overrideWithValue(
          SmartPlaylistLocalDatasource(isar),
        ),
        presetConfigRepositoryProvider.overrideWithValue(configRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  /// Starts a re-read that stops inside the preset config load,
  /// disposes the provider there (the user left the screen), then
  /// lets the build resume. Returns the failures the build reported.
  Future<List<Object>> disposeDuringConfigLoad() async {
    final provider = podcastSmartPlaylistsProvider(1);
    final gate = Completer<void>();
    configRepo.getConfigGate = gate;
    final callsBefore = configRepo.getConfigCalls;

    container.invalidate(provider);
    final sub = container.listen(provider, (_, _) {});
    while (configRepo.getConfigCalls == callsBefore) {
      await Future<void>.delayed(Duration.zero);
    }
    sub.close();
    while (container.exists(provider)) {
      await Future<void>.delayed(Duration.zero);
    }
    gate.complete();
    // Let the abandoned build run to completion.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return observer.failures;
  }

  group('podcastSmartPlaylists disposed mid-build', () {
    test('re-resolve after episodes changed does not use the disposed '
        'ref', () async {
      await readSmartPlaylists(container, 1);
      episodeRepo.episodes.add(_episode(3, 2));

      final failures = await disposeDuringConfigLoad();

      check(failures).isEmpty();
    });

    test('config version migration does not use the disposed ref', () async {
      await readSmartPlaylists(container, 1);
      configRepo.summary = _summary(2);

      final failures = await disposeDuringConfigLoad();

      check(failures).isEmpty();
    });
  });
}
