import '../../../../l10n/app_localizations.dart';

/// Localized compact duration label for the episode play pill.
///
/// - `< 60s` → `0:ss` (locale-neutral numeric).
/// - `>= 60s` → localized `{minutes}m` / `{minutes}分`.
/// - non-positive durations → `0:00`.
String episodePillDurationLabel(Duration duration, AppLocalizations l10n) {
  final secs = duration.inSeconds;
  if (secs <= 0) return '0:00';
  if (secs < 60) {
    return '0:${secs.toString().padLeft(2, '0')}';
  }
  return l10n.episodePillDurationMinutes(duration.inMinutes);
}
