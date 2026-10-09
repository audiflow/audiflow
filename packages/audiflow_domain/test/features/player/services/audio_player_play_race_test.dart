import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

const _url = 'https://example.com/a.mp3';

/// Stands in for just_audio on a slow device: loads wait on [loadGate], a
/// new load or a stop interrupts the outstanding one as just_audio does,
/// [playError] makes `play()` fail the way an interrupted load does, and
/// [holdPlay] keeps the `play()` future open as playback does.
class _SlowAudioPlayer extends AudioPlayer {
  _SlowAudioPlayer() : super(handleInterruptions: false);

  final List<String> loadedUrls = [];
  Completer<void> loadGate = Completer<void>()..complete();
  Object? playError;
  Completer<void>? holdPlay;
  int playCalls = 0;
  int interruptedLoads = 0;
  Completer<void>? _outstandingLoad;

  void _interruptOutstandingLoad() {
    final load = _outstandingLoad;
    if (load == null || load.isCompleted) return;
    interruptedLoads++;
    load.completeError(PlayerInterruptedException('Loading interrupted'));
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
    _interruptOutstandingLoad();
    final load = Completer<void>();
    _outstandingLoad = load;
    unawaited(
      loadGate.future.then((_) {
        if (!load.isCompleted) load.complete();
      }),
    );
    await load.future;
    return const Duration(minutes: 10);
  }

  @override
  Future<void> stop() async => _interruptOutstandingLoad();

  @override
  Future<void> play() async {
    playCalls++;
    final error = playError;
    if (error != null) throw error;
    await holdPlay?.future;
  }
}

/// Knows no episodes, so play() skips history and download lookups.
class _EmptyEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Only resume() reaches the history service here.
class _QuietHistoryService implements PlaybackHistoryService {
  @override
  void onPlaybackResumed() {}

  @override
  Future<void> onListenerResumed(
    int episodeId, {
    required Duration position,
    required Duration duration,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _SlowAudioPlayer player;
  late ProviderContainer container;

  setUp(() {
    player = _SlowAudioPlayer();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        episodeRepositoryProvider.overrideWithValue(_EmptyEpisodeRepository()),
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

  group('play() on a slow device', () {
    test('a second play of the episode being loaded joins the load', () async {
      // A double tap during a long frame stall: both taps see nothing
      // loaded yet. A second setUrl would interrupt the first, and both
      // loads then fail with "Loading interrupted".
      player.loadGate = Completer<void>();
      final first = controller().play(_url);
      final second = controller().play(_url);
      await pumpEventQueue();
      player.loadGate.complete();
      await Future.wait([first, second]);

      check(player.loadedUrls).deepEquals([_url]);
      check(player.interruptedLoads).equals(0);
      check(player.playCalls).equals(1);
      check(
        container.read(audioPlayerControllerProvider),
      ).isA<PlaybackLoading>();
    });

    test('a play of another episode still starts its own load', () async {
      player.loadGate = Completer<void>();
      final first = controller().play(_url);
      final second = controller().play('https://example.com/b.mp3');
      await pumpEventQueue();
      player.loadGate.complete();
      await Future.wait([first, second]);

      check(player.loadedUrls).deepEquals([_url, 'https://example.com/b.mp3']);
      check(player.interruptedLoads).equals(1);
      // The interrupted first load must not report over the second.
      check(
        container.read(audioPlayerControllerProvider),
      ).isA<PlaybackLoading>();
    });

    test('a play after stop starts a new load of the same episode', () async {
      player.loadGate = Completer<void>();
      final first = controller().play(_url);
      await pumpEventQueue();
      // Replay before the stopped load has unwound: joining it would end
      // in the interruption the stop caused.
      final stopped = controller().stop();
      final second = controller().play(_url);
      await pumpEventQueue();
      player.loadGate.complete();
      await Future.wait([first, stopped, second]);

      check(player.loadedUrls).deepEquals([_url, _url]);
      // The replay survives both the stop and the stopped load's failure.
      check(controller().currentUrl).equals(_url);
      check(
        container.read(audioPlayerControllerProvider),
      ).isA<PlaybackLoading>();
    });

    test('a stale engine failure does not override a replay', () async {
      final firstPlayback = Completer<void>();
      player.holdPlay = firstPlayback;
      await controller().play(_url);
      player.holdPlay = null;
      await controller().stop();
      await controller().play(_url);
      firstPlayback.completeError(
        PlayerInterruptedException('Loading interrupted'),
      );
      await pumpEventQueue();

      check(
        container.read(audioPlayerControllerProvider),
      ).isA<PlaybackLoading>();
    });

    test('a failing engine play() is not an unhandled error', () async {
      player.playError = PlayerInterruptedException('Loading interrupted');
      await controller().play(_url);
      await pumpEventQueue();

      check(container.read(audioPlayerControllerProvider)).isA<PlaybackError>();
    });

    test('a failing engine play() on resume is not unhandled', () async {
      await controller().play(_url);
      player.playError = PlayerInterruptedException('Loading interrupted');
      await controller().resume();
      await pumpEventQueue();

      check(player.playCalls).equals(2);
      check(container.read(audioPlayerControllerProvider)).isA<PlaybackError>();
    });
  });
}
