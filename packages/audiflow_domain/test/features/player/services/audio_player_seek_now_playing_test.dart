import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

/// Records saveProgress calls; everything else is unused here.
class _RecordingHistoryRepository implements PlaybackHistoryRepository {
  final List<int> savedPositionsMs = [];

  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  }) async => savedPositionsMs.add(positionMs);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FixedNowPlaying extends NowPlayingController {
  _FixedNowPlaying(this._initial);
  final NowPlayingInfo? _initial;

  @override
  NowPlayingInfo? build() => _initial;
}

NowPlayingInfo _restored({Duration? totalDuration}) => NowPlayingInfo(
  episodeUrl: 'https://example.com/a.mp3',
  episodeTitle: 'Episode',
  podcastTitle: 'Podcast',
  savedPosition: const Duration(minutes: 1),
  totalDuration: totalDuration,
  episode: Episode()..id = 1,
);

void main() {
  late _RecordingHistoryRepository history;

  ProviderContainer makeContainer(NowPlayingInfo? nowPlaying) {
    history = _RecordingHistoryRepository();
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        playbackHistoryRepositoryProvider.overrideWithValue(history),
        nowPlayingControllerProvider.overrideWith(
          () => _FixedNowPlaying(nowPlaying),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<Duration?> seekWithoutAudio(
    ProviderContainer container,
    Duration position,
  ) async {
    await container
        .read(audioPlayerControllerProvider.notifier)
        .seekNowPlaying(position);
    return container.read(nowPlayingControllerProvider)?.savedPosition;
  }

  group('seekNowPlaying without loaded audio', () {
    test('moves and persists the saved position', () async {
      final container = makeContainer(_restored());
      final saved = await seekWithoutAudio(
        container,
        const Duration(minutes: 5),
      );

      check(saved).equals(const Duration(minutes: 5));
      check(history.savedPositionsMs).deepEquals([300000]);
    });

    test('clamps to a known episode duration', () async {
      final container = makeContainer(
        _restored(totalDuration: const Duration(minutes: 3)),
      );
      final saved = await seekWithoutAudio(
        container,
        const Duration(minutes: 5),
      );

      check(saved).equals(const Duration(minutes: 3));
      check(history.savedPositionsMs).deepEquals([180000]);
    });

    test('announces the clamped target as a seek', () async {
      final container = makeContainer(
        _restored(totalDuration: const Duration(minutes: 3)),
      );
      final events = <PlayerLifecycleEvent>[];
      final sub = container
          .read(audioPlayerControllerProvider.notifier)
          .lifecycleEvents
          .listen(events.add);
      addTearDown(sub.cancel);

      await seekWithoutAudio(container, const Duration(minutes: 5));
      await pumpEventQueue();

      check(events).single
          .isA<SeekStartedLifecycle>()
          .has((e) => e.target, 'target')
          .equals(const Duration(minutes: 3));
    });

    test('does nothing when nothing is playing', () async {
      final container = makeContainer(null);
      final saved = await seekWithoutAudio(
        container,
        const Duration(minutes: 5),
      );

      check(saved).isNull();
      check(history.savedPositionsMs).isEmpty();
    });
  });
}
