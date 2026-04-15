import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transcript/repositories/chapter_repository_impl.dart';
import '../models/sleep_timer_config.dart';
import '../models/sleep_timer_event.dart';
import '../models/sleep_timer_state.dart';
import '../providers/sleep_timer_providers.dart';
import '../services/audio_player_service.dart';
import '../services/now_playing_controller.dart';
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
  final nowPlaying = ref.watch(nowPlayingControllerProvider);
  final episodeId = nowPlaying?.episode?.id;
  if (episodeId == null) return false;
  final chapters = await ref
      .watch(chapterRepositoryProvider)
      .getByEpisodeId(episodeId);
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
  }

  void setEndOfChapter() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.endOfChapter());
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

  void _onTick() {
    final hasChapters =
        ref.read(currentEpisodeHasChaptersProvider).value ?? false;
    final decision = _service.evaluate(
      config: state.config,
      event: TickEvent(DateTime.now()),
      currentEpisodeHasChapters: hasChapters,
    );
    _applyDecision(decision);
  }

  void _onLifecycle(PlayerLifecycleEvent event) {
    final mapped = switch (event) {
      EpisodeCompletedLifecycle() => const EpisodeCompletedEvent(),
      EpisodeSwitchedLifecycle() => const ManualEpisodeSwitchedEvent(),
      SeekLifecycle() => null,
    };
    if (mapped == null) return;

    final hasChapters =
        ref.read(currentEpisodeHasChaptersProvider).value ?? false;
    final decision = _service.evaluate(
      config: state.config,
      event: mapped,
      currentEpisodeHasChapters: hasChapters,
    );
    _applyDecision(decision);
  }

  void _applyDecision(SleepTimerDecision decision) {
    switch (decision) {
      case KeepDecision():
        return;
      case FireDecision():
        _fire();
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
        return;
    }
  }

  void _fire() {
    _tick?.cancel();
    _tick = null;
    final player = ref.read(audioPlayerControllerProvider.notifier);
    unawaited(player.fadeOutAndPause());
    _events.add(const SleepTimerFired());
    state = state.copyWith(config: const SleepTimerConfig.off());
  }
}
