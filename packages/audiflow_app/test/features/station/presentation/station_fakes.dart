import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory station storage for the station editor tests.
class FakeStationRepository implements StationRepository {
  final stations = <int, Station>{};
  int creates = 0;
  int _nextId = 1;

  /// When set, [create] throws it, as a failing database write would.
  Object? createError;

  @override
  Future<Station> create(Station station) async {
    if (createError case final error?) throw error;
    if (StationLimitExceededException.maxStations <= stations.length) {
      throw const StationLimitExceededException();
    }
    creates++;
    station.id = _nextId++;
    stations[station.id] = station;
    return station;
  }

  /// When set, [watchAll] waits for it, to hold the list mid-load.
  Completer<void>? listGate;

  @override
  Stream<List<Station>> watchAll() async* {
    await listGate?.future;
    yield stations.values.toList();
  }

  /// When set, [update] waits for it, to hold a save in flight.
  Completer<void>? updateGate;

  @override
  Future<void> update(Station station) async {
    await updateGate?.future;
    // Stores a copy so a later edit to the same object is not visible
    // until it is saved.
    stations[station.id] = _copy(station);
  }

  /// When set, [findById] waits for it, to hold a load mid-way.
  Completer<void>? findGate;

  @override
  Future<Station?> findById(int id) async {
    await findGate?.future;
    final stored = stations[id];
    return stored == null ? null : _copy(stored);
  }

  static Station _copy(Station s) => Station()
    ..id = s.id
    ..name = s.name
    ..sortOrder = s.sortOrder
    ..hideCompleted = s.hideCompleted
    ..filterDownloaded = s.filterDownloaded
    ..filterFavorited = s.filterFavorited
    ..durationFilter = s.durationFilter
    ..defaultEpisodeLimit = s.defaultEpisodeLimit
    ..episodeSort = s.episodeSort
    ..groupByPodcast = s.groupByPodcast
    ..podcastSort = s.podcastSort
    ..lastPlayedAt = s.lastPlayedAt
    ..createdAt = s.createdAt
    ..updatedAt = s.updatedAt;

  @override
  Future<void> delete(int id) async => stations.remove(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeStationPodcastRepository implements StationPodcastRepository {
  final links = <StationPodcast>[];

  List<int> podcastIdsOf(int stationId) => [
    for (final l in links)
      if (l.stationId == stationId) l.podcastId,
  ];

  /// When true, [getByStation] fails, as a broken read would.
  bool failReads = false;

  @override
  Future<List<StationPodcast>> getByStation(int stationId) async {
    if (failReads) throw Exception('read failed');
    return _linksOf(stationId);
  }

  List<StationPodcast> _linksOf(int stationId) => [
    for (final l in links)
      if (l.stationId == stationId) l,
  ];

  @override
  Future<void> add(
    int stationId,
    int podcastId, {
    int sortOrder = 0,
    int? episodeLimit,
  }) async {
    links.add(
      StationPodcast()
        ..stationId = stationId
        ..podcastId = podcastId
        ..addedAt = DateTime(2026)
        ..sortOrder = sortOrder
        ..episodeLimit = episodeLimit,
    );
  }

  @override
  Future<void> update(StationPodcast stationPodcast) async {}

  @override
  Future<void> remove(int stationId, int podcastId) async => links.removeWhere(
    (l) => l.stationId == stationId && l.podcastId == podcastId,
  );

  @override
  Future<void> removeAllForStation(int stationId) async =>
      links.removeWhere((l) => l.stationId == stationId);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeReconciler implements StationReconcilerService {
  final reconciled = <int>[];

  /// Rebuilds that have started; one finishes when [gate] completes.
  final started = <int>[];
  Completer<void>? gate;

  @override
  Future<void> onStationConfigChanged(int stationId) async {
    started.add(stationId);
    await gate?.future;
    reconciled.add(stationId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeStationEpisodeRepository implements StationEpisodeRepository {
  @override
  Future<void> removeAllForStation(int stationId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
