import 'package:meta/meta.dart';

/// How long playback continues before the active sleep timer stops it.
///
/// [time] is wall-clock time: playback speed is already applied. When the
/// stop point lies in later episodes whose durations are unknown, [time]
/// covers only the current episode and [extraEpisodes] counts the further
/// episodes that still play after it.
@immutable
class SleepTimerTimeLeft {
  const SleepTimerTimeLeft(this.time, {this.extraEpisodes = 0});

  final Duration time;

  /// Further episodes not included in [time]; zero when [time] is complete.
  final int extraEpisodes;

  /// Whether [time] reaches all the way to the stop point.
  bool get isComplete => extraEpisodes == 0;

  @override
  bool operator ==(Object other) =>
      other is SleepTimerTimeLeft &&
      other.time == time &&
      other.extraEpisodes == extraEpisodes;

  @override
  int get hashCode => Object.hash(time, extraEpisodes);

  @override
  String toString() => 'SleepTimerTimeLeft($time, +$extraEpisodes)';
}
