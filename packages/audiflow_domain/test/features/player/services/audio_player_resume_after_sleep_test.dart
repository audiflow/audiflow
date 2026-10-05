import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_queue_service.dart';

const _url = 'https://example.com/a.mp3';
const _nextUrl = 'https://example.com/b.mp3';

/// Stands in for just_audio, including its rule that `playing` stays true
/// after the source completes until `pause()` or `stop()` is called, so
/// `play()` on a completed source does nothing.
class _CompletingAudioPlayer extends AudioPlayer {
  _CompletingAudioPlayer() : super(handleInterruptions: false);

  final StreamController<PlayerState> _states =
      StreamController<PlayerState>.broadcast();
  final List<String> loadedUrls = [];
  bool _playing = false;
  ProcessingState _processing = ProcessingState.idle;

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  bool get playing => _playing;

  @override
  ProcessingState get processingState => _processing;

  void _emit() => _states.add(PlayerState(_playing, _processing));

  void completeSource() {
    _processing = ProcessingState.completed;
    _emit();
  }

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    loadedUrls.add(url);
    _processing = ProcessingState.ready;
    return const Duration(minutes: 10);
  }

  @override
  Future<void> play() async {
    if (_playing) return;
    _playing = true;
    _emit();
  }

  @override
  Future<void> pause() async {
    if (!_playing) return;
    _playing = false;
    _emit();
  }

  int stopCalls = 0;

  @override
  Future<void> stop() async {
    stopCalls++;
    _playing = false;
    _processing = ProcessingState.idle;
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await super.dispose();
  }
}

/// Queue of [episodes]; [queueGate] holds `getQueue()` open so a test can
/// act while the completed-state handler is still looking at the queue.
class _ListQueueService extends FakeQueueService {
  _ListQueueService(this.episodes);

  final List<Episode> episodes;
  Completer<void>? queueGate;
  Completer<void>? popGate;
  int pops = 0;

  @override
  Future<PlaybackQueue> getQueue() async {
    await queueGate?.future;
    return PlaybackQueue(
      manualItems: [
        for (final (index, episode) in episodes.indexed)
          QueueItemWithEpisode(
            queueItem: QueueItem()
              ..episodeId = episode.id
              ..position = index,
            episode: episode,
          ),
      ],
    );
  }

  @override
  Future<Episode?> popNextEpisode() async {
    await popGate?.future;
    if (episodes.isEmpty) return null;
    pops++;
    return episodes.removeAt(0);
  }
}

/// Knows no episodes, so play() skips history and download lookups.
class _EmptyEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _EmptySubscriptionRepository implements SubscriptionRepository {
  @override
  Future<Subscription?> getById(int id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _QuietHistoryService implements PlaybackHistoryService {
  @override
  void onPlaybackResumed() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _thirdUrl = 'https://example.com/c.mp3';

Episode _episode(int id, String url) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = url
  ..title = url
  ..audioUrl = url;

void main() {
  late _CompletingAudioPlayer player;
  late _ListQueueService queue;
  late ProviderContainer container;

  setUp(() {
    player = _CompletingAudioPlayer();
    queue = _ListQueueService([_episode(2, _nextUrl), _episode(3, _thirdUrl)]);
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        episodeRepositoryProvider.overrideWithValue(_EmptyEpisodeRepository()),
        subscriptionRepositoryProvider.overrideWithValue(
          _EmptySubscriptionRepository(),
        ),
        queueServiceProvider.overrideWithValue(queue),
        playbackHistoryServiceProvider.overrideWithValue(
          _QuietHistoryService(),
        ),
        audioPlayerProvider.overrideWith((ref) {
          ref.onDispose(player.dispose);
          return player;
        }),
      ],
    );
  });

  tearDown(() => container.dispose());

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  /// Plays [_url] to its end with auto-advance suppressed, as an
  /// end-of-episode sleep timer does.
  Future<void> stopAtEpisodeEndBySleepTimer() async {
    await controller().play(_url);
    await pumpEventQueue();
    controller().suppressNextAutoAdvance();
    player.completeSource();
    await pumpEventQueue();
  }

  group('play after an end-of-episode sleep stop', () {
    test('the sleep stop itself does not advance the queue', () async {
      await stopAtEpisodeEndBySleepTimer();

      check(player.loadedUrls).deepEquals([_url]);
      check(
        container.read(audioPlayerControllerProvider),
      ).isA<PlaybackPaused>();
    });

    test('resume() starts the next queued episode', () async {
      await stopAtEpisodeEndBySleepTimer();

      await controller().resume();
      await pumpEventQueue();

      check(player.loadedUrls).deepEquals([_url, _nextUrl]);
      check(controller().currentUrl).equals(_nextUrl);
    });

    test('togglePlayPause() starts the next queued episode', () async {
      await stopAtEpisodeEndBySleepTimer();

      await controller().togglePlayPause(_url);
      await pumpEventQueue();

      check(player.loadedUrls).deepEquals([_url, _nextUrl]);
      check(controller().currentUrl).equals(_nextUrl);
    });
  });

  group('end-of-episode sleep stop with an empty queue', () {
    setUp(() => queue.episodes.clear());

    test('closes the player as a natural queue end does', () async {
      await stopAtEpisodeEndBySleepTimer();

      check(player.loadedUrls).deepEquals([_url]);
      check(controller().currentUrl).isNull();
      check(container.read(audioPlayerControllerProvider)).isA<PlaybackIdle>();
      check(container.read(nowPlayingControllerProvider)).isNull();
      // The finished source would otherwise keep reporting playing to the
      // lock screen after the player closed.
      check(player.stopCalls).equals(1);
    });
  });

  group('overlapping play after an end-of-episode sleep stop', () {
    test('a double tap advances the queue once', () async {
      await stopAtEpisodeEndBySleepTimer();

      await Future.wait([controller().resume(), controller().resume()]);
      await pumpEventQueue();

      check(queue.pops).equals(1);
      check(player.loadedUrls).deepEquals([_url, _nextUrl]);
    });

    test(
      'a tap while the stop reads the queue keeps the new episode',
      () async {
        queue.queueGate = Completer<void>();
        await controller().play(_url);
        await pumpEventQueue();
        controller().suppressNextAutoAdvance();
        player.completeSource();
        await pumpEventQueue();

        await controller().resume();
        queue.queueGate!.complete();
        await pumpEventQueue();

        check(queue.pops).equals(1);
        check(controller().currentUrl).equals(_nextUrl);
        check(
          container.read(audioPlayerControllerProvider),
        ).not((it) => it.isA<PlaybackPaused>());
      },
    );
  });

  group('natural completion', () {
    test('an episode picked while the queue is read keeps playing', () async {
      queue.episodes.clear();
      queue.popGate = Completer<void>();
      await controller().play(_url);
      await pumpEventQueue();
      player.completeSource();
      await pumpEventQueue();

      await controller().play(_thirdUrl);
      queue.popGate!.complete();
      await pumpEventQueue();

      check(controller().currentUrl).equals(_thirdUrl);
      check(player.stopCalls).equals(0);
    });
  });
}
