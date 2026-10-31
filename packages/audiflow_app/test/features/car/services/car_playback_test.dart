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

class _FakeQueueService extends Fake implements QueueService {
  final adhocCalls =
      <({int start, List<int>? siblings, AutoPlayOrder? order})>[];
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
