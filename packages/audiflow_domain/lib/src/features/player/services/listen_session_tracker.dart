import '../../monitoring/models/analytics_event.dart';

/// Tracks the currently open contiguous listening segment and turns it
/// into an [EpisodeListenSession] when it ends.
///
/// Pure state holder: the player decides when segments open and close
/// (play, pause, seek, speed change, switch, stop, completion), this
/// class only remembers where one started. Identity is captured at
/// [open] so a close that happens after `NowPlayingInfo` has already
/// moved on to the next episode still reports the episode that was heard.
class ListenSessionTracker {
  ListenSessionTracker({this.minSegmentSec = 2});

  /// Segments shorter than this are dropped: rapid skip-button taps
  /// would otherwise emit a burst of near-empty sessions.
  final int minSegmentSec;

  ({EpisodeAnalyticsIds ids, int startSec, double speed})? _open;

  bool get isOpen => _open != null;

  /// Identity of the open segment, so a split (seek, speed change) can
  /// reopen under the same episode without re-resolving it.
  EpisodeAnalyticsIds? get openIds => _open?.ids;

  /// Starts a segment. No-op when one is already open, because the
  /// player state stream re-reports `playing` on every processing-state
  /// change (buffering -> ready) within the same segment.
  void open({
    required EpisodeAnalyticsIds ids,
    required int positionSec,
    required double speed,
  }) {
    if (_open != null) return;
    _open = (ids: ids, startSec: positionSec, speed: speed);
  }

  /// Ends the open segment. Returns null when nothing was open or the
  /// segment is too short to be meaningful.
  EpisodeListenSession? close({
    required int positionSec,
    required int durationSec,
    required ListenEndReason reason,
  }) {
    final segment = _open;
    _open = null;
    if (segment == null) return null;
    if (positionSec - segment.startSec < minSegmentSec) return null;

    final ids = segment.ids;
    return EpisodeListenSession(
      podcastId: ids.podcastId,
      feedUrl: ids.feedUrl,
      episodeId: ids.episodeId,
      podcastTitle: ids.podcastTitle,
      episodeTitle: ids.episodeTitle,
      startSec: segment.startSec,
      endSec: positionSec,
      durationSec: durationSec,
      speed: segment.speed,
      endReason: reason,
    );
  }
}
