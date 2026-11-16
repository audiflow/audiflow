import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/podcast_view_preference.dart';
import '../../feed/models/smart_playlist_group_user_preference.dart';
import '../../feed/models/smart_playlist_user_preference.dart';
import '../../parental_control/models/podcast_parental_flags.dart';
import '../../settings/models/podcast_audio_preference.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/podcast_user_state.dart';
import '../sync/user_state_fields.dart';
import 'user_state_store.dart';

/// Reads and writes [PodcastUserState] in the shape of the per-podcast
/// preference rows callers already use, addressed by local podcast id.
///
/// As with `EpisodeUserStateAccess`, the old rows keep being written for
/// one release. Each section of the new row is read once it has been
/// written (its `has*Hlc` is set); before that, and for a podcast without
/// a stable key, the old row is read.
class PodcastUserStateAccess {
  PodcastUserStateAccess(this._isar, {Logger? logger})
    : _logger = logger ?? _compareLogger;

  final Isar _isar;
  final Logger _logger;

  static final _compareLogger = NamedLogger('UserStateCompare');

  /// The state row of [podcastId]'s podcast, or null when it has no key or
  /// no row yet.
  Future<PodcastUserState?> stateOf(int podcastId) async {
    final key = (await _isar.subscriptions.get(podcastId))?.podcastKey;
    if (key == null) return null;
    return _isar.podcastUserStates.getByPodcastKey(key);
  }

  /// Like [stateOf], creating the row when the podcast has a key. Null for
  /// a podcast without one.
  Future<PodcastUserState?> _stateForWrite(int podcastId) async {
    final key = (await _isar.subscriptions.get(podcastId))?.podcastKey;
    if (key == null) return null;
    return await _isar.podcastUserStates.getByPodcastKey(key) ??
        (PodcastUserState()..podcastKey = key);
  }

  // -- Subscription --

  /// Records the user fields of [sub] on its state row, after [sub] was
  /// written. Does nothing for a podcast without a key. Must run inside
  /// [UserStateStore.write].
  Future<void> saveSubscription(Subscription sub, UserStateTxn txn) async {
    final key = sub.podcastKey;
    if (key == null) return;
    final state =
        await _isar.podcastUserStates.getByPodcastKey(key) ??
        (PodcastUserState()..podcastKey = key);
    if (!applySubscription(state, sub, txn)) return;
    await _putState(state, txn);
  }

  /// Fills [sub]'s auto-download choices from the subscription section its
  /// key already has, so a catalog row recreated after an eviction, or keyed
  /// for the first time on this device, takes them up instead of stamping
  /// its defaults over them. Only fields still at their defaults are
  /// filled: a choice made on the row before it was keyed is newer. Call
  /// before [saveSubscription].
  Future<void> restoreSubscriptionChoices(Subscription sub) async {
    final key = sub.podcastKey;
    if (key == null) return;
    final state = await _isar.podcastUserStates.getByPodcastKey(key);
    if (state == null || state.subscribedHlc == 0) return;
    if (!sub.autoDownload) sub.autoDownload = state.autoDownload;
    sub.autoDownloadKeepCount ??= state.autoDownloadKeepCount;
  }

  /// Records that [sub] is gone from this device: it no longer subscribes.
  /// Must run inside [UserStateStore.write].
  Future<void> saveSubscriptionRemoved(
    Subscription sub,
    UserStateTxn txn,
  ) async {
    final key = sub.podcastKey;
    if (key == null) return;
    final state = await _isar.podcastUserStates.getByPodcastKey(key);
    if (state == null || !state.subscribed) return;
    state
      ..subscribed = false
      ..subscribedHlc = txn.stamp.packed;
    await _putState(state, txn);
  }

