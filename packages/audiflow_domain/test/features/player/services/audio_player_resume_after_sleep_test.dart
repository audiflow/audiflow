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

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _states.close();
    await super.dispose();
  }
}

class _OneEpisodeQueueService extends FakeQueueService {
  _OneEpisodeQueueService(this._next);

  Episode? _next;

  @override
  Future<PlaybackQueue> getQueue() async {
    final next = _next;
    if (next == null) return const PlaybackQueue();
    return PlaybackQueue(
      manualItems: [
        QueueItemWithEpisode(
          queueItem: QueueItem()
            ..episodeId = next.id
            ..position = 0,
          episode: next,
        ),
      ],
    );
  }

  @override
  Future<Episode?> popNextEpisode() async {
    final next = _next;
    _next = null;
    return next;
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

Episode _nextEpisode() => Episode()
  ..id = 2
  ..podcastId = 1
  ..guid = 'b'
  ..title = 'Next'
  ..audioUrl = _nextUrl;

void main() {
  late _CompletingAudioPlayer player;
  late _OneEpisodeQueueService queue;
  late ProviderContainer container;

  setUp(() {
    player = _CompletingAudioPlayer();
    queue = _OneEpisodeQueueService(_nextEpisode());
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
    setUp(() => queue._next = null);

    test('closes the player as a natural queue end does', () async {
      await stopAtEpisodeEndBySleepTimer();

      check(player.loadedUrls).deepEquals([_url]);
      check(controller().currentUrl).isNull();
      check(container.read(audioPlayerControllerProvider)).isA<PlaybackIdle>();
      check(container.read(nowPlayingControllerProvider)).isNull();
    });
  });
}
