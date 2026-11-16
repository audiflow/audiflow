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
  const FieldSpec(this.id, this.name, this.value, {this.hlc});

  final int id;
  final String name;

  /// The value: null, int, double, bool, String, or DateTime.
  final Object? Function(T row) value;

  /// The field's packed HLC. Null for a field that never changes once the
  /// row exists (or, for counters, only grows); it is sent with every
  /// change of the row.
  final int Function(T row)? hlc;
}

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
          hlc: (r) => r.subscribedHlc,
        ),
        FieldSpec(
          2,
          'subscribedAt',
          (r) => r.subscribedAt,
          hlc: (r) => r.subscribedHlc,
        ),
        FieldSpec(3, 'feedUrl', (r) => r.feedUrl, hlc: (r) => r.feedUrlHlc),
        FieldSpec(4, 'itunesId', (r) => r.itunesId, hlc: (r) => r.itunesIdHlc),
        FieldSpec(
          5,
          'autoDownload',
          (r) => r.autoDownload,
          hlc: (r) => r.autoDownloadHlc,
        ),
        FieldSpec(
          6,
          'autoDownloadKeepCount',
          (r) => r.autoDownloadKeepCount,
          hlc: (r) => r.autoDownloadKeepCountHlc,
        ),
        FieldSpec(7, 'hasView', (r) => r.hasView, hlc: (r) => r.hasViewHlc),
        FieldSpec(8, 'viewMode', (r) => r.viewMode, hlc: (r) => r.viewModeHlc),
        FieldSpec(
          9,
          'episodeFilter',
          (r) => r.episodeFilter,
          hlc: (r) => r.episodeFilterHlc,
        ),
        FieldSpec(
          10,
          'episodeSortOrder',
          (r) => r.episodeSortOrder,
          hlc: (r) => r.episodeSortOrderHlc,
        ),
        FieldSpec(
          11,
          'seasonSortField',
          (r) => r.seasonSortField,
          hlc: (r) => r.seasonSortFieldHlc,
        ),
        FieldSpec(
          12,
          'seasonSortOrder',
          (r) => r.seasonSortOrder,
          hlc: (r) => r.seasonSortOrderHlc,
        ),
        FieldSpec(
          13,
          'selectedPlaylistId',
          (r) => r.selectedPlaylistId,
          hlc: (r) => r.selectedPlaylistIdHlc,
        ),
        FieldSpec(
          14,
          'autoPlayOrder',
          (r) => r.autoPlayOrder,
          hlc: (r) => r.autoPlayOrderHlc,
        ),
        FieldSpec(15, 'hasAudio', (r) => r.hasAudio, hlc: (r) => r.hasAudioHlc),
        FieldSpec(16, 'speed', (r) => r.speed, hlc: (r) => r.speedHlc),
        FieldSpec(
          17,
          'skipSilence',
          (r) => r.skipSilence,
          hlc: (r) => r.skipSilenceHlc,
        ),
        FieldSpec(
          18,
          'voiceBoost',
          (r) => r.voiceBoost,
          hlc: (r) => r.voiceBoostHlc,
        ),
        FieldSpec(
          19,
          'hasParental',
          (r) => r.hasParental,
          hlc: (r) => r.hasParentalHlc,
        ),
        FieldSpec(
          20,
          'hideExplicitEpisodes',
          (r) => r.hideExplicitEpisodes,
          hlc: (r) => r.hideExplicitEpisodesHlc,
        ),
      ]);

  static final playOrder = EntitySpec<PlayOrderRow>(
    'playOrder',
    (r) => '${r.podcastKey}|${r.entry.playlistId}|${r.entry.groupId ?? ''}',
    [FieldSpec(1, 'order', (r) => r.entry.order, hlc: (r) => r.entry.hlc)],
  );

  static final episode =
      EntitySpec<EpisodeUserState>('episode', (r) => r.episodeKey, [
        FieldSpec(1, 'podcastKey', (r) => r.podcastKey),
        FieldSpec(
          2,
          'hasPlayback',
          (r) => r.hasPlayback,
          hlc: (r) => r.hasPlaybackHlc,
        ),
        FieldSpec(
          3,
          'positionMs',
          (r) => r.positionMs,
          hlc: (r) => r.positionHlc,
        ),
        FieldSpec(
          4,
          'durationMs',
          (r) => r.durationMs,
          hlc: (r) => r.durationHlc,
        ),
        FieldSpec(
          5,
          'completedAt',
          (r) => r.completedAt,
          hlc: (r) => r.completedAtHlc,
        ),
        FieldSpec(
          6,
          'isReplaying',
          (r) => r.isReplaying,
          hlc: (r) => r.replayHlc,
        ),
        FieldSpec(
          7,
          'isReplayFromStart',
          (r) => r.isReplayFromStart,
          hlc: (r) => r.replayHlc,
        ),
        FieldSpec(
          8,
          'firstPlayedAt',
          (r) => r.firstPlayedAt,
          hlc: (r) => r.firstPlayedAtHlc,
        ),
        FieldSpec(
          9,
          'lastPlayedAt',
          (r) => r.lastPlayedAt,
          hlc: (r) => r.lastPlayedAtHlc,
        ),
        FieldSpec(
          10,
          'favoritedAt',
          (r) => r.favoritedAt,
          hlc: (r) => r.favoritedAtHlc,
        ),
      ]);

  /// Grow-only, merged by maximum per device, so no HLC.
  static final episodeCounter = EntitySpec<EpisodeCounterRow>(
    'episodeCounter',
    (r) => '${r.episodeKey}|${r.counters.deviceId}',
    [
      FieldSpec(1, 'playCount', (r) => r.counters.playCount),
      FieldSpec(2, 'completedCount', (r) => r.counters.completedCount),
      FieldSpec(3, 'listenedMs', (r) => r.counters.listenedMs),
      FieldSpec(4, 'realtimeMs', (r) => r.counters.realtimeMs),
    ],
  );

  static final queueEntry =
      EntitySpec<QueueEntry>('queueEntry', (r) => r.entryId, [
        FieldSpec(1, 'episodeKey', (r) => r.episodeKey),
        FieldSpec(2, 'rank', (r) => r.rank, hlc: (r) => r.rankHlc),
        FieldSpec(3, 'isAdhoc', (r) => r.isAdhoc, hlc: (r) => r.isAdhocHlc),
        FieldSpec(
          4,
          'sourceContext',
          (r) => r.sourceContext,
          hlc: (r) => r.sourceContextHlc,
        ),
        FieldSpec(5, 'addedAt', (r) => r.addedAt),
        FieldSpec(6, 'deleted', (r) => r.deleted, hlc: (r) => r.deletedHlc),
      ]);

  static final station = EntitySpec<StationState>(
    'station',
    (r) => r.stationId,
    [
      FieldSpec(1, 'name', (r) => r.name, hlc: (r) => r.nameHlc),
      FieldSpec(2, 'sortOrder', (r) => r.sortOrder, hlc: (r) => r.sortOrderHlc),
      FieldSpec(
        3,
        'episodeSortType',
        (r) => r.episodeSortType,
        hlc: (r) => r.episodeSortTypeHlc,
      ),
      FieldSpec(
        4,
        'hideCompleted',
        (r) => r.hideCompleted,
        hlc: (r) => r.hideCompletedHlc,
      ),
      FieldSpec(
        5,
        'filterDownloaded',
        (r) => r.filterDownloaded,
        hlc: (r) => r.filterDownloadedHlc,
      ),
      FieldSpec(
        6,
        'filterFavorited',
        (r) => r.filterFavorited,
        hlc: (r) => r.filterFavoritedHlc,
      ),
      FieldSpec(
        7,
        'durationOperator',
        (r) => r.durationOperator,
        hlc: (r) => r.durationFilterHlc,
      ),
      FieldSpec(
        8,
        'durationMinutes',
        (r) => r.durationMinutes,
        hlc: (r) => r.durationFilterHlc,
      ),
      FieldSpec(
        9,
        'publishedWithinDays',
        (r) => r.publishedWithinDays,
        hlc: (r) => r.publishedWithinDaysHlc,
      ),
      FieldSpec(
        10,
        'defaultEpisodeLimit',
        (r) => r.defaultEpisodeLimit,
        hlc: (r) => r.defaultEpisodeLimitHlc,
      ),
      FieldSpec(
        11,
        'groupByPodcast',
        (r) => r.groupByPodcast,
        hlc: (r) => r.groupByPodcastHlc,
      ),
      FieldSpec(
        12,
        'podcastSortType',
        (r) => r.podcastSortType,
        hlc: (r) => r.podcastSortTypeHlc,
      ),
      FieldSpec(
        13,
        'lastPlayedAt',
        (r) => r.lastPlayedAt,
        hlc: (r) => r.lastPlayedAtHlc,
      ),
      FieldSpec(14, 'createdAt', (r) => r.createdAt),
      FieldSpec(15, 'deleted', (r) => r.deleted, hlc: (r) => r.deletedHlc),
    ],
  );

  static final stationMember = EntitySpec<StationMember>(
    'stationMember',
    (r) => '${r.stationId}|${r.podcastKey}',
    [
      FieldSpec(
        1,
        'episodeLimit',
        (r) => r.episodeLimit,
        hlc: (r) => r.episodeLimitHlc,
      ),
      FieldSpec(2, 'sortOrder', (r) => r.sortOrder, hlc: (r) => r.sortOrderHlc),
      FieldSpec(3, 'addedAt', (r) => r.addedAt),
      FieldSpec(4, 'deleted', (r) => r.deleted, hlc: (r) => r.deletedHlc),
    ],
  );

  static final setting = EntitySpec<SyncedSetting>('setting', (r) => r.key, [
    FieldSpec(1, 'value', (r) => r.value, hlc: (r) => r.hlc),
    FieldSpec(2, 'present', (r) => r.present, hlc: (r) => r.hlc),
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
  ]);

  static MapEntry<String, Map<int, String>> _ids<T>(EntitySpec<T> spec) =>
      MapEntry(spec.name, {for (final f in spec.fields) f.id: f.name});
}