  /// Logs, in debug builds, when [sub]'s user fields differ from its state
  /// row.
  Future<void> compareSubscription(Subscription sub) async {
    if (!kDebugMode) return;
    final key = sub.podcastKey;
    if (key == null) return;
    final state = await _isar.podcastUserStates.getByPodcastKey(key);
    if (state == null || state.subscribedHlc == 0) return;
    // Compared in full; logged without the feed URL's credentials.
    if (describeSubscription(sub) == describeSubscriptionState(state)) return;
    // The redacted strings can be equal, so they are not compared again.
    _report(
      'subscription',
      sub.id,
      describeSubscription(sub, redact: true),
      describeSubscriptionState(state, redact: true),
    );
  }

  // -- View --

  /// The view preference of [podcastId], or null when none is set.
  Future<PodcastViewPreference?> view(int podcastId) async {
    final legacy = await _isar.podcastViewPreferences.getByPodcastId(podcastId);
    final state = await stateOf(podcastId);
    if (state == null || state.hasViewHlc == 0) return legacy;
    final current = viewFromState(state, podcastId);
    _compare('view', podcastId, describeView(legacy), describeView(current));
    return current;
  }

  /// Writes [pref] (null: deleted) as the view preference of [podcastId]:
  /// the old row, then the keyed state. Must run inside
  /// [UserStateStore.write].
  Future<void> saveView(
    int podcastId,
    PodcastViewPreference? pref,
    UserStateTxn txn,
  ) async {
    final legacy = await _isar.podcastViewPreferences.getByPodcastId(podcastId);
    if (pref == null) {
      if (legacy != null) await _isar.podcastViewPreferences.delete(legacy.id);
    } else {
      pref
        ..id = legacy?.id ?? Isar.autoIncrement
        ..podcastId = podcastId;
      await _isar.podcastViewPreferences.put(pref);
    }
    final state = await _stateForWrite(podcastId);
    if (state == null) return;
    applyView(state, pref, txn);
    await _putState(state, txn);
  }

  // -- Audio --

  /// The audio override of [podcastId], or null when none is set.
  Future<PodcastAudioPreference?> audio(int podcastId) async {
    final legacy = await _isar.podcastAudioPreferences.getByPodcastId(
      podcastId,
    );
    final state = await stateOf(podcastId);
    if (state == null || state.hasAudioHlc == 0) return legacy;
    final current = audioFromState(state, podcastId);
    _compare('audio', podcastId, describeAudio(legacy), describeAudio(current));
    return current;
  }

  /// Writes [pref] (null: removed) as the audio override of [podcastId].
  /// Must run inside [UserStateStore.write].
  Future<void> saveAudio(
    int podcastId,
    PodcastAudioPreference? pref,
    UserStateTxn txn,
  ) async {
    final legacy = await _isar.podcastAudioPreferences.getByPodcastId(
      podcastId,
    );
    if (pref == null) {
      if (legacy != null) await _isar.podcastAudioPreferences.delete(legacy.id);
    } else {
      pref
        ..id = legacy?.id ?? Isar.autoIncrement
        ..podcastId = podcastId;
      await _isar.podcastAudioPreferences.put(pref);
    }
    final state = await _stateForWrite(podcastId);
    if (state == null) return;
    applyAudio(state, pref, txn);
    await _putState(state, txn);
  }

  // -- Parental flags --

  /// The parental flags of [podcastId], or null when none are set.
  Future<PodcastParentalFlags?> parental(int podcastId) async {
    final legacy = await _legacyParental(podcastId);
    final state = await stateOf(podcastId);
    if (state == null || state.hasParentalHlc == 0) return legacy;
    final current = parentalFromState(state, podcastId);
    _compare(
      'parental',
      podcastId,
      describeParental(legacy),
      describeParental(current),
    );
    return current;
  }

