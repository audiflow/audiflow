import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_timer_config.freezed.dart';

/// Configuration for the active sleep timer.
///
/// See `docs/superpowers/specs/2026-04-14-sleep-timer-design.md` for the
/// full behavioral specification.
@freezed
sealed class SleepTimerConfig with _$SleepTimerConfig {
  const factory SleepTimerConfig.off() = SleepTimerConfigOff;
  const factory SleepTimerConfig.endOfEpisode() = SleepTimerConfigEndOfEpisode;
  const factory SleepTimerConfig.endOfChapter() = SleepTimerConfigEndOfChapter;
  const factory SleepTimerConfig.duration({
    required Duration total,
    required DateTime deadline,
  }) = SleepTimerConfigDuration;
  const factory SleepTimerConfig.episodes({
    required int total,
    required int remaining,
  }) = SleepTimerConfigEpisodes;
}
