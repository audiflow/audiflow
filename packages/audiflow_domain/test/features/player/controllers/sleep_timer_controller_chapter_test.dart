import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records fades and stops instead of driving a real audio player.
class _FakePlayer extends AudioPlayerController {
  int fadeCount = 0;
  int pauseCount = 0;
  int suppressCount = 0;
  final pausedAt = <Duration>[];

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> pauseAt(Duration position) async => pausedAt.add(position);

  @override
  void suppressNextAutoAdvance() => suppressCount++;

  @override
  PlaybackState build() => const PlaybackState.idle();

  @override
  Future<void> fadeOutAndPause({
    Duration total = const Duration(seconds: 8),
  }) async {
    fadeCount++;
  }
}

/// Chapter store whose per-episode watch emits what the test pushes.
class _LiveChapterRepository implements ChapterRepository {
  final _controllers = <int, StreamController<List<EpisodeChapter>>>{};

  StreamController<List<EpisodeChapter>> _for(int episodeId) => _controllers
      .putIfAbsent(episodeId, StreamController<List<EpisodeChapter>>.broadcast);

  void emit(int episodeId, List<EpisodeChapter> chapters) =>
      _for(episodeId).add(chapters);

  Future<void> close() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }

  @override
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) =>
      _for(episodeId).stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

EpisodeChapter _chapter(int episodeId, int index, int startSeconds) =>
    EpisodeChapter()
      ..id = episodeId * 100 + index
      ..episodeId = episodeId
      ..sortOrder = index
      ..title = 'Chapter $index'
      ..startMs = startSeconds * 1000;

/// Chapters starting at 0s, 60s and 120s.
List<EpisodeChapter> _threeChapters(int episodeId) => [
  _chapter(episodeId, 0, 0),
  _chapter(episodeId, 1, 60),
  _chapter(episodeId, 2, 120),
];

NowPlayingInfo _nowPlaying(int episodeId) => NowPlayingInfo(
  episodeUrl: 'https://example.com/$episodeId.mp3',
  episodeTitle: 'Episode $episodeId',
  podcastTitle: 'Podcast',
  episode: Episode()..id = episodeId,
);

