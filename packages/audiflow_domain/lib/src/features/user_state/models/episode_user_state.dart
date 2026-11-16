import 'package:isar_community/isar.dart';

part 'episode_user_state.g.dart';

/// What the user did with one episode, keyed so every device names it the
/// same way (docs/architecture/user-data-sync.md, "Local storage").
///
/// Replaces `PlaybackHistory` and the favorite fields on `Episode`, which
/// point at episodes by local auto-increment id. Each value carries the
/// [Hlc] of its last change (`*Hlc`, packed), so two devices' versions
/// merge field by field. Totals that both devices add to are per-device
/// grow-only [counters], summed for display.
///
/// A row exists only for an episode the user touched. Its episode may be
/// missing from the catalog (not fetched yet, or dropped from the feed);
/// readers then hide it rather than delete it.
@collection
class EpisodeUserState {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String episodeKey;

  /// The episode's podcast, for per-podcast queries before the catalog
  /// resolves the episode.
  @Index()
  late String podcastKey;

  /// Whether playback state exists, mirroring whether a `PlaybackHistory`
  /// row would: a favorite alone leaves it false.
  bool hasPlayback = false;
  int hasPlaybackHlc = 0;

  int positionMs = 0;
  int positionHlc = 0;

  int? durationMs;
  int durationHlc = 0;

  /// See `PlaybackHistory.completedAt`.
  DateTime? completedAt;
  int completedAtHlc = 0;

  /// `PlaybackHistory.isReplaying` and `isReplayFromStart`, which only
  /// change together, so they share one timestamp.
  bool isReplaying = false;
  bool isReplayFromStart = false;
  int replayHlc = 0;

  DateTime? firstPlayedAt;
  int firstPlayedAtHlc = 0;

  DateTime? lastPlayedAt;
  int lastPlayedAtHlc = 0;

  /// When the episode was favorited; null when it is not a favorite.
  DateTime? favoritedAt;
  int favoritedAtHlc = 0;

  /// One entry per device that played this episode.
  List<EpisodePlayCounters> counters = [];
}

/// Grow-only totals one device contributed to an episode.
///
/// Only the owning device changes its entry, and only upward, so merging
/// two copies takes the larger value per device and never loses a listen.
@embedded
class EpisodePlayCounters {
  String deviceId = '';
  int playCount = 0;
  int completedCount = 0;
  int listenedMs = 0;
  int realtimeMs = 0;
}