  /// Writes [flags] (null: removed) as the parental flags of [podcastId].
  /// Must run inside [UserStateStore.write].
  Future<void> saveParental(
    int podcastId,
    PodcastParentalFlags? flags,
    UserStateTxn txn,
  ) async {
    final legacy = await _legacyParental(podcastId);
    if (flags == null) {
      await _isar.podcastParentalFlags
          .filter()
          .itunesIdEqualTo(podcastId)
          .deleteAll();
    } else {
      flags
        ..id = legacy?.id ?? Isar.autoIncrement
        ..itunesId = podcastId;
      await _isar.podcastParentalFlags.put(flags);
    }
    final state = await _stateForWrite(podcastId);
    if (state == null) return;
    applyParental(state, flags, txn);
    await _putState(state, txn);
  }

  // The column is named itunesId, but every caller stores Subscription.id.
  Future<PodcastParentalFlags?> _legacyParental(int podcastId) => _isar
      .podcastParentalFlags
      .filter()
      .itunesIdEqualTo(podcastId)
      .findFirst();

  // -- Play order per playlist and group --

  /// The play order of [playlistId] (or of [groupId] in it), or null when
  /// none is set.
  Future<String?> playOrder(
    int podcastId,
    String playlistId, {
    String? groupId,
  }) async {
    final legacy = await _legacyPlayOrder(podcastId, playlistId, groupId);
    final state = await stateOf(podcastId);
    final entry = state == null ? null : _entryOf(state, playlistId, groupId);
    if (entry == null) return legacy;
    _compare(
      'play order $playlistId/${groupId ?? '-'}',
      podcastId,
      '$legacy',
      '${entry.order}',
    );
    return entry.order;
  }

  /// Writes [order] (null: cleared) as the play order of [playlistId] (or
  /// of [groupId] in it). Must run inside [UserStateStore.write].
  Future<void> savePlayOrder(
    int podcastId,
    String playlistId,
    String? groupId,
    String? order,
    UserStateTxn txn,
  ) async {
    await _writeLegacyPlayOrder(podcastId, playlistId, groupId, order);
    final state = await _stateForWrite(podcastId);
    if (state == null) return;
    applyPlayOrder(state, playlistId, groupId, order, txn);
    await _putState(state, txn);
  }

  Future<String?> _legacyPlayOrder(
    int podcastId,
    String playlistId,
    String? groupId,
  ) async {
    if (groupId == null) {
      final row = await _isar.smartPlaylistUserPreferences
          .getByPodcastIdPlaylistId(podcastId, playlistId);
      return row?.autoPlayOrder;
    }
    final row = await _isar.smartPlaylistGroupUserPreferences
        .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
    return row?.autoPlayOrder;
  }

