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
  itunesId: '123',
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
  void Function()? onLoad;

  /// Stands in for a pause that does not take, leaving `playing` true.
  bool ignorePause = false;
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
    onLoad?.call();
    final error = loadError;
    if (error != null) throw error;
    _processing = ProcessingState.ready;
    return const Duration(minutes: 10);
  }

  @override
  Future<void> play() async => report(_processing, playing: true);

  @override
  Future<void> pause() async {
    if (!ignorePause) report(_processing, playing: false);
  }

  @override
  Future<void> stop() async {}

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

class _KnownEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => Episode()
    ..id = 1
    ..podcastId = 1
    ..guid = 'guid-1'
    ..title = 'Episode'
    ..audioUrl = audioUrl;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoDownloadService implements DownloadService {
  @override
  Future<String?> getLocalPath(int episodeId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RecordingHistoryService implements PlaybackHistoryService {
  int stops = 0;

  @override
  Future<void> onPlaybackStopped(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async => stops++;

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

/// Records saved positions, and runs [onLookup] during a load's setup, after
/// setUrl has succeeded.
class _RecordingHistoryRepository implements PlaybackHistoryRepository {
  final saved = <int>[];
  void Function()? onLookup;

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async {
    onLookup?.call();
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #saveProgress) {
      saved.add(invocation.namedArguments[#positionMs] as int);
    }
    return Future<void>.value();
  }
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

    test('an engine report of playing does not end the error', () async {
      await failLoad();

      player.report(ProcessingState.ready, playing: true);
      await pumpEventQueue();

      check(state()).isA<PlaybackError>();
    });

    test(
      'retrying works even when the engine still reads as playing',
      () async {
        player.report(ProcessingState.ready, playing: true);
        player.ignorePause = true;
        await failLoad();
        final failedLoads = player.loadCalls;

        player.loadError = null;
        await controller().togglePlayPause(_url);
        await pumpEventQueue();

        check(player.loadCalls).equals(failedLoads + 1);
      },
    );

    test('a retry reports the same podcast as the first attempt', () async {
      await failLoad();

      player.loadError = null;
      await controller().resume();
      await pumpEventQueue();

      final started = analytics.events.whereType<EpisodePlayStarted>();
      check(started.single.podcastId).equals('123');
    });

    test('interruption marks do not erase the error', () async {
      await failLoad();

      controller().markPausedByInterruption();
      check(state()).isA<PlaybackError>();
      controller().markPlayingByInterruption();
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
      final states = <PlaybackState>[];
      final subscription = container.listen(
        audioPlayerControllerProvider,
        (_, next) => states.add(next),
      );
      addTearDown(subscription.close);

      // Fired from inside setUrl, so the source guard is really up.
      player.onLoad = player.reportError;
      await controller().play('https://example.com/b.mp3', metadata: _metadata);
      await pumpEventQueue();

      check(states.whereType<PlaybackError>()).isEmpty();
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

  group('with a known episode', () {
    late ProviderContainer known;
    late _RecordingHistoryService history;
    late _RecordingHistoryRepository historyRepo;

    setUp(() {
      history = _RecordingHistoryService();
      historyRepo = _RecordingHistoryRepository();
      known = ProviderContainer(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            FakeAppSettingsRepository(),
          ),
          analyticsServiceProvider.overrideWithValue(analytics),
          episodeRepositoryProvider.overrideWithValue(
            _KnownEpisodeRepository(),
          ),
          downloadServiceProvider.overrideWithValue(_NoDownloadService()),
          playbackHistoryServiceProvider.overrideWithValue(history),
          playbackHistoryRepositoryProvider.overrideWithValue(historyRepo),
          audioPlayerProvider.overrideWith((ref) => player),
          playbackProgressProvider.overrideWith(
            (ref) => const PlaybackProgress(
              position: Duration.zero,
              duration: Duration(minutes: 10),
              bufferedPosition: Duration.zero,
            ),
          ),
        ],
      );
    });

    tearDown(() => known.dispose());

    AudioPlayerController knownController() =>
        known.read(audioPlayerControllerProvider.notifier);

    Future<void> failKnownLoad() async {
      player.loadError = PlayerException(-1003, 'host not found', 0);
      await knownController().play(_url, metadata: _metadata);
      await pumpEventQueue();
    }

    test('leaving a failed episode keeps its saved position', () async {
      await failKnownLoad();

      await knownController().stop();

      check(history.stops).equals(0);
    });

    test('a failure during setup does not start the engine', () async {
      historyRepo.onLookup = player.reportError;

      await knownController().play(_url, metadata: _metadata);
      await pumpEventQueue();

      check(known.read(audioPlayerControllerProvider)).isA<PlaybackError>();
      check(player.playing).isFalse();
    });

    test('a seek moves the saved position a retry resumes from', () async {
      await failKnownLoad();

      await knownController().seek(const Duration(seconds: 90));

      check(historyRepo.saved).deepEquals([90000]);
    });

    test('an automatic seek does not move it', () async {
      await failKnownLoad();

      await knownController().seekAutomatically(const Duration(seconds: 90));

      check(historyRepo.saved).isEmpty();
    });

    test('skip buttons do nothing', () async {
      await failKnownLoad();

      await knownController().skipForward();
      await knownController().skipBackward();

      check(historyRepo.saved).isEmpty();
    });
  });
}
