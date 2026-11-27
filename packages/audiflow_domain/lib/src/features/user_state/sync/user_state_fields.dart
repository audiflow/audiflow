import '../../subscription/models/subscriptions.dart';
import '../models/episode_user_state.dart';
import '../models/podcast_user_state.dart';
import '../models/queue_entry.dart';
import '../models/station_state.dart';
import '../models/synced_setting.dart';

/// One synced field: its wire id, how to read its value, and the [Hlc]
/// that orders its changes.
///
/// A fieldId is never reused, not even after the field is retired; the
/// registry test pins every id.
class FieldSpec<T> {
  const FieldSpec(
    this.id,
    this.name,
    this.value, {
    required this.set,
    this.hlc,
    this.setHlc,
    this.growOnly = false,
  });

  final int id;
  final String name;

  /// The value: null, int, double, bool, String, or DateTime.
  final Object? Function(T row) value;

  /// The field's packed HLC. Null for a field that never changes once the
  /// row exists (or, for counters, only grows); it is sent with every
  /// change of the row.
  final int Function(T row)? hlc;

  /// Stores a decoded value. Throws [TypeError] when the value does not fit
  /// the field, which a merge treats as a damaged input.
  final void Function(T row, Object? value) set;

  /// Stores the field's HLC; null exactly when [hlc] is.
  final void Function(T row, int hlc)? setHlc;

  /// A per-device counter that only grows, merged by maximum.
  final bool growOnly;
}

// The assignment's target type picks T, so one helper casts every field.
T _as<T>(Object? value) => value as T;

/// A kind of synced row: its wire name, the key every device names a row
/// by, and its fields.
class EntitySpec<T> {
  const EntitySpec(this.name, this.key, this.fields);

  /// Stable wire name; never renamed.
  final String name;
  final String Function(T row) key;
  final List<FieldSpec<T>> fields;

  FieldSpec<T>? field(int id) {
    for (final f in fields) {
      if (f.id == id) return f;
    }
    return null;
  }
}

/// A key made of several parts, unambiguous whatever the parts contain:
/// each is length-prefixed, and null is written as `~`, distinct from an
/// empty string (`0:`).
String compositeKey(List<String?> parts) =>
    parts.map((p) => p == null ? '~' : '${p.length}:$p').join('|');

/// The parts of a [compositeKey]. Throws [FormatException] when [key] is
/// not one made of [count] parts.
List<String?> splitCompositeKey(String key, int count) {
  final parts = <String?>[];
  var i = 0;
  while (i < key.length) {
    if (key[i] == '~') {
      parts.add(null);
      i += 1;
    } else {
      final colon = key.indexOf(':', i);
      final digits = colon < 0 ? '' : key.substring(i, colon);
      // Digits only: int.tryParse would also take a sign.
      final length = RegExp(r'^[0-9]+$').hasMatch(digits)
          ? int.parse(digits)
          : null;
      final end = length == null ? -1 : colon + 1 + length;
      if (length == null || key.length < end) {
        throw FormatException('not a composite key', key, i);
      }
      parts.add(key.substring(colon + 1, end));
      i = end;
    }
    if (i == key.length) break;
    if (key[i] != '|') throw FormatException('not a composite key', key, i);
    i += 1;
    if (i == key.length) throw FormatException('not a composite key', key, i);
  }
  if (parts.length != count) {
    throw FormatException('expected $count parts', key);
  }
  return parts;
}

/// A per-device counter entry of an episode.
typedef EpisodeCounterRow = ({String episodeKey, EpisodePlayCounters counters});

/// The play order of one smart playlist or group of a podcast.
typedef PlayOrderRow = ({String podcastKey, PlayOrderEntry entry});

