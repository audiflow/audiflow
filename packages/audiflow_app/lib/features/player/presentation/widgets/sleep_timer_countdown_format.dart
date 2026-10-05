import 'package:audiflow_domain/audiflow_domain.dart';

import '../../../../l10n/app_localizations.dart';
import '../../helpers/playback_time_format.dart';

/// Seek bar countdown for the active sleep timer, e.g. `12:05`, or
/// `30:00 +2` when two further episodes of unknown length follow.
///
/// Uses the player's clock format so it matches the other time labels.
String formatSleepTimerCountdown(SleepTimerTimeLeft left) {
  final time = formatPlaybackTime(left.time);
  if (left.isComplete) return time;
  return '$time +${left.extraEpisodes}';
}

/// Screen reader label for the active sleep timer.
///
/// With [includeMode], names the stop condition before the time left
/// ("Sleep timer, stops at end of episode, 12 minutes left"); a duration
/// timer has no condition beyond its time left. Returns null when no timer
/// is armed.
String? sleepTimerSemanticsLabel(
  SleepTimerConfig config,
  SleepTimerTimeLeft? left,
  AppLocalizations l10n, {
  required bool includeMode,
}) {
  if (config is SleepTimerConfigOff) return null;
  final mode = includeMode ? _modePhrase(config, l10n) : null;
  final time = left == null ? null : spokenSleepTimerTimeLeft(left, l10n);
  final status = switch ((mode, time)) {
    (final mode?, final time?) => l10n.sleepTimerSemanticsStatusAndTimeLeft(
      mode,
      time,
    ),
    (final mode?, null) => mode,
    (null, final time?) => time,
    (null, null) => null,
  };
  if (status == null) return l10n.sleepTimerIconLabel;
  return l10n.sleepTimerSemanticsLabel(status);
}

/// Time left as speech, e.g. "1 hour 5 minutes left".
String spokenSleepTimerTimeLeft(
  SleepTimerTimeLeft left,
  AppLocalizations l10n,
) {
  final time = _spokenDuration(left.time, l10n);
  if (left.isComplete) return l10n.sleepTimerSemanticsTimeLeft(time);
  return l10n.sleepTimerSemanticsTimeLeftPlusEpisodes(time, left.extraEpisodes);
}

String? _modePhrase(SleepTimerConfig config, AppLocalizations l10n) {
  return switch (config) {
    SleepTimerConfigEndOfEpisode() => l10n.sleepTimerSemanticsEndOfEpisode,
    SleepTimerConfigEndOfChapter() => l10n.sleepTimerSemanticsEndOfChapter,
    SleepTimerConfigEpisodes(:final remaining) =>
      l10n.sleepTimerSemanticsEpisodes(remaining),
    SleepTimerConfigDuration() || SleepTimerConfigOff() => null,
  };
}

/// Seconds under a minute, else hours and minutes rounded up so the spoken
/// time never undercuts the countdown.
String _spokenDuration(Duration time, AppLocalizations l10n) {
  if (time.inSeconds < 60) return l10n.sleepTimerSpokenSeconds(time.inSeconds);
  final totalMinutes = (time.inSeconds + 59) ~/ 60;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return l10n.sleepTimerMinutesLabel(minutes);
  if (minutes == 0) return l10n.sleepTimerSpokenHours(hours);
  return l10n.sleepTimerSpokenHoursMinutes(
    l10n.sleepTimerSpokenHours(hours),
    l10n.sleepTimerMinutesLabel(minutes),
  );
}

/// Whether [next] is a newly armed timer rather than the running one
/// changing on its own (an episode-count timer counting down).
///
/// Re-arming the very same condition leaves the config equal and is not
/// seen as a change.
bool isNewSleepTimerArm(SleepTimerConfig? previous, SleepTimerConfig next) {
  if (next is SleepTimerConfigOff || previous == next) return false;
  if (previous is SleepTimerConfigEpisodes &&
      next is SleepTimerConfigEpisodes) {
    return previous.total != next.total || previous.remaining < next.remaining;
  }
  return true;
}