  Future<void> _writeLegacyPlayOrder(
    int podcastId,
    String playlistId,
    String? groupId,
    String? order,
  ) async {
    if (groupId == null) {
      if (order == null) {
        await _isar.smartPlaylistUserPreferences.deleteByPodcastIdPlaylistId(
          podcastId,
          playlistId,
        );
        return;
      }
      final row =
          await _isar.smartPlaylistUserPreferences.getByPodcastIdPlaylistId(
            podcastId,
            playlistId,
          ) ??
          (SmartPlaylistUserPreference()
            ..podcastId = podcastId
            ..playlistId = playlistId);
      await _isar.smartPlaylistUserPreferences.put(row..autoPlayOrder = order);
      return;
    }
    if (order == null) {
      await _isar.smartPlaylistGroupUserPreferences
          .deleteByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
      return;
    }
    final row =
        await _isar.smartPlaylistGroupUserPreferences
            .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId) ??
        (SmartPlaylistGroupUserPreference()
          ..podcastId = podcastId
          ..playlistId = playlistId
          ..groupId = groupId);
    await _isar.smartPlaylistGroupUserPreferences.put(
      row..autoPlayOrder = order,
    );
  }

  // -- Copy of the old rows --

  /// Copies the old preference rows of [sub] into its state row, section by
  /// section, skipping sections the state row already has. Idempotent; must
  /// run inside [UserStateStore.write].
  ///
  /// Runs for existing data at launch (the backfill migration) and for a
  /// podcast the moment it gets its key.
  Future<void> copyLegacy(Subscription sub, UserStateTxn txn) async {
    final key = sub.podcastKey;
    if (key == null) return;
    final existing = await _isar.podcastUserStates.getByPodcastKey(key);
    final state = existing ?? (PodcastUserState()..podcastKey = key);
    var changed = false;

    if (state.subscribedHlc == 0) {
      changed = applySubscription(state, sub, txn) || changed;
    }
    if (state.hasViewHlc == 0) {
      final view = await _isar.podcastViewPreferences.getByPodcastId(sub.id);
      if (view != null) {
        applyView(state, view, txn);
        changed = true;
      }
    }
    if (state.hasAudioHlc == 0) {
      final audio = await _isar.podcastAudioPreferences.getByPodcastId(sub.id);
      if (audio != null) {
        applyAudio(state, audio, txn);
        changed = true;
      }
    }
    if (state.hasParentalHlc == 0) {
      final flags = await _legacyParental(sub.id);
      if (flags != null) {
        applyParental(state, flags, txn);
        changed = true;
      }
    }
    final playlists = await _isar.smartPlaylistUserPreferences
        .filter()
        .podcastIdEqualTo(sub.id)
        .findAll();
    for (final row in playlists) {
      if (_entryOf(state, row.playlistId, null) != null) continue;
      applyPlayOrder(state, row.playlistId, null, row.autoPlayOrder, txn);
      changed = true;
    }
    final groups = await _isar.smartPlaylistGroupUserPreferences
        .filter()
        .podcastIdEqualTo(sub.id)
        .findAll();
    for (final row in groups) {
      if (_entryOf(state, row.playlistId, row.groupId) != null) continue;
      applyPlayOrder(
        state,
        row.playlistId,
        row.groupId,
        row.autoPlayOrder,
        txn,
      );
      changed = true;
    }

    if (changed) await _putState(state, txn);
  }

  void _compare(String section, int podcastId, String legacy, String current) {
    if (legacy == current) return;
    _report(section, podcastId, legacy, current);
  }

  void _report(String section, int podcastId, String legacy, String current) {
    if (!kDebugMode) return;
    _logger.w(
      'PodcastUserState $section differs for podcast $podcastId: '
      'old $legacy, new $current',
    );
  }

  /// Puts [state] and reports it, with its play orders, for ops.
  Future<void> _putState(PodcastUserState state, UserStateTxn txn) async {
    await _isar.podcastUserStates.put(state);
    txn.touch(UserStateEntities.podcast, state);
    for (final entry in state.playOrders) {
      txn.touch(UserStateEntities.playOrder, (
        podcastKey: state.podcastKey,
        entry: entry,
      ));
    }
  }
}

PlayOrderEntry? _entryOf(
  PodcastUserState state,
  String playlistId,
  String? groupId,
) {
  for (final entry in state.playOrders) {
    if (entry.playlistId == playlistId && entry.groupId == groupId) {
      return entry;
    }
  }
  return null;
}

/// Records the user fields of [sub] on [state], stamping what changed.
/// Returns whether anything changed.
bool applySubscription(
  PodcastUserState state,
  Subscription sub,
  UserStateTxn txn,
) {
  final stamp = txn.stamp.packed;
  var changed = false;
  final subscribed = !sub.isCached;
  if (state.subscribed != subscribed ||
      !_sameMoment(state.subscribedAt, sub.subscribedAt) ||
      state.subscribedHlc == 0) {
    state
      ..subscribed = subscribed
      ..subscribedAt = sub.subscribedAt
      ..subscribedHlc = stamp;
    changed = true;
  }
  if (state.feedUrl != sub.feedUrl) {
    state
      ..feedUrl = sub.feedUrl
      ..feedUrlHlc = stamp;
    changed = true;
  }
  if (state.itunesId != sub.itunesId) {
    state
      ..itunesId = sub.itunesId
      ..itunesIdHlc = stamp;
    changed = true;
  }
  if (state.autoDownload != sub.autoDownload) {
    state
      ..autoDownload = sub.autoDownload
      ..autoDownloadHlc = stamp;
    changed = true;
  }
  if (state.autoDownloadKeepCount != sub.autoDownloadKeepCount) {
    state
      ..autoDownloadKeepCount = sub.autoDownloadKeepCount
      ..autoDownloadKeepCountHlc = stamp;
    changed = true;
  }
  return changed;
}

