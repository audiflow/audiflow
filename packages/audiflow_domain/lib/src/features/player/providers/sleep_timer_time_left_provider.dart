import 'dart:async';

import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../queue/providers/queue_providers.dart';
import '../controllers/sleep_timer_controller.dart';
import '../models/sleep_timer_config.dart';
import '../models/sleep_timer_time_left.dart';
import '../services/audio_player_service.dart';
import '../services/now_playing_controller.dart';
import '../services/sleep_timer_time_left_calculator.dart';
import 'current_chapter_providers.dart';
import 'now_playing_speed_provider.dart';

part 'sleep_timer_time_left_provider.g.dart';

/// Time until the active sleep timer stops playback; null when no timer is
/// armed or the stop point is unknown.
///
/// A duration timer refreshes on each whole second of its countdown. The
/// other modes follow the playback position, chapters, queue, and speed.
@riverpod
SleepTimerTimeLeft? sleepTimerTimeLeft(Ref ref) {
  final config = ref.watch(
    sleepTimerControllerProvider.select((state) => state.config),
  );
  final now = DateTime.now();
  return switch (config) {
    SleepTimerConfigOff() => null,
    SleepTimerConfigDuration(:final deadline) => _countDown(
      ref,
      config,
      deadline,
      now,
    ),
    _ => computeSleepTimerTimeLeft(
      config: config,
      now: now,
      playback: _playback(ref, config),
    ),
  };
}

/// Computes a duration timer's time left and schedules a rebuild for the
/// moment the displayed second changes.
SleepTimerTimeLeft? _countDown(
  Ref ref,
  SleepTimerConfig config,
  DateTime deadline,
  DateTime now,
) {
  final left = deadline.difference(now);
  if (!left.isNegative) {
    final subSecond = left - Duration(seconds: left.inSeconds);
    final delay = subSecond == Duration.zero
        ? const Duration(seconds: 1)
        : subSecond;
    final timer = Timer(delay, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return computeSleepTimerTimeLeft(
    config: config,
    now: now,
    playback: _noPlayback,
  );
}

const SleepTimerPlayback _noPlayback = (
  position: null,
  duration: null,
  speed: 1.0,
  chapters: [],
  upNextDurations: null,
);

SleepTimerPlayback _playback(Ref ref, SleepTimerConfig config) {
  final (:position, :duration) = _progress(ref);
  return (
    position: position,
    duration: duration,
    speed: ref.watch(nowPlayingSpeedProvider),
    chapters: config is SleepTimerConfigEndOfChapter
        ? ref.watch(currentEpisodeChaptersProvider).unwrapPrevious().value ??
              const []
        : const [],
    upNextDurations: config is SleepTimerConfigEpisodes
        ? _upNextDurations(ref)
        : null,
  );
}

/// Live position and duration while audio is loaded, else the restored
/// saved position and episode length, mirroring the player screen.
({Duration? position, Duration? duration}) _progress(Ref ref) {
  final live = ref.watch(playbackProgressProvider);
  if (live != null && 0 < live.duration.inMilliseconds) {
    return (position: live.position, duration: live.duration);
  }
  final info = ref.watch(nowPlayingControllerProvider);
  return (position: info?.savedPosition, duration: info?.totalDuration);
}

List<Duration?>? _upNextDurations(Ref ref) {
  final queue = ref.watch(playbackQueueProvider).value;
  if (queue == null) return null;
  final nowPlayingUrl = ref.watch(
    nowPlayingControllerProvider.select((info) => info?.episodeUrl),
  );
  return [
    for (final item in queue.upNextItems(nowPlayingUrl: nowPlayingUrl))
      switch (item.episode.durationMs) {
        final ms? => Duration(milliseconds: ms),
        null => null,
      },
  ];
}
