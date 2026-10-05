import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../../transcript/models/episode_chapter.dart';
import '../models/current_chapter.dart';
import '../models/sleep_timer_config.dart';
import '../models/sleep_timer_event.dart';
import '../models/sleep_timer_state.dart';
import '../providers/current_chapter_providers.dart';
import '../providers/sleep_timer_providers.dart';
import '../services/audio_player_service.dart';
import '../services/chapter_crossing_tracker.dart';
import '../services/player_lifecycle_events.dart';
import '../services/sleep_timer_service.dart';

part 'sleep_timer_controller.g.dart';

/// Reports whether the currently-playing episode has any chapter data.
///
/// Used by [SleepTimerController] to hide the "End of chapter" menu entry
/// and to evaluate chapter-dependent decisions. Returns false when no
/// episode is playing or when the episode has no chapters.
@riverpod
Future<bool> currentEpisodeHasChapters(Ref ref) async {
  final chapters = await ref.watch(currentEpisodeChaptersProvider.future);
  return chapters.isNotEmpty;
}

/// Coordinates the sleep timer: subscribes to player lifecycle events,
/// runs a 1s duration tick, and executes decisions from [SleepTimerService].
///
/// Kept alive so remembered values survive screen navigation.
@Riverpod(keepAlive: true)
class SleepTimerController extends _$SleepTimerController {
  static const SleepTimerService _service = SleepTimerService();

  final StreamController<SleepTimerEvent> _events =
      StreamController<SleepTimerEvent>.broadcast();
  ChapterCrossingTracker _chapterTracker = ChapterCrossingTracker();
  Timer? _tick;

  Stream<SleepTimerEvent> get events => _events.stream;

  @override
  SleepTimerState build() {
    final ds = ref.watch(sleepTimerPreferencesDatasourceProvider);
    final initial = SleepTimerState(
      config: const SleepTimerConfig.off(),
      lastMinutes: ds.getLastMinutes(),
      lastEpisodes: ds.getLastEpisodes(),
    );

    // playerLifecycleEventsProvider is a plain Provider<Stream<...>>, so
    // ref.watch keeps it materialized and returns the underlying broadcast
    // stream directly. One live subscription for the controller's lifetime,
    // no AsyncValue wrapper.
    final stream = ref.watch(playerLifecycleEventsProvider);
    final lifecycleSub = stream.listen(_onLifecycle);

    // A fresh tracker makes the immediate observation below a baseline, so
    // build() never evaluates a chapter event.
    _chapterTracker = ChapterCrossingTracker();
    // Tracked whatever the mode, so a timer armed mid-chapter already knows
    // which chapter it is in. Both are listened: a chapter list replaced
    // without changing the current chapter must still move the baseline.
    ref.listen<CurrentChapter?>(
      currentChapterProvider,
      (_, _) => _observeChapter(),
      fireImmediately: true,
    );
    ref.listen(currentEpisodeChaptersProvider, (_, _) => _observeChapter());

    ref.onDispose(() {
      lifecycleSub.cancel();
      _tick?.cancel();
      _events.close();
    });

    return initial;
  }