// DateTime equality also compares isUtc, which a round trip can change.
bool _sameMoment(DateTime? a, DateTime? b) =>
    a == null ? b == null : (b != null && a.isAtSameMomentAs(b));

/// The user fields of [s] as one string. With [redact], the feed URL loses
/// its user info and query, where a private feed keeps its credentials.
String describeSubscription(Subscription s, {bool redact = false}) =>
    '${!s.isCached}|${s.subscribedAt.toUtc()}|'
    '${redact ? redactFeedUrl(s.feedUrl) : s.feedUrl}|${s.itunesId}|'
    '${s.autoDownload}|${s.autoDownloadKeepCount}';

/// [describeSubscription] for a state row.
String describeSubscriptionState(PodcastUserState s, {bool redact = false}) =>
    '${s.subscribed}|${s.subscribedAt?.toUtc()}|'
    '${redact ? redactFeedUrl(s.feedUrl) : s.feedUrl}|${s.itunesId}|'
    '${s.autoDownload}|${s.autoDownloadKeepCount}';

/// [url] without user info and query, for logs.
String? redactFeedUrl(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return '<unparsable>';
  final userInfo = uri.userInfo.isEmpty ? '' : '***@';
  final query = uri.hasQuery ? '?***' : '';
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://$userInfo${uri.host}$port${uri.path}$query';
}

/// The view preference [state] describes, or null when it has none.
PodcastViewPreference? viewFromState(PodcastUserState state, int podcastId) {
  if (!state.hasView) return null;
  return PodcastViewPreference()
    ..podcastId = podcastId
    ..viewMode = state.viewMode
    ..episodeFilter = state.episodeFilter
    ..episodeSortOrder = state.episodeSortOrder
    ..seasonSortField = state.seasonSortField
    ..seasonSortOrder = state.seasonSortOrder
    ..selectedPlaylistId = state.selectedPlaylistId
    ..autoPlayOrder = state.autoPlayOrder;
}

/// Records [pref] (null: deleted) on [state], stamping what changed.
void applyView(
  PodcastUserState state,
  PodcastViewPreference? pref,
  UserStateTxn txn,
) {
  final stamp = txn.stamp.packed;
  final exists = pref != null;
  if (state.hasView != exists || state.hasViewHlc == 0) {
    state
      ..hasView = exists
      ..hasViewHlc = stamp;
  }
  if (pref == null) return;
  if (state.viewMode != pref.viewMode) {
    state
      ..viewMode = pref.viewMode
      ..viewModeHlc = stamp;
  }
  if (state.episodeFilter != pref.episodeFilter) {
    state
      ..episodeFilter = pref.episodeFilter
      ..episodeFilterHlc = stamp;
  }
  if (state.episodeSortOrder != pref.episodeSortOrder) {
    state
      ..episodeSortOrder = pref.episodeSortOrder
      ..episodeSortOrderHlc = stamp;
  }
  if (state.seasonSortField != pref.seasonSortField) {
    state
      ..seasonSortField = pref.seasonSortField
      ..seasonSortFieldHlc = stamp;
  }
  if (state.seasonSortOrder != pref.seasonSortOrder) {
    state
      ..seasonSortOrder = pref.seasonSortOrder
      ..seasonSortOrderHlc = stamp;
  }
  if (state.selectedPlaylistId != pref.selectedPlaylistId) {
    state
      ..selectedPlaylistId = pref.selectedPlaylistId
      ..selectedPlaylistIdHlc = stamp;
  }
  if (state.autoPlayOrder != pref.autoPlayOrder) {
    state
      ..autoPlayOrder = pref.autoPlayOrder
      ..autoPlayOrderHlc = stamp;
  }
}

