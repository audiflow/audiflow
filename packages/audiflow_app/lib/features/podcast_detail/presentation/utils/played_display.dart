import 'package:audiflow_domain/audiflow_domain.dart';

/// Whether an episode row or detail shows the played look (check pill,
/// full progress line, muted text).
///
/// A played episode that is being replayed, or is playing right now, shows
/// its playback state instead so it can be paused and resumed. The played
/// status itself (menus, filters, counts) is unaffected (FR 04).
bool showsPlayedState(
  EpisodeWithProgress? progress, {
  required bool isPlaying,
}) {
  if (progress == null || !progress.isCompleted) return false;
  return !progress.isInProgress && !isPlaying;
}
