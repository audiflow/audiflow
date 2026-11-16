import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../station/models/station.dart';
import '../../station/models/station_podcast.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/station_state.dart';
import 'user_state_store.dart';

/// Keeps [StationState] and [StationMember] in step with the `Station` and
/// `StationPodcast` rows the app reads.
///
/// Every station write goes through this class in the same
/// [UserStateStore.write]. A member whose podcast has no stable key yet is
/// recorded once the podcast is keyed ([copyLegacy]).
class StationStateAccess {
  StationStateAccess(this._isar, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Uuid _uuid;

  /// Gives [stations] their ids, puts them, and records each on its state.
  /// Must run inside [UserStateStore.write].
  Future<void> saveStations(List<Station> stations, UserStateTxn txn) async {
    if (stations.isEmpty) return;
    for (final station in stations) {
      station.stationId ??= _uuid.v7();
    }
    await _isar.stations.putAll(stations);
    for (final station in stations) {
      final stationId = station.stationId!;
      final state =
          await _isar.stationStates.getByStationId(stationId) ??
          (StationState()
            ..stationId = stationId
            ..createdAt = station.createdAt);
      if (applyStation(state, station, txn)) {
        await _isar.stationStates.put(state);
      }
    }
  }

  /// Marks [station] and its members removed; the caller deletes the rows.
  /// Must run inside [UserStateStore.write].
  Future<void> removeStation(Station station, UserStateTxn txn) async {
    final stationId = station.stationId;
    if (stationId == null) return;
    final stamp = txn.stamp.packed;
    final state = await _isar.stationStates.getByStationId(stationId);
    if (state != null && !state.deleted) {
      await _isar.stationStates.put(
        state
          ..deleted = true
          ..deletedHlc = stamp,
      );
    }
    final members = await _isar.stationMembers
        .filter()
        .stationIdEqualTo(stationId)
        .deletedEqualTo(false)
        .findAll();
    for (final member in members) {
      member
        ..deleted = true
        ..deletedHlc = stamp;
    }
    await _isar.stationMembers.putAll(members);
  }

  /// Puts [links] and records each on its member. Must run inside
  /// [UserStateStore.write].
  Future<void> saveMembers(List<StationPodcast> links, UserStateTxn txn) async {
    if (links.isEmpty) return;
    await _isar.stationPodcasts.putAll(links);
    final keys = await _memberKeys(links);
    for (var i = 0; i < links.length; i++) {
      final key = keys[i];
      if (key == null) continue;
      final member =
          await _isar.stationMembers.getByStationIdPodcastKey(
            key.stationId,
            key.podcastKey,
          ) ??
          (StationMember()
            ..stationId = key.stationId
            ..podcastKey = key.podcastKey
            ..addedAt = links[i].addedAt);
      if (applyMember(member, links[i], txn)) {
        await _isar.stationMembers.put(member);
      }
    }
  }

  /// Marks the members of [links] removed; the caller deletes the rows.
  /// A member another remaining link still maps to (two subscriptions can
  /// share a podcast key) stays. Must run inside [UserStateStore.write].
  Future<void> removeMembers(
    List<StationPodcast> links,
    UserStateTxn txn,
  ) async {
    final stamp = txn.stamp.packed;
    final removed = {for (final l in links) l.id};
    final keys = await _memberKeys(links);
    for (var i = 0; i < links.length; i++) {
      final key = keys[i];
      if (key == null) continue;
      if (await _stillLinked(links[i].stationId, key.podcastKey, removed)) {
        continue;
      }
      final member = await _isar.stationMembers.getByStationIdPodcastKey(
        key.stationId,
        key.podcastKey,
      );
      if (member == null || member.deleted) continue;
      await _isar.stationMembers.put(
        member
          ..deleted = true
          ..deletedHlc = stamp,
      );
    }
  }

  /// Marks every member of [sub]'s podcast removed, before [sub]'s row is
  /// deleted and its key can no longer be looked up. Members another
  /// subscription with the same key still links to stay. Must run inside
  /// [UserStateStore.write].
  Future<void> removePodcast(Subscription sub, UserStateTxn txn) async {
    if (sub.podcastKey == null) return;
    final links = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(sub.id)
        .findAll();
    await removeMembers(links, txn);
  }

  Future<bool> _stillLinked(
    int localStationId,
    String podcastKey,
    Set<int> removed,
  ) async {
    final others = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(localStationId)
        .findAll();
    final remaining = [
      for (final l in others)
        if (!removed.contains(l.id)) l.podcastId,
    ];
    if (remaining.isEmpty) return false;
    final subs = await _isar.subscriptions.getAll(remaining);
    return subs.any((sub) => sub?.podcastKey == podcastKey);
  }

  /// Records the station links of [sub], now that it has a key.
  /// Idempotent; must run inside [UserStateStore.write].
  Future<void> copyLegacy(Subscription sub, UserStateTxn txn) async {
    if (sub.podcastKey == null) return;
    final links = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(sub.id)
        .findAll();
    await saveMembers(links, txn);
  }

  Future<List<({String stationId, String podcastKey})?>> _memberKeys(
    List<StationPodcast> links,
  ) async {
    final stations = await _isar.stations.getAll([
      for (final l in links) l.stationId,
    ]);
    final subs = await _isar.subscriptions.getAll([
      for (final l in links) l.podcastId,
    ]);
    final keys = <({String stationId, String podcastKey})?>[];
    for (var i = 0; i < links.length; i++) {
      final stationId = stations[i]?.stationId;
      final podcastKey = subs[i]?.podcastKey;
      keys.add(
        stationId == null || podcastKey == null
            ? null
            : (stationId: stationId, podcastKey: podcastKey),
      );
    }
    return keys;
  }
}

/// Assigns [next] through [assign] and stamps it when it differs from
/// [current]. Returns whether it changed.
bool _stamped<T>(T current, T next, void Function() assign) {
  if (current == next) return false;
  assign();
  return true;
}

/// Records [station] on [state], stamping what changed. Returns whether
/// anything changed.
bool applyStation(StationState state, Station station, UserStateTxn txn) {
  final stamp = txn.stamp.packed;
  final duration = station.durationFilter;
  final fresh = state.id == Isar.autoIncrement;
  final changes = [
    _stamped(state.name, station.name, () {
      state
        ..name = station.name
        ..nameHlc = stamp;
    }),
    _stamped(state.sortOrder, station.sortOrder, () {
      state
        ..sortOrder = station.sortOrder
        ..sortOrderHlc = stamp;
    }),
    _stamped(state.episodeSortType, station.episodeSortType, () {
      state
        ..episodeSortType = station.episodeSortType
        ..episodeSortTypeHlc = stamp;
    }),
    _stamped(state.hideCompleted, station.hideCompleted, () {
      state
        ..hideCompleted = station.hideCompleted
        ..hideCompletedHlc = stamp;
    }),
    _stamped(state.filterDownloaded, station.filterDownloaded, () {
      state
        ..filterDownloaded = station.filterDownloaded
        ..filterDownloadedHlc = stamp;
    }),
    _stamped(state.filterFavorited, station.filterFavorited, () {
      state
        ..filterFavorited = station.filterFavorited
        ..filterFavoritedHlc = stamp;
    }),
    _stamped(
      '${state.durationOperator}|${state.durationMinutes}',
      '${duration?.durationOperator}|${duration?.durationMinutes ?? 0}',
      () {
        state
          ..durationOperator = duration?.durationOperator
          ..durationMinutes = duration?.durationMinutes ?? 0
          ..durationFilterHlc = stamp;
      },
    ),
    _stamped(state.publishedWithinDays, station.publishedWithinDays, () {
      state
        ..publishedWithinDays = station.publishedWithinDays
        ..publishedWithinDaysHlc = stamp;
    }),
    _stamped(state.defaultEpisodeLimit, station.defaultEpisodeLimit, () {
      state
        ..defaultEpisodeLimit = station.defaultEpisodeLimit
        ..defaultEpisodeLimitHlc = stamp;
    }),
    _stamped(state.groupByPodcast, station.groupByPodcast, () {
      state
        ..groupByPodcast = station.groupByPodcast
        ..groupByPodcastHlc = stamp;
    }),
    _stamped(state.podcastSortType, station.podcastSortType, () {
      state
        ..podcastSortType = station.podcastSortType
        ..podcastSortTypeHlc = stamp;
    }),
    _stamped(
      state.lastPlayedAt?.microsecondsSinceEpoch,
      station.lastPlayedAt?.microsecondsSinceEpoch,
      () {
        state
          ..lastPlayedAt = station.lastPlayedAt
          ..lastPlayedAtHlc = stamp;
      },
    ),
    _stamped(state.deleted, false, () {
      state
        ..deleted = false
        ..deletedHlc = stamp;
    }),
  ];
  return fresh || changes.contains(true);
}

/// Records [link] on [member], stamping what changed. Returns whether
/// anything changed.
bool applyMember(StationMember member, StationPodcast link, UserStateTxn txn) {
  final stamp = txn.stamp.packed;
  final fresh = member.id == Isar.autoIncrement;
  final changes = [
    _stamped(member.episodeLimit, link.episodeLimit, () {
      member
        ..episodeLimit = link.episodeLimit
        ..episodeLimitHlc = stamp;
    }),
    _stamped(member.sortOrder, link.sortOrder, () {
      member
        ..sortOrder = link.sortOrder
        ..sortOrderHlc = stamp;
    }),
    _stamped(member.deleted, false, () {
      member
        ..deleted = false
        ..deletedHlc = stamp;
    }),
  ];
  return fresh || changes.contains(true);
}
