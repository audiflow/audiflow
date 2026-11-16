import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../../player/models/playback_history.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/episode_user_state.dart';
import 'user_state_store.dart';

/// Reads and writes [EpisodeUserState] in the shape of the models callers
/// already use (`PlaybackHistory`, `Episode.isFavorited`).
///
/// For one release the old rows keep being written next to the new ones,
/// so a rollback still finds them. Reads prefer the new row and fall back
/// to the old one only for an episode that has no new row yet: one whose
/// podcast has no stable key (not parsed since keys were introduced), or,
/// defensively, one keyed without its state having been copied.
class EpisodeUserStateAccess {
  EpisodeUserStateAccess(this._isar, {Logger? logger})
    : _logger = logger ?? _compareLogger;

  final Isar _isar;
  final Logger _logger;

  static final _compareLogger = NamedLogger('UserStateCompare');

  /// The playback history of [episodeId], from the new row when it has
  /// playback, otherwise from the old one.
  Future<PlaybackHistory?> history(int episodeId) async {
    final slot = await loadSlot(episodeId);
    return slot.history;
  }

  /// Whether [episode] is a favorite.
  Future<bool> isFavorited(Episode episode) async {
    final key = episode.episodeKey;
    if (key == null) return episode.isFavorited;
    final state = await _isar.episodeUserStates.getByEpisodeKey(key);
    if (state == null || state.favoritedAtHlc == 0) return episode.isFavorited;
    return state.favoritedAt != null;
  }

  /// Reads everything a playback write needs about [episodeId].
  ///
  /// In debug builds, compares the old and new rows and logs a mismatch.
  Future<PlaybackSlot> loadSlot(int episodeId) async {
    final legacy = await _isar.playbackHistorys.getByEpisodeId(episodeId);
    final episode = await _isar.episodes.get(episodeId);
    final key = episode?.episodeKey;
    final state = key == null
        ? null
        : await _isar.episodeUserStates.getByEpisodeKey(key);
    final fromState = state != null && state.hasPlayback
        ? historyFromState(state, episodeId)
        : null;
    if (fromState != null && legacy != null) {
      _reportMismatch(episodeId, legacy, fromState);
    }
    return PlaybackSlot._(
      episodeId: episodeId,
      episode: episode,
      state: state,
      legacyId: legacy?.id,
      history: fromState ?? legacy,
    );
  }

  /// Writes [history] as the playback state of [slot]'s episode, to the
  /// old row and, when the episode is keyed, to its [EpisodeUserState].
  ///
  /// Must run inside [UserStateStore.write].
  Future<void> saveHistory(
    PlaybackSlot slot,
    PlaybackHistory history,
    UserStateTxn txn,
  ) async {
    history
      ..id = slot.legacyId ?? Isar.autoIncrement
      ..episodeId = slot.episodeId;
    await _isar.playbackHistorys.put(history);
    final state = slot.state ?? await _newState(slot.episode);
    if (state == null) return;
    applyHistory(state, history, txn);
    await _isar.episodeUserStates.put(state);
  }

  /// Writes the favorite of [episode]; must run inside
  /// [UserStateStore.write]. The caller has already updated the old
  /// fields on [episode].
  Future<void> saveFavorite(Episode episode, UserStateTxn txn) async {
    final key = episode.episodeKey;
    if (key == null) return;
    final state =
        await _isar.episodeUserStates.getByEpisodeKey(key) ??
        await _newState(episode);
    if (state == null) return;
    applyFavorite(state, episode.favoritedAt, txn);
    await _isar.episodeUserStates.put(state);
  }

  /// Copies the old user state of [episode] into its new row unless that
  /// row already has it. Idempotent; must run inside
  /// [UserStateStore.write].
  ///
  /// Runs for existing data at launch (the backfill migration) and for an
  /// episode the moment it gets its key.
  Future<void> copyLegacy(Episode episode, UserStateTxn txn) async {
    final key = episode.episodeKey;
    if (key == null) return;
    final legacy = await _isar.playbackHistorys.getByEpisodeId(episode.id);
    final wantsFavorite = episode.isFavorited;
    if (legacy == null && !wantsFavorite) return;
    var state = await _isar.episodeUserStates.getByEpisodeKey(key);
    final needsHistory = legacy != null && !(state?.hasPlayback ?? false);
    final needsFavorite = wantsFavorite && (state?.favoritedAtHlc ?? 0) == 0;
    if (!needsHistory && !needsFavorite) return;
    state ??= await _newState(episode);
    if (state == null) return;
    if (needsHistory) applyHistory(state, legacy, txn);
    if (needsFavorite) {
      applyFavorite(state, episode.favoritedAt ?? DateTime.now(), txn);
    }
    await _isar.episodeUserStates.put(state);
  }