/// Every synced entity. Adding one, or a field, means a new id; never
/// change or reuse an existing one.
abstract final class UserStateEntities {
  static final podcast =
      EntitySpec<PodcastUserState>('podcast', (r) => r.podcastKey, [
        FieldSpec(
          1,
          'subscribed',
          (r) => r.subscribed,
          set: (r, v) => r.subscribed = _as(v),
          hlc: (r) => r.subscribedHlc,
          setHlc: (r, h) => r.subscribedHlc = h,
        ),
        FieldSpec(
          2,
          'subscribedAt',
          (r) => r.subscribedAt,
          set: (r, v) => r.subscribedAt = _as(v),
          hlc: (r) => r.subscribedHlc,
          setHlc: (r, h) => r.subscribedHlc = h,
        ),
        FieldSpec(
          3,
          'feedUrl',
          (r) => r.feedUrl,
          set: (r, v) => r.feedUrl = _as(v),
          hlc: (r) => r.feedUrlHlc,
          setHlc: (r, h) => r.feedUrlHlc = h,
        ),
        FieldSpec(
          4,
          'itunesId',
          (r) => r.itunesId,
          set: (r, v) => r.itunesId = _as(v),
          hlc: (r) => r.itunesIdHlc,
          setHlc: (r, h) => r.itunesIdHlc = h,
        ),
        FieldSpec(
          5,
          'autoDownload',
          (r) => r.autoDownload,
          set: (r, v) => r.autoDownload = _as(v),
          hlc: (r) => r.autoDownloadHlc,
          setHlc: (r, h) => r.autoDownloadHlc = h,
        ),
        FieldSpec(
          6,
          'autoDownloadKeepCount',
          (r) => r.autoDownloadKeepCount,
          set: (r, v) => r.autoDownloadKeepCount = _as(v),
          hlc: (r) => r.autoDownloadKeepCountHlc,
          setHlc: (r, h) => r.autoDownloadKeepCountHlc = h,
        ),
        FieldSpec(
          7,
          'hasView',
          (r) => r.hasView,
          set: (r, v) => r.hasView = _as(v),
          hlc: (r) => r.hasViewHlc,
          setHlc: (r, h) => r.hasViewHlc = h,
        ),
        FieldSpec(
          8,
          'viewMode',
          (r) => r.viewMode,
          set: (r, v) => r.viewMode = _as(v),
          hlc: (r) => r.viewModeHlc,
          setHlc: (r, h) => r.viewModeHlc = h,
        ),
        FieldSpec(
          9,
          'episodeFilter',
          (r) => r.episodeFilter,
          set: (r, v) => r.episodeFilter = _as(v),
          hlc: (r) => r.episodeFilterHlc,
          setHlc: (r, h) => r.episodeFilterHlc = h,
        ),
        FieldSpec(
          10,
          'episodeSortOrder',
          (r) => r.episodeSortOrder,
          set: (r, v) => r.episodeSortOrder = _as(v),
          hlc: (r) => r.episodeSortOrderHlc,
          setHlc: (r, h) => r.episodeSortOrderHlc = h,
        ),
        FieldSpec(
          11,
          'seasonSortField',
          (r) => r.seasonSortField,
          set: (r, v) => r.seasonSortField = _as(v),
          hlc: (r) => r.seasonSortFieldHlc,
          setHlc: (r, h) => r.seasonSortFieldHlc = h,
        ),
        FieldSpec(
          12,
          'seasonSortOrder',
          (r) => r.seasonSortOrder,
          set: (r, v) => r.seasonSortOrder = _as(v),
          hlc: (r) => r.seasonSortOrderHlc,
          setHlc: (r, h) => r.seasonSortOrderHlc = h,
        ),
        FieldSpec(
          13,
          'selectedPlaylistId',
          (r) => r.selectedPlaylistId,
          set: (r, v) => r.selectedPlaylistId = _as(v),
          hlc: (r) => r.selectedPlaylistIdHlc,
          setHlc: (r, h) => r.selectedPlaylistIdHlc = h,
        ),
        FieldSpec(
          14,
          'autoPlayOrder',
          (r) => r.autoPlayOrder,
          set: (r, v) => r.autoPlayOrder = _as(v),
          hlc: (r) => r.autoPlayOrderHlc,
          setHlc: (r, h) => r.autoPlayOrderHlc = h,
        ),
        FieldSpec(
          15,
          'hasAudio',
          (r) => r.hasAudio,
          set: (r, v) => r.hasAudio = _as(v),
          hlc: (r) => r.hasAudioHlc,
          setHlc: (r, h) => r.hasAudioHlc = h,
        ),
        FieldSpec(
          16,
          'speed',
          (r) => r.speed,
          set: (r, v) => r.speed = _as(v),
          hlc: (r) => r.speedHlc,
          setHlc: (r, h) => r.speedHlc = h,
        ),
        FieldSpec(
          17,
          'skipSilence',
          (r) => r.skipSilence,
          set: (r, v) => r.skipSilence = _as(v),
          hlc: (r) => r.skipSilenceHlc,
          setHlc: (r, h) => r.skipSilenceHlc = h,
        ),
        FieldSpec(
          18,
          'voiceBoost',
          (r) => r.voiceBoost,
          set: (r, v) => r.voiceBoost = _as(v),
          hlc: (r) => r.voiceBoostHlc,
          setHlc: (r, h) => r.voiceBoostHlc = h,
        ),
        FieldSpec(
          19,
          'hasParental',
          (r) => r.hasParental,
          set: (r, v) => r.hasParental = _as(v),
          hlc: (r) => r.hasParentalHlc,
          setHlc: (r, h) => r.hasParentalHlc = h,
        ),
        FieldSpec(
          20,
          'hideExplicitEpisodes',
          (r) => r.hideExplicitEpisodes,
          set: (r, v) => r.hideExplicitEpisodes = _as(v),
          hlc: (r) => r.hideExplicitEpisodesHlc,
          setHlc: (r, h) => r.hideExplicitEpisodesHlc = h,
        ),
      ]);

