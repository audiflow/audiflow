/// Extensions for Duration class
extension DurationExtensions on Duration {
  /// Format duration as MM:SS
  String formatMinutesSeconds() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration as HH:MM:SS
  String formatHoursMinutesSeconds() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Compact label for podcast UIs (pill, list rows).
  ///
  /// - `< 60 s` → `0:ss` zero-padded (e.g. `0:09`, `0:45`).
  /// - `>= 60 s` → `{minutes truncated}m` (e.g. `33m`, `9999m`).
  /// - Negative durations clamp to `0:00`.
  String get podcastShortLabel {
    final secs = inSeconds;
    if (secs <= 0) return '0:00';
    if (secs < 60) {
      return '0:${secs.toString().padLeft(2, '0')}';
    }
    return '${inMinutes}m';
  }
}