  /// Resolves new rows to their catalog episodes and merges in the old
  /// rows of episodes that have no new playback state.
  ///
  /// New rows whose episode is not in the catalog are left out: the state
  /// is kept for when the episode arrives, but there is no local id to
  /// report it under. Callers read [states], [legacy], and this resolution
  /// in one read transaction, so all of them see the same snapshot.
  Future<List<PlaybackHistory>> resolve({
    required List<EpisodeUserState> states,
    required List<PlaybackHistory> legacy,
  }) async {
    final result = <PlaybackHistory>[];
    final covered = <int>{};
    final byKey = await _episodesByKey(states.map((s) => s.episodeKey));
    for (final state in states) {
      final episode = byKey[state.episodeKey];
      if (episode == null || !covered.add(episode.id)) continue;
      result.add(historyFromState(state, episode.id));
    }

    final legacyEpisodes = await _isar.episodes.getAll(
      legacy.map((h) => h.episodeId).toList(),
    );
    final keys = [for (final e in legacyEpisodes) ?e?.episodeKey];
    final withPlayback = {
      for (final s in await _isar.episodeUserStates.getAllByEpisodeKey(keys))
        if (s != null && s.hasPlayback) s.episodeKey,
    };
    for (var i = 0; i < legacy.length; i++) {
      final episode = legacyEpisodes[i];
      // An old row whose episode is gone stays visible, as it was before
      // the new rows existed; its readers already skip it.
      if (episode != null) {
        if (covered.contains(episode.id)) continue;
        final key = episode.episodeKey;
        if (key != null && withPlayback.contains(key)) continue;
      }
      result.add(legacy[i]);
    }
    return result;
  }

  Future<Map<String, Episode>> _episodesByKey(Iterable<String> keys) async {
    final unique = keys.toSet().toList();
    if (unique.isEmpty) return {};
    final episodes = await _isar.episodes
        .where()
        .anyOf(unique, (q, key) => q.episodeKeyEqualTo(key))
        .findAll();
    return {for (final e in episodes) ?e.episodeKey: e};
  }

  Future<EpisodeUserState?> _newState(Episode? episode) async {
    final key = episode?.episodeKey;
    if (episode == null || key == null) return null;
    final podcast = await _isar.subscriptions.get(episode.podcastId);
    final podcastKey = podcast?.podcastKey;
    // An episode is keyed only after its podcast, so this holds unless the
    // podcast row was deleted underneath; then there is nothing to key by.
    if (podcastKey == null) return null;
    return EpisodeUserState()
      ..episodeKey = key
      ..podcastKey = podcastKey;
  }

  void _reportMismatch(int episodeId, PlaybackHistory a, PlaybackHistory b) {
    if (!kDebugMode || sameHistory(a, b)) return;
    _logger.w(
      'EpisodeUserState differs from PlaybackHistory for episode $episodeId: '
      'old ${describeHistory(a)}, new ${describeHistory(b)}',
    );
  }
}

/// What [EpisodeUserStateAccess.loadSlot] found for one episode.
class PlaybackSlot {
  const PlaybackSlot._({
    required this.episodeId,
    required this.episode,
    required this.state,
    required this.legacyId,
    required this.history,
  });

  final int episodeId;
  final Episode? episode;
  final EpisodeUserState? state;
  final int? legacyId;

  /// The current playback history, or null before the first play.
  final PlaybackHistory? history;
}

/// The playback history [state] describes, for the episode [episodeId].
PlaybackHistory historyFromState(EpisodeUserState state, int episodeId) {
  var playCount = 0;
  var completedCount = 0;
  var listenedMs = 0;
  var realtimeMs = 0;
  for (final c in state.counters) {
    playCount += c.playCount;
    completedCount += c.completedCount;
    listenedMs += c.listenedMs;
    realtimeMs += c.realtimeMs;
  }
  return PlaybackHistory()
    ..episodeId = episodeId
    ..positionMs = state.positionMs
    ..durationMs = state.durationMs
    ..completedAt = state.completedAt
    ..isReplaying = state.isReplaying
    ..isReplayFromStart = state.isReplayFromStart
    ..firstPlayedAt = state.firstPlayedAt
    ..lastPlayedAt = state.lastPlayedAt
    ..playCount = playCount
    ..completedCount = completedCount
    ..totalListenedMs = listenedMs
    ..totalRealtimeMs = realtimeMs;
}

