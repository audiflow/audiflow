/// Player clock label: `mm:ss`, or `h:mm:ss` from one hour up; `--:--` when
/// the time is unknown.
String formatPlaybackTime(Duration? duration) {
  if (duration == null) return '--:--';
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (60 <= duration.inMinutes) return '${duration.inHours}:$minutes:$seconds';
  return '$minutes:$seconds';
}
