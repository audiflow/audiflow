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
  // An open replay shows its playback state even before it has a saved
  // position past zero, where it is not yet in progress.
  final listenFinished = progress?.history?.isListenFinished ?? false;
  return listenFinished && !isPlaying;
}