  static final playOrder = EntitySpec<PlayOrderRow>(
    'playOrder',
    (r) => compositeKey([r.podcastKey, r.entry.playlistId, r.entry.groupId]),
    [
      FieldSpec(
        1,
        'order',
        (r) => r.entry.order,
        set: (r, v) => r.entry.order = _as(v),
        hlc: (r) => r.entry.hlc,
        setHlc: (r, h) => r.entry.hlc = h,
      ),
    ],
  );

  static final episode = EntitySpec<EpisodeUserState>(
    'episode',
    (r) => r.episodeKey,
    [
      FieldSpec(
        1,
        'podcastKey',
        (r) => r.podcastKey,
        set: (r, v) => r.podcastKey = _as(v),
      ),
      FieldSpec(
        2,
        'hasPlayback',
        (r) => r.hasPlayback,
        set: (r, v) => r.hasPlayback = _as(v),
        hlc: (r) => r.hasPlaybackHlc,
        setHlc: (r, h) => r.hasPlaybackHlc = h,
      ),
      FieldSpec(
        3,
        'positionMs',
        (r) => r.positionMs,
        set: (r, v) => r.positionMs = _as(v),
        hlc: (r) => r.positionHlc,
        setHlc: (r, h) => r.positionHlc = h,
      ),
      FieldSpec(
        4,
        'durationMs',
        (r) => r.durationMs,
        set: (r, v) => r.durationMs = _as(v),
        hlc: (r) => r.durationHlc,
        setHlc: (r, h) => r.durationHlc = h,
      ),
      FieldSpec(
        5,
        'completedAt',
        (r) => r.completedAt,
        set: (r, v) => r.completedAt = _as(v),
        hlc: (r) => r.completedAtHlc,
        setHlc: (r, h) => r.completedAtHlc = h,
      ),
      FieldSpec(
        6,
        'isReplaying',
        (r) => r.isReplaying,
        set: (r, v) => r.isReplaying = _as(v),
        hlc: (r) => r.replayHlc,
        setHlc: (r, h) => r.replayHlc = h,
      ),
      FieldSpec(
        7,
        'isReplayFromStart',
        (r) => r.isReplayFromStart,
        set: (r, v) => r.isReplayFromStart = _as(v),
        hlc: (r) => r.replayHlc,
        setHlc: (r, h) => r.replayHlc = h,
      ),
      FieldSpec(
        8,
        'firstPlayedAt',
        (r) => r.firstPlayedAt,
        set: (r, v) => r.firstPlayedAt = _as(v),
        hlc: (r) => r.firstPlayedAtHlc,
        setHlc: (r, h) => r.firstPlayedAtHlc = h,
      ),
      FieldSpec(
        9,
        'lastPlayedAt',
        (r) => r.lastPlayedAt,
        set: (r, v) => r.lastPlayedAt = _as(v),
        hlc: (r) => r.lastPlayedAtHlc,
        setHlc: (r, h) => r.lastPlayedAtHlc = h,
      ),
      FieldSpec(
        10,
        'favoritedAt',
        (r) => r.favoritedAt,
        set: (r, v) => r.favoritedAt = _as(v),
        hlc: (r) => r.favoritedAtHlc,
        setHlc: (r, h) => r.favoritedAtHlc = h,
      ),
      // The locator rides with every change, so a device that keys the
      // episode differently can still find it.
      FieldSpec(
        11,
        'locatorGuid',
        (r) => r.locatorGuid,
        set: (r, v) => r.locatorGuid = _as(v),
      ),
      FieldSpec(
        12,
        'locatorAudioUrl',
        (r) => r.locatorAudioUrl,
        set: (r, v) => r.locatorAudioUrl = _as(v),
      ),
      FieldSpec(
        13,
        'locatorPublishedAt',
        (r) => r.locatorPublishedAt,
        set: (r, v) => r.locatorPublishedAt = _as(v),
      ),
    ],
  );

