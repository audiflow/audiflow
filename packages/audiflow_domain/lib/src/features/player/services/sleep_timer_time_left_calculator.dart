import '../../transcript/models/episode_chapter.dart';
import '../models/current_chapter.dart';
import '../models/sleep_timer_config.dart';
import '../models/sleep_timer_time_left.dart';

/// Playback state the sleep timer's time left is computed from.
///
/// [duration] is null or zero while the episode length is unknown.
/// [upNextDurations] lists the queued episodes after the current one in
/// play order, null where a duration is unknown; [upNextDurations] itself is
/// null while the queue has not loaded.
typedef SleepTimerPlayback = ({
  Duration? position,
  Duration? duration,
  double speed,
  List<EpisodeChapter> chapters,
  List<Duration?>? upNextDurations,
});

/// Time until the sleep timer described by [config] stops playback.
///
/// Returns null when no timer is armed or the stop point cannot be placed
/// (unknown episode length, or an end-of-chapter timer without chapters,
/// which the timer treats as inactive). A duration timer counts down wall-
/// clock time from [now]; every other mode counts media time divided by the
/// playback speed.
SleepTimerTimeLeft? computeSleepTimerTimeLeft({
  required SleepTimerConfig config,
  required DateTime now,
  required SleepTimerPlayback playback,
}) {
  return switch (config) {
    SleepTimerConfigOff() => null,
    SleepTimerConfigDuration(:final deadline) => SleepTimerTimeLeft(
      _nonNegative(deadline.difference(now)),
    ),
    SleepTimerConfigEndOfEpisode() => _scaled(
      _mediaUntil(playback, playback.duration),
      playback.speed,
    ),
    SleepTimerConfigEndOfChapter() => _scaled(
      _mediaUntilChapterEnd(playback),
      playback.speed,
    ),
    SleepTimerConfigEpisodes(:final remaining) => _episodesTimeLeft(
      playback,
      remaining,
    ),
  };
}

/// Media time from the position to [end]; null when either is unknown.
Duration? _mediaUntil(SleepTimerPlayback playback, Duration? end) {
  final position = playback.position;
  if (position == null || !_isKnown(end)) return null;
  return _nonNegative(end! - position);
}

/// Media time to the boundary the end-of-chapter timer fires on.
///
/// The timer fires when playback crosses into the next chapter, so the
/// stop point is the next chapter's start. During a lead-in before the
/// first chapter it fires at the end of the first chapter, and in the last
/// chapter the stop point is the end of the episode.
Duration? _mediaUntilChapterEnd(SleepTimerPlayback playback) {
  final chapters = playback.chapters;
  final position = playback.position;
  if (chapters.isEmpty || position == null) return null;
  final nextIndex = (chapterIndexAt(chapters, position) ?? 0) + 1;
  final end = nextIndex < chapters.length
      ? Duration(milliseconds: chapters[nextIndex].startMs)
      : playback.duration;
  return _mediaUntil(playback, end);
}

/// The current episode's remainder plus the next `remaining - 1` queued
/// episodes, or the current remainder with a `+N` count when any of those
/// durations is unknown.
SleepTimerTimeLeft? _episodesTimeLeft(
  SleepTimerPlayback playback,
  int remaining,
) {
  final current = _mediaUntil(playback, playback.duration);
  if (current == null) return null;
  final further = remaining - 1;
  final upNext = playback.upNextDurations;
  if (upNext == null) {
    return _scaled(current, playback.speed, extraEpisodes: further);
  }
  // Playback also stops when the queue runs out before the count does.
  final following = upNext.take(further).toList();
  if (following.any((duration) => !_isKnown(duration))) {
    return _scaled(current, playback.speed, extraEpisodes: following.length);
  }
  final total = following.fold(current, (sum, duration) => sum + duration!);
  return _scaled(total, playback.speed);
}

SleepTimerTimeLeft? _scaled(
  Duration? media,
  double speed, {
  int extraEpisodes = 0,
}) {
  if (media == null) return null;
  // A non-positive speed never reaches the player; read it as normal speed.
  final effective = 0 < speed ? speed : 1.0;
  return SleepTimerTimeLeft(
    Duration(microseconds: (media.inMicroseconds / effective).round()),
    extraEpisodes: extraEpisodes,
  );
}

bool _isKnown(Duration? duration) =>
    duration != null && duration != Duration.zero;

Duration _nonNegative(Duration duration) =>
    duration.isNegative ? Duration.zero : duration;
