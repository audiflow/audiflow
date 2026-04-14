import 'package:freezed_annotation/freezed_annotation.dart';

import 'sleep_timer_config.dart';

part 'sleep_timer_state.freezed.dart';

/// Aggregate sleep-timer state exposed by the controller.
///
/// `lastMinutes` and `lastEpisodes` are the user's most recent numeric
/// selections (0 when never set). They persist across app restarts.
@freezed
sealed class SleepTimerState with _$SleepTimerState {
  const factory SleepTimerState({
    required SleepTimerConfig config,
    required int lastMinutes,
    required int lastEpisodes,
  }) = _SleepTimerState;
}