void main() {
  late StreamController<PlayerLifecycleEvent> lifecycle;
  late StreamController<PlaybackProgress> positions;
  late _LiveChapterRepository chapters;
  late _FakePlayer player;
  late ProviderContainer container;
  late List<SleepTimerEvent> timerEvents;

  setUp(() async {
    lifecycle = StreamController<PlayerLifecycleEvent>.broadcast();
    positions = StreamController<PlaybackProgress>.broadcast();
    chapters = _LiveChapterRepository();
    player = _FakePlayer();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        playerLifecycleEventsProvider.overrideWith((ref) => lifecycle.stream),
        audioPlayerControllerProvider.overrideWith(() => player),
        playbackProgressStreamProvider.overrideWith((ref) => positions.stream),
        chapterRepositoryProvider.overrideWithValue(chapters),
      ],
    );
    // Listened like main.dart does: an unlistened provider pauses its
    // chapter subscriptions.
    container.listen(sleepTimerControllerProvider, (_, _) {});
    timerEvents = [];
    final sub = container
        .read(sleepTimerControllerProvider.notifier)
        .events
        .listen(timerEvents.add);
    addTearDown(() async {
      await sub.cancel();
      container.dispose();
      await lifecycle.close();
      await positions.close();
      await chapters.close();
    });
  });

  Future<void> playEpisode(int episodeId, List<EpisodeChapter> list) async {
    container
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(_nowPlaying(episodeId));
    await pumpEventQueue();
    chapters.emit(episodeId, list);
    await pumpEventQueue();
  }

  Future<void> playAt(Duration position) async {
    positions.add(
      PlaybackProgress(
        position: position,
        duration: const Duration(minutes: 5),
        bufferedPosition: Duration.zero,
      ),
    );
    await pumpEventQueue();
  }

  Future<void> lifecycleEvent(PlayerLifecycleEvent event) async {
    lifecycle.add(event);
    await pumpEventQueue();
  }

  void armEndOfChapter() =>
      container.read(sleepTimerControllerProvider.notifier).setEndOfChapter();

  SleepTimerConfig config() =>
      container.read(sleepTimerControllerProvider).config;

  void checkNotFired() {
    check(player.fadeCount).equals(0);
    check(player.pauseCount).equals(0);
    check(player.pausedAt).isEmpty();
    check(timerEvents).isEmpty();
    check(config()).isA<SleepTimerConfigEndOfChapter>();
  }

  // Crossing into the next chapter pauses at once: a fade would play the
  // next chapter's opening while the volume drops. The position returns to
  // [boundary], the start of the chapter just entered, so resuming plays
  // that chapter from its beginning.
  void checkFiredOnce(Duration boundary) {
    check(player.pausedAt).deepEquals([boundary]);
    check(player.pauseCount).equals(0);
    check(player.fadeCount).equals(0);
    check(player.suppressCount).equals(0);
    check(timerEvents).single.isA<SleepTimerFired>();
    check(config()).isA<SleepTimerConfigOff>();
  }

  void checkCancelled() {
    check(player.fadeCount).equals(0);
    check(player.pauseCount).equals(0);
    check(player.pausedAt).isEmpty();
    check(player.suppressCount).equals(0);
    check(timerEvents).single.isA<SleepTimerCancelled>();
    check(config()).isA<SleepTimerConfigOff>();
  }

  Future<void> seek(int seekId, Duration target) async {
    await lifecycleEvent(SeekStartedLifecycle(target, seekId: seekId));
    await playAt(target);
    await lifecycleEvent(SeekLifecycle(target, seekId: seekId));
  }

  test(
    'pauses without a fade at the start of the next chapter on a crossing',
    () async {
      await playEpisode(1, _threeChapters(1));
      await playAt(const Duration(seconds: 30));
      armEndOfChapter();

      await playAt(const Duration(milliseconds: 59800));
      checkNotFired();

      await playAt(const Duration(milliseconds: 60100));
      checkFiredOnce(const Duration(seconds: 60));

      // The player then moves back to the boundary on its own account: no
      // cancellation follows the fire.
      await lifecycleEvent(
        const SeekStartedLifecycle(
          Duration(seconds: 60),
          seekId: 1,
          automatic: true,
        ),
      );
      await playAt(const Duration(seconds: 60));
      await lifecycleEvent(
        const SeekLifecycle(Duration(seconds: 60), seekId: 1),
      );
      checkFiredOnce(const Duration(seconds: 60));
    },
  );

  test(
    'an update past several chapter starts stops at the target end',
    () async {
      await playEpisode(1, [
        _chapter(1, 0, 0),
        _chapter(1, 1, 60),
        _chapter(1, 2, 61),
      ]);
      await playAt(const Duration(seconds: 30));
      armEndOfChapter();

      // One position update skips the one-second chapter 1 entirely.
      await playAt(const Duration(milliseconds: 61100));
      checkFiredOnce(const Duration(seconds: 60));
    },
  );

  test('a seek forward out of the chapter cancels the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 30));
    armEndOfChapter();

    // Jump to the start of the next chapter, as the chapter list does. A
    // position from before the jump still arrives while the seek runs.
    await lifecycleEvent(
      const SeekStartedLifecycle(Duration(seconds: 60), seekId: 1),
    );
    await playAt(const Duration(milliseconds: 30200));
    await playAt(const Duration(seconds: 60));
    await lifecycleEvent(const SeekLifecycle(Duration(seconds: 60), seekId: 1));
    checkCancelled();

    // Nothing fires later at the end of the chapter the seek landed in.
    await playAt(const Duration(milliseconds: 120100));
    checkCancelled();
  });

  test('a seek backward out of the chapter cancels the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 90));
    armEndOfChapter();

    await seek(1, const Duration(seconds: 30));
    checkCancelled();
  });

  test('a seek within the chapter keeps the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 70));
    armEndOfChapter();

    await seek(1, const Duration(seconds: 100));
    await seek(2, const Duration(seconds: 65));
    checkNotFired();

    await playAt(const Duration(milliseconds: 120100));
    checkFiredOnce(const Duration(seconds: 120));
  });

  test(
    'a seek that fails still cancels: the listener asked to leave',
    () async {
      await playEpisode(1, _threeChapters(1));
      await playAt(const Duration(seconds: 30));
      armEndOfChapter();

      await lifecycleEvent(
        const SeekStartedLifecycle(Duration(seconds: 130), seekId: 1),
      );
      await lifecycleEvent(
        const SeekFailedLifecycle(Duration(seconds: 30), seekId: 1),
      );
      checkCancelled();
    },
  );

  test('resuming at the saved position keeps the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 90));
    armEndOfChapter();

    // The source reports zero once loaded, before the player seeks back to
    // the saved position.
    await playAt(Duration.zero);
    await lifecycleEvent(
      const SeekStartedLifecycle(
        Duration(seconds: 90),
        seekId: 1,
        automatic: true,
      ),
    );
    await playAt(const Duration(seconds: 90));
    await lifecycleEvent(const SeekLifecycle(Duration(seconds: 90), seekId: 1));
    checkNotFired();

    await playAt(const Duration(milliseconds: 120100));
    checkFiredOnce(const Duration(seconds: 120));
  });

  test('a rewind after an interruption keeps the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 62));
    armEndOfChapter();

    // Pause-and-rewind lands a few seconds into the previous chapter.
    await lifecycleEvent(
      const SeekStartedLifecycle(
        Duration(seconds: 57),
        seekId: 1,
        automatic: true,
      ),
    );
    await playAt(const Duration(seconds: 57));
    await lifecycleEvent(const SeekLifecycle(Duration(seconds: 57), seekId: 1));
    await playAt(const Duration(milliseconds: 60100));
    checkNotFired();

    await playAt(const Duration(milliseconds: 120100));
    checkFiredOnce(const Duration(seconds: 120));
  });

  test('armed in the last chapter, it stops at the episode end', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 150));
    armEndOfChapter();

    await playAt(const Duration(seconds: 299));
    checkNotFired();

    await lifecycleEvent(const EpisodeCompletedLifecycle());
    // The end-of-episode stop: no fade, and the queue does not advance.
    check(player.suppressCount).equals(1);
    check(player.fadeCount).equals(0);
    check(player.pauseCount).equals(0);
    check(player.pausedAt).isEmpty();
    check(timerEvents).single.isA<SleepTimerFired>();
    check(config()).isA<SleepTimerConfigOff>();
  });

  test('a manual episode switch cancels the timer', () async {
    await playEpisode(1, _threeChapters(1));
    await playAt(const Duration(seconds: 30));
    armEndOfChapter();

    await lifecycleEvent(const EpisodeSwitchedLifecycle());
    await playEpisode(2, _threeChapters(2));
    await playAt(const Duration(seconds: 10));
    checkCancelled();

    // The new episode's chapter boundary does not fire anything.
    await playAt(const Duration(milliseconds: 60100));
    checkCancelled();
  });

  test(
    'chapters loading after arming neither fire nor cancel the timer',
    () async {
      await playEpisode(1, const []);
      await playAt(const Duration(seconds: 90));
      armEndOfChapter();

      // Chapters arrive for the playing episode, then are replaced by a set
      // with more boundaries: the chapter at 90s moves from index 0 to 1.
      chapters.emit(1, [_chapter(1, 0, 0), _chapter(1, 1, 120)]);
      await pumpEventQueue();
      chapters.emit(1, _threeChapters(1));
      await pumpEventQueue();
      await playAt(const Duration(seconds: 91));
      checkNotFired();

      await playAt(const Duration(milliseconds: 120100));
      checkFiredOnce(const Duration(seconds: 120));
    },
  );
}
