import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _IdlePlayer extends AudioPlayerController {
  @override
  PlaybackState build() => const PlaybackState.idle();
}

const _episodeUrl = 'https://example.com/current.mp3';

Episode _episode(String url, {int? durationMinutes}) => Episode()
  ..audioUrl = url
  ..durationMs = durationMinutes == null ? null : durationMinutes * 60000;

QueueItemWithEpisode _queued(Episode episode) => QueueItemWithEpisode(
  queueItem: QueueItem()
    ..episodeId = 0
    ..position = 0
    ..addedAt = DateTime(2026),
  episode: episode,
);

void main() {
  late ProviderContainer container;

  Future<void> setUpContainer({
    double speed = 1.0,
    PlaybackQueue queue = const PlaybackQueue(),
    List<EpisodeChapter> chapters = const [],
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        playerLifecycleEventsProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
        audioPlayerControllerProvider.overrideWith(_IdlePlayer.new),
        playbackProgressProvider.overrideWith(
          (ref) => const PlaybackProgress(
            position: Duration(minutes: 10),
            duration: Duration(minutes: 40),
            bufferedPosition: Duration.zero,
          ),
        ),
        currentEpisodeChaptersProvider.overrideWith(
          (ref) => Stream.value(chapters),
        ),
        nowPlayingSpeedProvider.overrideWith((ref) => speed),
        playbackQueueProvider.overrideWith((ref) => Stream.value(queue)),
      ],
    );
    container
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(
          const NowPlayingInfo(
            episodeUrl: _episodeUrl,
            episodeTitle: 'Current',
            podcastTitle: 'Podcast',
          ),
        );
    addTearDown(container.dispose);
  }

  SleepTimerController timer() =>
      container.read(sleepTimerControllerProvider.notifier);

  test('is null while no timer is armed', () async {
    await setUpContainer();
    check(container.read(sleepTimerTimeLeftProvider)).isNull();
  });

  test('applies the speed in effect to an end-of-episode timer', () async {
    await setUpContainer(speed: 1.5);
    timer().setEndOfEpisode();
    check(
      container.read(sleepTimerTimeLeftProvider),
    ).equals(const SleepTimerTimeLeft(Duration(minutes: 20)));
  });

  test('counts an end-of-chapter timer in the last chapter to the episode '
      'end', () async {
    // Position 10 of 40 minutes, in the last of two chapters.
    await setUpContainer(
      speed: 2.0,
      chapters: [
        EpisodeChapter()
          ..episodeId = 1
          ..sortOrder = 0
          ..title = 'Intro'
          ..startMs = 0,
        EpisodeChapter()
          ..episodeId = 1
          ..sortOrder = 1
          ..title = 'Main'
          ..startMs = 5 * 60000,
      ],
    );
    final sub = container.listen(sleepTimerTimeLeftProvider, (_, _) {});
    addTearDown(sub.close);
    await pumpEventQueue();
    timer().setEndOfChapter();
    await pumpEventQueue();
    check(
      container.read(sleepTimerTimeLeftProvider),
    ).equals(const SleepTimerTimeLeft(Duration(minutes: 15)));
  });

  test('sums the queue after the now-playing episode', () async {
    await setUpContainer(
      queue: PlaybackQueue(
        manualItems: [
          // The now-playing episode is skipped wherever it is queued.
          _queued(_episode(_episodeUrl, durationMinutes: 40)),
          _queued(_episode('https://example.com/a.mp3', durationMinutes: 20)),
        ],
      ),
    );
    final sub = container.listen(sleepTimerTimeLeftProvider, (_, _) {});
    addTearDown(sub.close);
    await timer().setEpisodes(2);
    await pumpEventQueue();
    check(
      container.read(sleepTimerTimeLeftProvider),
    ).equals(const SleepTimerTimeLeft(Duration(minutes: 50)));
  });

  test('a duration timer refreshes as the seconds pass', () async {
    await setUpContainer();
    final values = <SleepTimerTimeLeft?>[];
    final sub = container.listen(
      sleepTimerTimeLeftProvider,
      (_, next) => values.add(next),
    );
    addTearDown(sub.close);
    await timer().setDuration(const Duration(minutes: 1));
    // The first refresh lands within a second of arming; leave slack for a
    // loaded machine.
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    check(values.length).isGreaterOrEqual(2);
    check(values.last!.time).isLessThan(values.first!.time);
  });
}
