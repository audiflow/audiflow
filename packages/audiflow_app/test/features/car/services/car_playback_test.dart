import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/player_stubs.dart';

class _FakeEpisodeRepository extends Fake implements EpisodeRepository {
  Episode? episode;

  @override
  Future<Episode?> getById(int id) async => episode?.id == id ? episode : null;
}

class _FakeSubscriptionRepository extends Fake
    implements SubscriptionRepository {
  @override
  Future<Subscription?> getById(int id) async => null;
}

class _FakePlayOrderRepository extends Fake
    implements PlayOrderPreferenceRepository {
  @override
  Future<AutoPlayOrder> resolveForPodcast(int podcastId) async =>
      AutoPlayOrder.asDisplayed;
}

class _FakeStationRepository extends Fake implements StationRepository {
  final played = <int>[];

  @override
  Future<Station?> findById(int id) async => id == 3
      ? (Station()
          ..id = 3
          ..name = 'Mix'
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026))
      : null;

  @override
  Future<void> markPlayed(int id, {required DateTime at}) async =>
      played.add(id);
}

class _FakeInstallIdRepository extends Fake implements InstallIdRepository {
  @override
  Future<String> getOrCreate() async => 'install';
}

class _FakeAnalytics extends Fake implements AnalyticsService {
  final events = <AnalyticsEvent>[];

  @override
  Future<void> log(AnalyticsEvent event) async => events.add(event);
}

class _FakeQueueService extends Fake implements QueueService {
  final adhocCalls =
      <
        ({int start, String context, List<int>? siblings, AutoPlayOrder? order})
      >[];
  var cleared = 0;

  @override
  Future<void> createAdhocQueue({
    required int startingEpisodeId,
    required String sourceContext,
    List<int>? siblingEpisodeIds,
    AutoPlayOrder? effectiveOrder,
  }) async {
    adhocCalls.add((
      start: startingEpisodeId,
      context: sourceContext,
      siblings: siblingEpisodeIds,
      order: effectiveOrder,
    ));
  }

  @override
  Future<void> clearQueue() async => cleared++;
}

class _FakeCatalog extends Fake implements CarCatalog {
  final requested = <int>[];

  @override
  Future<List<int>> podcastEpisodeIds(int podcastId) async {
    requested.add(podcastId);
    return const [7, 6, 5];
  }

  @override
  Future<List<int>> stationEpisodeIds(int stationId) async =>
      stationId == 3 ? const [9, 6, 8] : const [];
}

class _RecordingPlayer extends StubAudioPlayerController {
  _RecordingPlayer() : super(const PlaybackState.idle());

  final urls = <String>[];

  @override
  void markPlaySource(PlaySource source) {}

  @override
  Future<void> play(
    String url, {
    NowPlayingInfo? metadata,
    Duration? startAt,
  }) async {
    urls.add(url);
  }
}

/// Hands a [Ref] to the code under test, which takes one like a provider.
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  group('nextCarSpeed', () {
    test('steps through every car speed and wraps', () {
      final visited = <double>[];
      var speed = carSpeeds.first;
      for (var i = 0; i < carSpeeds.length; i++) {
        speed = nextCarSpeed(speed);
        visited.add(speed);
      }
      check(visited).deepEquals([...carSpeeds.skip(1), carSpeeds.first]);
    });

    test('moves a speed between steps up to the next step', () {
      check(nextCarSpeed(1.3)).equals(1.5);
    });

    test('wraps a speed above the last step to the first', () {
      check(nextCarSpeed(PlaybackSpeedScale.max)).equals(carSpeeds.first);
    });

    test('moves a speed below the first step up to it', () {
      check(nextCarSpeed(PlaybackSpeedScale.min)).equals(carSpeeds.first);
    });

    test('only offers speeds on the shared grid', () {
      for (final speed in carSpeeds) {
        check(PlaybackSpeedScale.steps).contains(speed);
      }
    });
  });

  group('CarPlayback', () {
    late _FakeEpisodeRepository episodes;
    late _FakeQueueService queue;
    late _FakeCatalog catalog;
    late _RecordingPlayer player;
    late _FakeStationRepository stations;
    late _FakeAnalytics analytics;
    late CarPlayback playback;

    setUp(() {
      episodes = _FakeEpisodeRepository()
        ..episode = (Episode()
          ..id = 6
          ..podcastId = 2
          ..guid = 'g'
          ..title = 'Episode'
          ..audioUrl = 'https://example.com/6.mp3');
      queue = _FakeQueueService();
      catalog = _FakeCatalog();
      player = _RecordingPlayer();
      stations = _FakeStationRepository();
      analytics = _FakeAnalytics();
      final container = ProviderContainer(
        overrides: [
          episodeRepositoryProvider.overrideWithValue(episodes),
          subscriptionRepositoryProvider.overrideWithValue(
            _FakeSubscriptionRepository(),
          ),
          playOrderPreferenceRepositoryProvider.overrideWithValue(
            _FakePlayOrderRepository(),
          ),
          queueServiceProvider.overrideWithValue(queue),
          audioPlayerControllerProvider.overrideWith(() => player),
          stationRepositoryProvider.overrideWithValue(stations),
          installIdRepositoryProvider.overrideWithValue(
            _FakeInstallIdRepository(),
          ),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);
      playback = CarPlayback(
        container.read(_refProvider),
        catalog: () => catalog,
      );
    });

    test('a podcast row queues its list in the podcast play order', () async {
      check(await playback.playPodcastEpisode(6)).isTrue();

      check(catalog.requested).deepEquals([2]);
      check(queue.adhocCalls.single)
        ..has((c) => c.start, 'start').equals(6)
        ..has((c) => c.siblings, 'siblings').isNotNull().deepEquals([7, 6, 5])
        ..has((c) => c.order, 'order').equals(AutoPlayOrder.asDisplayed);
      check(queue.cleared).equals(0);
      check(player.urls).deepEquals(['https://example.com/6.mp3']);
    });

    test('a station row queues the station list as displayed', () async {
      check(await playback.playStationEpisode(3, 6)).isTrue();
      await pumpEventQueue();

      check(queue.adhocCalls.single)
        ..has((c) => c.start, 'start').equals(6)
        ..has((c) => c.context, 'context').equals('Mix')
        ..has((c) => c.siblings, 'siblings').isNotNull().deepEquals([9, 6, 8])
        ..has((c) => c.order, 'order').equals(AutoPlayOrder.asDisplayed);
      check(player.urls).deepEquals(['https://example.com/6.mp3']);
      // Moves the station up in the Library, as a play on the phone does.
      check(stations.played).deepEquals([3]);
      check(analytics.events.single).isA<StationPlayed>();
    });

    test('a station that is gone changes nothing', () async {
      check(await playback.playStationEpisode(4, 6)).isFalse();
      check(await playback.playStationEpisode(3, 99)).isFalse();
      await pumpEventQueue();

      check(queue.adhocCalls).isEmpty();
      check(player.urls).isEmpty();
      check(stations.played).isEmpty();
      check(analytics.events).isEmpty();
    });

    test('another row plays alone and clears the queue', () async {
      check(await playback.playEpisode(6)).isTrue();

      check(queue.cleared).equals(1);
      check(queue.adhocCalls).isEmpty();
      check(player.urls).deepEquals(['https://example.com/6.mp3']);
    });

    test('a missing episode changes nothing', () async {
      check(await playback.playPodcastEpisode(99)).isFalse();
      check(await playback.playEpisode(99)).isFalse();

      check(queue.adhocCalls).isEmpty();
      check(queue.cleared).equals(0);
      check(player.urls).isEmpty();
    });
  });
}