/// The audio override [state] describes, or null when it has none.
PodcastAudioPreference? audioFromState(PodcastUserState state, int podcastId) {
  if (!state.hasAudio) return null;
  return PodcastAudioPreference()
    ..podcastId = podcastId
    ..speed = state.speed
    ..skipSilence = state.skipSilence
    ..voiceBoost = state.voiceBoost;
}

/// Records [pref] (null: removed) on [state], stamping what changed.
void applyAudio(
  PodcastUserState state,
  PodcastAudioPreference? pref,
  UserStateTxn txn,
) {
  final stamp = txn.stamp.packed;
  final exists = pref != null;
  if (state.hasAudio != exists || state.hasAudioHlc == 0) {
    state
      ..hasAudio = exists
      ..hasAudioHlc = stamp;
  }
  if (pref == null) return;
  if (state.speed != pref.speed) {
    state
      ..speed = pref.speed
      ..speedHlc = stamp;
  }
  if (state.skipSilence != pref.skipSilence) {
    state
      ..skipSilence = pref.skipSilence
      ..skipSilenceHlc = stamp;
  }
  if (state.voiceBoost != pref.voiceBoost) {
    state
      ..voiceBoost = pref.voiceBoost
      ..voiceBoostHlc = stamp;
  }
}

/// The parental flags [state] describes, or null when it has none.
PodcastParentalFlags? parentalFromState(PodcastUserState state, int podcastId) {
  if (!state.hasParental) return null;
  return PodcastParentalFlags()
    ..itunesId = podcastId
    ..hideExplicitEpisodes = state.hideExplicitEpisodes;
}

/// Records [flags] (null: removed) on [state], stamping what changed.
void applyParental(
  PodcastUserState state,
  PodcastParentalFlags? flags,
  UserStateTxn txn,
) {
  final stamp = txn.stamp.packed;
  final exists = flags != null;
  if (state.hasParental != exists || state.hasParentalHlc == 0) {
    state
      ..hasParental = exists
      ..hasParentalHlc = stamp;
  }
  if (flags == null) return;
  if (state.hideExplicitEpisodes != flags.hideExplicitEpisodes) {
    state
      ..hideExplicitEpisodes = flags.hideExplicitEpisodes
      ..hideExplicitEpisodesHlc = stamp;
  }
}

/// Records [order] (null: cleared) as the play order of [playlistId], or
/// of [groupId] in it, on [state].
void applyPlayOrder(
  PodcastUserState state,
  String playlistId,
  String? groupId,
  String? order,
  UserStateTxn txn,
) {
  final existing = _entryOf(state, playlistId, groupId);
  if (existing != null && existing.order == order) return;
  // Isar hands back a fixed-length list, so the entries are rebuilt.
  final entries = [
    for (final e in state.playOrders)
      if (!identical(e, existing)) e,
    PlayOrderEntry()
      ..playlistId = playlistId
      ..groupId = groupId
      ..order = order
      ..hlc = txn.stamp.packed,
  ];
  state.playOrders = entries;
}

String describeView(PodcastViewPreference? p) => p == null
    ? 'none'
    : '${p.viewMode}|${p.episodeFilter}|${p.episodeSortOrder}|'
          '${p.seasonSortField}|${p.seasonSortOrder}|${p.selectedPlaylistId}|'
          '${p.autoPlayOrder}';

String describeAudio(PodcastAudioPreference? p) =>
    p == null ? 'none' : '${p.speed}|${p.skipSilence}|${p.voiceBoost}';

String describeParental(PodcastParentalFlags? p) =>
    p == null ? 'none' : '${p.hideExplicitEpisodes}';
