import 'package:audiflow_app/features/queue/services/queue_item_player.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/player_stubs.dart';

class _FakeQueueService extends Fake implements QueueService {
  _FakeQueueService(this.episode);

  final Episode? episode;

  @override
  Future<Episode?> skipToItem(int queueItemId) async => episode;
}

class _FakeSubscriptionRepository extends Fake
    implements SubscriptionRepository {
  @override
  Future<Subscription?> getById(int id) async => null;
}

class _RecordingPlayer extends StubAudioPlayerController {
  _RecordingPlayer() : super(const PlaybackState.idle());

  final sources = <PlaySource>[];
  final urls = <String>[];

  @override
  void markPlaySource(PlaySource source) => sources.add(source);

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
  late _RecordingPlayer player;

  ProviderContainer containerWith(Episode? episode) {
    player = _RecordingPlayer();
    final container = ProviderContainer(
      overrides: [
        queueServiceProvider.overrideWithValue(_FakeQueueService(episode)),
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(),
        ),
        audioPlayerControllerProvider.overrideWith(() => player),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Episode episode() => Episode()
    ..id = 1
    ..podcastId = 2
    ..guid = 'g'
    ..title = 'Episode'
    ..audioUrl = 'https://example.com/a.mp3';

  group('playQueueItem', () {
    test('reports the queue as the play source by default', () async {
      final container = containerWith(episode());

      final played = await playQueueItem(container.read(_refProvider), 5);

      check(played).isTrue();
      check(player.sources).deepEquals([PlaySource.queue]);
      check(player.urls).deepEquals(['https://example.com/a.mp3']);
    });

    test('reports the given play source', () async {
      final container = containerWith(episode());

      await playQueueItem(
        container.read(_refProvider),
        5,
        source: PlaySource.car,
      );

      check(player.sources).deepEquals([PlaySource.car]);
    });

    test('plays nothing when the item has left the queue', () async {
      final container = containerWith(null);

      final played = await playQueueItem(container.read(_refProvider), 5);

      check(played).isFalse();
      check(player.urls).isEmpty();
    });
  });
}