  /// Grow-only, merged by maximum per device, so no HLC.
  static final episodeCounter = EntitySpec<EpisodeCounterRow>(
    'episodeCounter',
    (r) => compositeKey([r.episodeKey, r.counters.deviceId]),
    [
      FieldSpec(
        1,
        'playCount',
        (r) => r.counters.playCount,
        set: (r, v) => r.counters.playCount = _as(v),
        growOnly: true,
      ),
      FieldSpec(
        2,
        'completedCount',
        (r) => r.counters.completedCount,
        set: (r, v) => r.counters.completedCount = _as(v),
        growOnly: true,
      ),
      FieldSpec(
        3,
        'listenedMs',
        (r) => r.counters.listenedMs,
        set: (r, v) => r.counters.listenedMs = _as(v),
        growOnly: true,
      ),
      FieldSpec(
        4,
        'realtimeMs',
        (r) => r.counters.realtimeMs,
        set: (r, v) => r.counters.realtimeMs = _as(v),
        growOnly: true,
      ),
    ],
  );

  static final queueEntry =
      EntitySpec<QueueEntry>('queueEntry', (r) => r.entryId, [
        FieldSpec(
          1,
          'episodeKey',
          (r) => r.episodeKey,
          set: (r, v) => r.episodeKey = _as(v),
        ),
        FieldSpec(
          2,
          'rank',
          (r) => r.rank,
          set: (r, v) => r.rank = _as(v),
          hlc: (r) => r.rankHlc,
          setHlc: (r, h) => r.rankHlc = h,
        ),
        FieldSpec(
          3,
          'isAdhoc',
          (r) => r.isAdhoc,
          set: (r, v) => r.isAdhoc = _as(v),
          hlc: (r) => r.isAdhocHlc,
          setHlc: (r, h) => r.isAdhocHlc = h,
        ),
        FieldSpec(
          4,
          'sourceContext',
          (r) => r.sourceContext,
          set: (r, v) => r.sourceContext = _as(v),
          hlc: (r) => r.sourceContextHlc,
          setHlc: (r, h) => r.sourceContextHlc = h,
        ),
        FieldSpec(
          5,
          'addedAt',
          (r) => r.addedAt,
          set: (r, v) => r.addedAt = _as(v),
        ),
        FieldSpec(
          6,
          'deleted',
          (r) => r.deleted,
          set: (r, v) => r.deleted = _as(v),
          hlc: (r) => r.deletedHlc,
          setHlc: (r, h) => r.deletedHlc = h,
        ),
      ]);

