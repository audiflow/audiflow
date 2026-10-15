import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show ProviderBase;

const _feedUrl = 'https://example.com/feed.xml';

const _grouping = SmartPlaylistGrouping(
  playlists: [],
  ungroupedEpisodeIds: [],
  resolverType: 'config',
);

class _FakeEpisodeRepository implements EpisodeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  late Completer<SmartPlaylistGrouping?> groupingGate;
  late Completer<PresetConfig?> presetGate;
  late _FailureObserver observer;
  late ProviderContainer container;

  setUp(() {
    groupingGate = Completer<SmartPlaylistGrouping?>();
    presetGate = Completer<PresetConfig?>();
    observer = _FailureObserver();
    container = ProviderContainer(
      observers: [observer],
      overrides: [
        podcastSmartPlaylistsByFeedUrlProvider(
          _feedUrl,
        ).overrideWith((ref) => groupingGate.future),
        subscriptionByFeedUrlProvider(
          _feedUrl,
        ).overrideWith((ref) async => null),
        presetByFeedUrlProvider(
          _feedUrl,
        ).overrideWith((ref) => presetGate.future),
        podcastDetailProvider(
          _feedUrl,
        ).overrideWith((ref) async => throw StateError('unused')),
        episodeRepositoryProvider.overrideWithValue(_FakeEpisodeRepository()),
      ],
    );
    // Upstream providers outlive the screen, as they do in the app while
    // feed sync keeps them busy.
    container.listen(
      podcastSmartPlaylistsByFeedUrlProvider(_feedUrl),
      (_, _) {},
    );
    container.listen(presetByFeedUrlProvider(_feedUrl), (_, _) {});
  });

  tearDown(() => container.dispose());

  /// Listens to [provider], disposes it while its build awaits a gate
  /// (the user left the screen), then lets the abandoned build resume.
  Future<void> disposeWhilePending(
    ProviderBase<Object?> provider,
    void Function() openGates,
  ) async {
    final sub = container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    sub.close();
    await _waitUntil(
      () => !container.exists(provider),
      'the provider disposes',
    );
    openGates();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test(
    'sortedPodcastSmartPlaylists disposed mid-build does not fail',
    () async {
      await disposeWhilePending(
        sortedPodcastSmartPlaylistsProvider(_feedUrl),
        () {
          groupingGate.complete(_grouping);
          presetGate.complete(null);
        },
      );

      check(observer.failures).isEmpty();
    },
  );

  test(
    'hasSmartPlaylistViewAfterLoad disposed mid-build does not fail',
    () async {
      await disposeWhilePending(
        hasSmartPlaylistViewAfterLoadProvider(_feedUrl),
        () => presetGate.complete(null),
      );

      check(observer.failures).isEmpty();
    },
  );
}