/// Records [history] on [state], stamping each field that changed.
///
/// Totals become growth of this device's counters: the amount [history]
/// adds over the current sum. A total that went down is ignored, since
/// counters only grow.
void applyHistory(
  EpisodeUserState state,
  PlaybackHistory history,
  UserStateTxn txn,
) {
  final stamp = txn.stamp.packed;
  if (!state.hasPlayback) {
    state
      ..hasPlayback = true
      ..hasPlaybackHlc = stamp;
  }
  if (state.positionMs != history.positionMs) {
    state
      ..positionMs = history.positionMs
      ..positionHlc = stamp;
  }
  if (state.durationMs != history.durationMs) {
    state
      ..durationMs = history.durationMs
      ..durationHlc = stamp;
  }
  if (state.completedAt != history.completedAt) {
    state
      ..completedAt = history.completedAt
      ..completedAtHlc = stamp;
  }
  if (state.isReplaying != history.isReplaying ||
      state.isReplayFromStart != history.isReplayFromStart) {
    state
      ..isReplaying = history.isReplaying
      ..isReplayFromStart = history.isReplayFromStart
      ..replayHlc = stamp;
  }
  if (state.firstPlayedAt != history.firstPlayedAt) {
    state
      ..firstPlayedAt = history.firstPlayedAt
      ..firstPlayedAtHlc = stamp;
  }
  if (state.lastPlayedAt != history.lastPlayedAt) {
    state
      ..lastPlayedAt = history.lastPlayedAt
      ..lastPlayedAtHlc = stamp;
  }

  final current = historyFromState(state, history.episodeId);
  final playDelta = history.playCount - current.playCount;
  final completedDelta = history.completedCount - current.completedCount;
  final listenedDelta = history.totalListenedMs - current.totalListenedMs;
  final realtimeDelta = history.totalRealtimeMs - current.totalRealtimeMs;
  if (playDelta <= 0 &&
      completedDelta <= 0 &&
      listenedDelta <= 0 &&
      realtimeDelta <= 0) {
    return;
  }
  // Isar hands back a fixed-length list, so the counters are rebuilt.
  final counters = [...state.counters];
  var own = counters.where((c) => c.deviceId == txn.deviceId).firstOrNull;
  if (own == null) {
    own = EpisodePlayCounters()..deviceId = txn.deviceId;
    counters.add(own);
  }
  if (0 < playDelta) own.playCount += playDelta;
  if (0 < completedDelta) own.completedCount += completedDelta;
  if (0 < listenedDelta) own.listenedMs += listenedDelta;
  if (0 < realtimeDelta) own.realtimeMs += realtimeDelta;
  state.counters = counters;
}

/// Records whether the episode is a favorite: [favoritedAt] is when it was
/// favorited, or null when it is not.
void applyFavorite(
  EpisodeUserState state,
  DateTime? favoritedAt,
  UserStateTxn txn,
) {
  if (state.favoritedAtHlc != 0 && state.favoritedAt == favoritedAt) return;
  state
    ..favoritedAt = favoritedAt
    ..favoritedAtHlc = txn.stamp.packed;
}

/// Whether two histories hold the same values, ignoring their row ids.
bool sameHistory(PlaybackHistory a, PlaybackHistory b) =>
    a.episodeId == b.episodeId &&
    a.positionMs == b.positionMs &&
    a.durationMs == b.durationMs &&
    a.completedAt == b.completedAt &&
    a.isReplaying == b.isReplaying &&
    a.isReplayFromStart == b.isReplayFromStart &&
    a.firstPlayedAt == b.firstPlayedAt &&
    a.lastPlayedAt == b.lastPlayedAt &&
    a.playCount == b.playCount &&
    a.completedCount == b.completedCount &&
    a.totalListenedMs == b.totalListenedMs &&
    a.totalRealtimeMs == b.totalRealtimeMs;

/// One-line description of [h] for logs.
String describeHistory(PlaybackHistory h) =>
    '{position: ${h.positionMs}, duration: ${h.durationMs}, '
    'completedAt: ${h.completedAt}, replaying: ${h.isReplaying}/'
    '${h.isReplayFromStart}, first: ${h.firstPlayedAt}, '
    'last: ${h.lastPlayedAt}, plays: ${h.playCount}, '
    'completions: ${h.completedCount}, listened: ${h.totalListenedMs}, '
    'realtime: ${h.totalRealtimeMs}}';
