import 'package:audiflow_app/features/station/presentation/controllers/station_detail_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository(this._episodes);

  final List<Episode> _episodes;
  final getByIdsCalls = <List<int>>[];

  @override
  Future<List<Episode>> getByIds(List<int> ids) async {
    getByIdsCalls.add(ids);
    return _episodes.where((e) => ids.contains(e.id)).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository(this._subscriptions);

  final List<Subscription> _subscriptions;
  final getByIdCalls = <int>[];

  @override
  Future<Subscription?> getById(int id) async {
    getByIdCalls.add(id);
    return _subscriptions.where((s) => s.id == id).firstOrNull;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Episode _episode(int id, int podcastId) => Episode()
  ..id = id
  ..podcastId = podcastId
  ..guid = 'guid-$id'
  ..title = 'Episode $id'
  ..audioUrl = 'https://example.com/$id.mp3';

StationEpisode _stationEpisode(int id, int episodeId) => StationEpisode()
  ..id = id
  ..stationId = 1
  ..episodeId = episodeId;

Subscription _subscription(int id) => Subscription()
  ..id = id
  ..itunesId = 'itunes-$id'
  ..feedUrl = 'https://example.com/$id.xml'
  ..title = 'Podcast $id'
  ..artistName = 'Artist'
  ..subscribedAt = DateTime(2026);

void main() {
  group('stationEpisodeRows', () {
    late _FakeEpisodeRepository episodeRepo;
    late _FakeSubscriptionRepository subscriptionRepo;

    ProviderContainer containerFor(List<StationEpisode> stationEpisodes) {
      final container = ProviderContainer(
        overrides: [
          stationEpisodesProvider.overrideWith(
            (ref, id) => Stream.value(stationEpisodes),
          ),
          episodeRepositoryProvider.overrideWithValue(episodeRepo),
          subscriptionRepositoryProvider.overrideWithValue(subscriptionRepo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    // Listen so the auto-dispose chain stays alive until the rows resolve.
    Future<List<StationEpisodeRow>> readRows(ProviderContainer container) {
      final sub = container.listen(stationEpisodeRowsProvider(1), (_, _) {});
      addTearDown(sub.close);
      return container.read(stationEpisodeRowsProvider(1).future);
    }

    setUp(() {
      episodeRepo = _FakeEpisodeRepository([
        _episode(10, 100),
        _episode(11, 100),
        _episode(12, 200),
      ]);
      subscriptionRepo = _FakeSubscriptionRepository([
        _subscription(100),
        _subscription(200),
      ]);
    });

    // Loading each row on its own let rows resolve while scrolling up, so a
    // placeholder grew to the real height above the viewport and the list
    // jumped.
    test('loads every episode in one query, in station order', () async {
      final container = containerFor([
        _stationEpisode(1, 12),
        _stationEpisode(2, 10),
        _stationEpisode(3, 11),
      ]);

      final rows = await readRows(container);

      check(episodeRepo.getByIdsCalls).deepEquals([
        [12, 10, 11],
      ]);
      check(rows.map((r) => r.episode.id).toList()).deepEquals([12, 10, 11]);
      check(
        rows.map((r) => r.stationEpisode.id).toList(),
      ).deepEquals([1, 2, 3]);
    });

    test('looks up each podcast once and attaches it to its rows', () async {
      final container = containerFor([
        _stationEpisode(1, 10),
        _stationEpisode(2, 11),
        _stationEpisode(3, 12),
      ]);

      final rows = await readRows(container);

      check(subscriptionRepo.getByIdCalls).unorderedEquals([100, 200]);
      check(
        rows.map((r) => r.subscription?.title).toList(),
      ).deepEquals(['Podcast 100', 'Podcast 100', 'Podcast 200']);
    });

    test('skips station entries whose episode no longer exists', () async {
      final container = containerFor([
        _stationEpisode(1, 10),
        _stationEpisode(2, 99),
      ]);

      final rows = await readRows(container);

      check(rows.map((r) => r.episode.id).toList()).deepEquals([10]);
    });
  });
}
