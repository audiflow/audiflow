import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory station storage for the station editor tests.
class FakeStationRepository implements StationRepository {
  final stations = <int, Station>{};
  int creates = 0;
  int _nextId = 1;

  @override
  Future<Station> create(Station station) async {
    if (StationLimitExceededException.maxStations <= stations.length) {
      throw const StationLimitExceededException();
    }
    creates++;
    station.id = _nextId++;
    stations[station.id] = station;
    return station;
  }

  @override
  Future<Station?> findById(int id) async => stations[id];

  /// When set, [watchAll] waits for it, to hold the list mid-load.
  Completer<void>? listGate;

  @override
  Stream<List<Station>> watchAll() async* {
    await listGate?.future;
    yield stations.values.toList();
  }

  @override
  Future<void> update(Station station) async => stations[station.id] = station;

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

  @override
  Future<List<StationPodcast>> getByStation(int stationId) async => [
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
