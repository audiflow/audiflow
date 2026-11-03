import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

const _url = 'https://example.com/a.mp3';

const _metadata = NowPlayingInfo(
  episodeUrl: _url,
  episodeTitle: 'Episode',
  podcastTitle: 'Podcast',
  feedUrl: 'https://example.com/feed.xml',
  episodeGuid: 'guid-1',
);

/// Stands in for just_audio around a failed load: the test drives what the
/// engine reports, because a failed load leaves it idle with `playing`
/// unchanged, and a play() in that state only flips `playing` to true.
class _FailingAudioPlayer extends AudioPlayer {
  _FailingAudioPlayer() : super(handleInterruptions: false);

  final _states = StreamController<PlayerState>.broadcast();
  final _errors = StreamController<PlayerException>.broadcast();

  Object? loadError;
  int loadCalls = 0;
  Duration currentPosition = Duration.zero;
  bool _playing = false;
  ProcessingState _processing = ProcessingState.idle;

  void report(ProcessingState processing, {bool? playing}) {
    _processing = processing;
    _playing = playing ?? _playing;
    _states.add(PlayerState(_playing, _processing));
  }

  void reportError() =>
      _errors.add(PlayerException(-1003, 'host not found', 0));

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  Stream<PlayerException> get errorStream => _errors.stream;

  // Listen sessions under two seconds are dropped, so tests move this to
  // make one count.
  @override
  Duration get position => currentPosition;

  @override
  bool get playing => _playing;

  @override
  ProcessingState get processingState => _processing;

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    loadCalls++;
    final error = loadError;
    if (error != null) throw error;
    _processing = ProcessingState.ready;
    return const Duration(minutes: 10);
  }

  @override
  Future<void> play() async => report(_processing, playing: true);

  @override
  Future<void> pause() async => report(_processing, playing: false);

  @override
  Future<void> dispose() async {
    await _states.close();
    await _errors.close();
    await super.dispose();
  }
}

/// Knows no episodes, so play() skips history and download lookups.
class _EmptyEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FailingAudioPlayer player;
  late FakeAnalyticsService analytics;
  late ProviderContainer container;

  setUp(() {
    player = _FailingAudioPlayer();
    analytics = FakeAnalyticsService();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(analytics),
        episodeRepositoryProvider.overrideWithValue(_EmptyEpisodeRepository()),
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

  PlaybackState state() => container.read(audioPlayerControllerProvider);

  Future<void> failLoad() async {
    player.loadError = PlayerException(-1003, 'host not found', 0);
    await controller().play(_url, metadata: _metadata);
    await pumpEventQueue();
  }

  Iterable<AnalyticsEvent> listenSessions() =>
      analytics.events.whereType<EpisodeListenSession>();

  group('after a failed load', () {
    test('the idle report does not replace the error', () async {
      await failLoad();

      player.report(ProcessingState.idle);
      await pumpEventQueue();

      check(state()).isA<PlaybackError>();
    });

    test(
      'an engine left playing is stopped, so it does not read as playing',
      () async {
        // Switching from a playing episode keeps `playing` true across setUrl.
        player.report(ProcessingState.ready, playing: true);
        await failLoad();

        check(player.playing).isFalse();
        check(state()).isA<PlaybackError>();
      },
    );

    test('tapping play loads the episode again', () async {
      await failLoad();
      final failedLoads = player.loadCalls;

      player.loadError = null;
      await controller().togglePlayPause(_url);
      await pumpEventQueue();

      check(player.loadCalls).equals(failedLoads + 1);
      check(player.playing).isTrue();
    });

    test('a retry that fails again shows the error again', () async {
      await failLoad();

      await controller().togglePlayPause(_url);
      await pumpEventQueue();

      check(state()).isA<PlaybackError>();
    });

    test('an automatic resume does not retry on its own', () async {
      await failLoad();
      final failedLoads = player.loadCalls;

      await controller().resumeAutomatically();
      await pumpEventQueue();

      check(player.loadCalls).equals(failedLoads);
      check(state()).isA<PlaybackError>();
    });

    test('no listen session opens', () async {
      await failLoad();

      player.report(ProcessingState.idle, playing: true);
      await pumpEventQueue();
      player.currentPosition = const Duration(seconds: 30);
      player.report(ProcessingState.idle, playing: false);
      await pumpEventQueue();

      check(listenSessions()).isEmpty();
    });
  });

  group('idle with an episode set', () {
    test('never reads as playing', () async {
      await controller().play(_url, metadata: _metadata);
      await pumpEventQueue();

      player.report(ProcessingState.idle, playing: true);
      await pumpEventQueue();

      check(state()).isA<PlaybackPaused>();
    });
  });

  group('a failure during playback', () {
    test('shows as an error and ends the listen session', () async {
      await controller().play(_url, metadata: _metadata);
      await pumpEventQueue();
      player.report(ProcessingState.ready, playing: true);
      await pumpEventQueue();

      player.currentPosition = const Duration(seconds: 30);
      player.reportError();
      await pumpEventQueue();

      check(state()).isA<PlaybackError>();
      check(player.playing).isFalse();
      check(listenSessions().length).equals(1);
    });

    test('reported while a new load runs is left to that load', () async {
      await controller().play(_url, metadata: _metadata);
      await pumpEventQueue();

      final load = controller().play(
        'https://example.com/b.mp3',
        metadata: _metadata,
      );
      player.reportError();
      await load;
      await pumpEventQueue();

      check(state()).not((it) => it.isA<PlaybackError>());
    });

    test('a load that plays clears the error', () async {
      await failLoad();

      player.loadError = null;
      await controller().play(_url, metadata: _metadata);
      await pumpEventQueue();
      player.report(ProcessingState.ready, playing: true);
      await pumpEventQueue();

      check(state()).isA<PlaybackPlaying>();
    });
  });
}