  static final station =
      EntitySpec<StationState>('station', (r) => r.stationId, [
        FieldSpec(
          1,
          'name',
          (r) => r.name,
          set: (r, v) => r.name = _as(v),
          hlc: (r) => r.nameHlc,
          setHlc: (r, h) => r.nameHlc = h,
        ),
        FieldSpec(
          2,
          'sortOrder',
          (r) => r.sortOrder,
          set: (r, v) => r.sortOrder = _as(v),
          hlc: (r) => r.sortOrderHlc,
          setHlc: (r, h) => r.sortOrderHlc = h,
        ),
        FieldSpec(
          3,
          'episodeSortType',
          (r) => r.episodeSortType,
          set: (r, v) => r.episodeSortType = _as(v),
          hlc: (r) => r.episodeSortTypeHlc,
          setHlc: (r, h) => r.episodeSortTypeHlc = h,
        ),
        FieldSpec(
          4,
          'hideCompleted',
          (r) => r.hideCompleted,
          set: (r, v) => r.hideCompleted = _as(v),
          hlc: (r) => r.hideCompletedHlc,
          setHlc: (r, h) => r.hideCompletedHlc = h,
        ),
        FieldSpec(
          5,
          'filterDownloaded',
          (r) => r.filterDownloaded,
          set: (r, v) => r.filterDownloaded = _as(v),
          hlc: (r) => r.filterDownloadedHlc,
          setHlc: (r, h) => r.filterDownloadedHlc = h,
        ),
        FieldSpec(
          6,
          'filterFavorited',
          (r) => r.filterFavorited,
          set: (r, v) => r.filterFavorited = _as(v),
          hlc: (r) => r.filterFavoritedHlc,
          setHlc: (r, h) => r.filterFavoritedHlc = h,
        ),
        FieldSpec(
          7,
          'durationOperator',
          (r) => r.durationOperator,
          set: (r, v) => r.durationOperator = _as(v),
          hlc: (r) => r.durationFilterHlc,
          setHlc: (r, h) => r.durationFilterHlc = h,
        ),
        FieldSpec(
          8,
          'durationMinutes',
          (r) => r.durationMinutes,
          set: (r, v) => r.durationMinutes = _as(v),
          hlc: (r) => r.durationFilterHlc,
          setHlc: (r, h) => r.durationFilterHlc = h,
        ),
        FieldSpec(
          9,
          'publishedWithinDays',
          (r) => r.publishedWithinDays,
          set: (r, v) => r.publishedWithinDays = _as(v),
          hlc: (r) => r.publishedWithinDaysHlc,
          setHlc: (r, h) => r.publishedWithinDaysHlc = h,
        ),
        FieldSpec(
          10,
          'defaultEpisodeLimit',
          (r) => r.defaultEpisodeLimit,
          set: (r, v) => r.defaultEpisodeLimit = _as(v),
          hlc: (r) => r.defaultEpisodeLimitHlc,
          setHlc: (r, h) => r.defaultEpisodeLimitHlc = h,
        ),
        FieldSpec(
          11,
          'groupByPodcast',
          (r) => r.groupByPodcast,
          set: (r, v) => r.groupByPodcast = _as(v),
          hlc: (r) => r.groupByPodcastHlc,
          setHlc: (r, h) => r.groupByPodcastHlc = h,
        ),
        FieldSpec(
          12,
          'podcastSortType',
          (r) => r.podcastSortType,
          set: (r, v) => r.podcastSortType = _as(v),
          hlc: (r) => r.podcastSortTypeHlc,
          setHlc: (r, h) => r.podcastSortTypeHlc = h,
        ),
        FieldSpec(
          13,
          'lastPlayedAt',
          (r) => r.lastPlayedAt,
          set: (r, v) => r.lastPlayedAt = _as(v),
          hlc: (r) => r.lastPlayedAtHlc,
          setHlc: (r, h) => r.lastPlayedAtHlc = h,
        ),
        FieldSpec(
          14,
          'createdAt',
          (r) => r.createdAt,
          set: (r, v) => r.createdAt = _as(v),
        ),
        FieldSpec(
          15,
          'deleted',
          (r) => r.deleted,
          set: (r, v) => r.deleted = _as(v),
          hlc: (r) => r.deletedHlc,
          setHlc: (r, h) => r.deletedHlc = h,
        ),
      ]);