  void setOff() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.off());
  }

  void setEndOfEpisode() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.endOfEpisode());
    _logSleepTimerSet(SleepTimerMode.endOfEpisode);
  }

  void setEndOfChapter() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.endOfChapter());
    _logSleepTimerSet(SleepTimerMode.endOfChapter);
  }

  Future<void> setDuration(Duration total) async {
    final minutes = total.inMinutes.clamp(1, 999);
    final clamped = Duration(minutes: minutes);
    final deadline = DateTime.now().add(clamped);

    await ref
        .read(sleepTimerPreferencesDatasourceProvider)
        .setLastMinutes(minutes);

    _startTick();
    state = state.copyWith(
      config: SleepTimerConfig.duration(total: clamped, deadline: deadline),
      lastMinutes: minutes,
    );
    _logSleepTimerSet(SleepTimerMode.duration, value: minutes);
  }

  Future<void> setEpisodes(int total) async {
    final clamped = total.clamp(1, 99);
    await ref
        .read(sleepTimerPreferencesDatasourceProvider)
        .setLastEpisodes(clamped);

    _tick?.cancel();
    _tick = null;
    state = state.copyWith(
      config: SleepTimerConfig.episodes(total: clamped, remaining: clamped),
      lastEpisodes: clamped,
    );
    _logSleepTimerSet(SleepTimerMode.episodes, value: clamped);
  }

  void _logSleepTimerSet(SleepTimerMode mode, {int? value}) {
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .log(SleepTimerSet(mode: mode, value: value)),
    );
  }

  Duration? remaining() {
    return switch (state.config) {
      SleepTimerConfigDuration(:final deadline) =>
        deadline.difference(DateTime.now()).isNegative
            ? Duration.zero
            : deadline.difference(DateTime.now()),
      _ => null,
    };
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _onTick() => _evaluate(TickEvent(DateTime.now()));

  void _onLifecycle(PlayerLifecycleEvent event) {
    if (event is SeekLifecycle) {
      _chapterTracker.seekCompleted();
      return;
    }
    if (event is SeekFailedLifecycle) {
      _chapterTracker.seekFailed();
      return;
    }
    final mapped = switch (event) {
      EpisodeCompletedLifecycle() => const EpisodeCompletedEvent(),
      EpisodeSwitchedLifecycle() => const ManualEpisodeSwitchedEvent(),
      SeekStartedLifecycle(:final target) => _chapterTracker.seekStarted(
        target,
        now: DateTime.now(),
      ),
      SeekLifecycle() || SeekFailedLifecycle() => null,
    };
    if (mapped != null) _evaluate(mapped);
  }

  void _observeChapter() {
    final chapterEvent = _chapterTracker.observe(
      chapters: _currentChapters(),
      current: ref.read(currentChapterProvider),
      now: DateTime.now(),
    );
    if (chapterEvent != null) _evaluate(chapterEvent);
  }

  // Read from the chapter list this controller listens to, not from
  // currentEpisodeHasChaptersProvider: that one is auto-disposed and only
  // resolved while the sleep sheet is open, so in the background it would
  // read as "no chapters" and keep an end-of-chapter timer from firing.
  List<EpisodeChapter>? _currentChapters() =>
      ref.read(currentEpisodeChaptersProvider).unwrapPrevious().value;

  void _evaluate(SleepTimerPlayerEvent event) {
    final hasChapters = _currentChapters()?.isNotEmpty ?? false;
    _applyDecision(
      _service.evaluate(
        config: state.config,
        event: event,
        currentEpisodeHasChapters: hasChapters,
      ),
    );
  }

  void _applyDecision(SleepTimerDecision decision) {
    switch (decision) {
      case KeepDecision():
        return;
      case FireDecision(:final immediate):
        _fire(immediate: immediate);
      case DecrementEpisodesDecision():
        final cfg = state.config;
        if (cfg is SleepTimerConfigEpisodes) {
          state = state.copyWith(
            config: SleepTimerConfig.episodes(
              total: cfg.total,
              remaining: cfg.remaining - 1,
            ),
          );
        }
      case RetargetChapterDecision():
        // The tracker already moved its baseline to the seek target, so the
        // next natural crossing ends the new chapter.
        return;
    }
  }

  void _fire({bool immediate = false}) {
    _tick?.cancel();
    _tick = null;
    final player = ref.read(audioPlayerControllerProvider.notifier);
    if (immediate) {
      // Audio already reached silence at end-of-stream. Calling pause()
      // here would emit a redundant playerStateStream event that re-enters
      // the completed-state handler concurrently and consumes the
      // suppression flag, letting the original handler advance the queue.
      // The audio_player_service's completed-state branch sets
      // PlaybackState.paused itself once it observes the flag.
      player.suppressNextAutoAdvance();
    } else {
      unawaited(player.fadeOutAndPause());
    }
    _events.add(const SleepTimerFired());
    state = state.copyWith(config: const SleepTimerConfig.off());
  }
}
