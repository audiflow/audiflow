import 'package:audiflow_domain/audiflow_domain.dart';

import '../../../../l10n/app_localizations.dart';

/// Pure label formatter for the active sleep-timer config.
///
/// Returns null when no timer is running.
String? formatSleepTimerLabel(SleepTimerConfig config, AppLocalizations l10n) {
  return switch (config) {
    SleepTimerConfigOff() => null,
    SleepTimerConfigEndOfEpisode() => l10n.sleepTimerChipEpisodeEnd,
    SleepTimerConfigEndOfChapter() => l10n.sleepTimerChipChapterEnd,
    SleepTimerConfigEpisodes(:final remaining) =>
      l10n.sleepTimerChipEpisodesLeft(remaining),
    SleepTimerConfigDuration(:final deadline) =>
      '${l10n.sleepTimerChipDurationPrefix}${formatSleepTimerRemaining(deadline)}',
  };
}

/// Compact label for the chip above the mini player.
///
/// Omits the "Sleep ·" prefix — the moon icon on the chip already
/// communicates the context. Returns null when no timer is running.
String? formatSleepTimerShortLabel(
  SleepTimerConfig config,
  AppLocalizations l10n,
) {
  return switch (config) {
    SleepTimerConfigOff() => null,
    SleepTimerConfigEndOfEpisode() => l10n.sleepTimerShortEpisodeEnd,
    SleepTimerConfigEndOfChapter() => l10n.sleepTimerShortChapterEnd,
    SleepTimerConfigEpisodes(:final remaining) =>
      l10n.sleepTimerShortEpisodesLeft(remaining),
    SleepTimerConfigDuration(:final deadline) => formatSleepTimerRemaining(
      deadline,
    ),
  };
}

/// Pure formatter for the deadline countdown shown on duration timers.
///
/// Returns "MM:SS" when remaining < 1h, "HH:MM:SS" otherwise. Negative
/// remaining clamps to zero.
String formatSleepTimerRemaining(DateTime deadline) {
  final remaining = deadline.difference(DateTime.now());
  final clamped = remaining.isNegative ? Duration.zero : remaining;
  final totalSeconds = clamped.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String pad2(int v) => v.toString().padLeft(2, '0');
  if (0 < hours) return '${pad2(hours)}:${pad2(minutes)}:${pad2(seconds)}';
  return '${pad2(minutes)}:${pad2(seconds)}';
}

/// Status line shown under the sleep-timer sheet title while a timer is
/// active. Returns null when no timer is running.
///
/// [formatClock] renders the wall-clock deadline (e.g. "23:45") so the
/// caller can honour the platform's 12/24-hour setting.
String? formatSleepTimerSheetStatus(
  SleepTimerConfig config,
  AppLocalizations l10n, {
  required String Function(DateTime deadline) formatClock,
}) {
  return switch (config) {
    SleepTimerConfigOff() => null,
    SleepTimerConfigEndOfEpisode() => l10n.sleepTimerStatusEndOfEpisode,
    SleepTimerConfigEndOfChapter() => l10n.sleepTimerStatusEndOfChapter,
    SleepTimerConfigEpisodes(:final remaining) =>
      l10n.sleepTimerStatusEpisodesLeft(remaining),
    SleepTimerConfigDuration(:final deadline) => l10n.sleepTimerStatusDuration(
      formatSleepTimerRemaining(deadline),
      formatClock(deadline),
    ),
  };
}