  static final stationMember = EntitySpec<StationMember>(
    'stationMember',
    (r) => compositeKey([r.stationId, r.podcastKey]),
    [
      FieldSpec(
        1,
        'episodeLimit',
        (r) => r.episodeLimit,
        set: (r, v) => r.episodeLimit = _as(v),
        hlc: (r) => r.episodeLimitHlc,
        setHlc: (r, h) => r.episodeLimitHlc = h,
      ),
      FieldSpec(
        2,
        'sortOrder',
        (r) => r.sortOrder,
        set: (r, v) => r.sortOrder = _as(v),
        hlc: (r) => r.sortOrderHlc,
        setHlc: (r, h) => r.sortOrderHlc = h,
      ),
      FieldSpec(
        3,
        'addedAt',
        (r) => r.addedAt,
        set: (r, v) => r.addedAt = _as(v),
      ),
      FieldSpec(
        4,
        'deleted',
        (r) => r.deleted,
        set: (r, v) => r.deleted = _as(v),
        hlc: (r) => r.deletedHlc,
        setHlc: (r, h) => r.deletedHlc = h,
      ),
    ],
  );

  static final setting = EntitySpec<SyncedSetting>('setting', (r) => r.key, [
    FieldSpec(
      1,
      'value',
      (r) => r.value,
      set: (r, v) => r.value = _as(v),
      hlc: (r) => r.hlc,
      setHlc: (r, h) => r.hlc = h,
    ),
    FieldSpec(
      2,
      'present',
      (r) => r.present,
      set: (r, v) => r.present = _as(v),
      hlc: (r) => r.hlc,
      setHlc: (r, h) => r.hlc = h,
    ),
  ]);

  /// What a snapshot needs to show a podcast, and to recreate its
  /// subscription row, before its feed is fetched again. Catalog data, not
  /// user state: it has no clock and never produces ops.
  static final podcastInfo =
      EntitySpec<Subscription>('podcastInfo', (r) => r.podcastKey!, [
        FieldSpec(1, 'title', (r) => r.title, set: (r, v) => r.title = _as(v)),
        FieldSpec(
          2,
          'artistName',
          (r) => r.artistName,
          set: (r, v) => r.artistName = _as(v),
        ),
        FieldSpec(
          3,
          'artworkUrl',
          (r) => r.artworkUrl,
          set: (r, v) => r.artworkUrl = _as(v),
        ),
      ]);

  /// Field names by id, per entity name: what this app version knows.
  static final Map<String, Map<int, String>> registry = Map.fromEntries([
    _ids(podcast),
    _ids(playOrder),
    _ids(episode),
    _ids(episodeCounter),
    _ids(queueEntry),
    _ids(station),
    _ids(stationMember),
    _ids(setting),
    _ids(podcastInfo),
  ]);

  /// Every entity's fieldIds as declared, duplicates included, so a test
  /// can catch a reused id before [registry] folds it away.
  static final Map<String, List<int>> declaredIds = Map.fromEntries([
    _declared(podcast),
    _declared(playOrder),
    _declared(episode),
    _declared(episodeCounter),
    _declared(queueEntry),
    _declared(station),
    _declared(stationMember),
    _declared(setting),
    _declared(podcastInfo),
  ]);

  static MapEntry<String, List<int>> _declared<T>(EntitySpec<T> spec) =>
      MapEntry(spec.name, [for (final f in spec.fields) f.id]);

  static MapEntry<String, Map<int, String>> _ids<T>(EntitySpec<T> spec) =>
      MapEntry(spec.name, {for (final f in spec.fields) f.id: f.name});
}
