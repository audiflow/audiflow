import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

const _url = 'https://example.com/a.mp3';
const _otherUrl = 'https://example.com/b.mp3';
const _episodeId = 7;
const _otherEpisodeId = 8;
const _duration = Duration(minutes: 10);
const _position = Duration(minutes: 5);

/// Stands at [_position] with [_duration] loaded instead of playing audio.
class _StandingAudioPlayer extends AudioPlayer {
  _StandingAudioPlayer() : super(handleInterruptions: false);

  @override
  Duration? get duration => _duration;

  @override
  Duration get position => _position;

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async => duration;

  @override
  Future<void> play() async {}

  @override
  Future<void> stop() async {}

  /// Holds the next seek open until completed, then clears itself.
  Completer<void>? seekGate;

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    final gate = seekGate;
    seekGate = null;
    await gate?.future;
  }
}

class _KnownEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => Episode()
    ..id = audioUrl == _otherUrl ? _otherEpisodeId : _episodeId
    ..podcastId = 1
    ..guid = 'guid'
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

class _EmptyHistoryRepository implements PlaybackHistoryRepository {
  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

typedef _Seek = ({
  int episodeId,
  Duration from,
  Duration to,
  Duration duration,
});

typedef _Resume = ({int episodeId, Duration position, Duration duration});

/// Records the seeks and resumes reported to the history service.
class _RecordingHistoryService implements PlaybackHistoryService {
  final List<_Seek> seeks = [];
  final List<_Resume> resumes = [];
  bool failSeeks = false;

  @override
  Future<void> onListenerResumed(
    int episodeId, {
    required Duration position,
    required Duration duration,
  }) async {
    resumes.add((episodeId: episodeId, position: position, duration: duration));
  }

  @override
  void onPlaybackResumed() {}

  @override
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {}

  @override
  Future<void> onSeeked(
    int episodeId, {
    required Duration from,
    required Duration to,
    required Duration duration,
  }) async {
    if (failSeeks) throw StateError('write failed');
    seeks.add((episodeId: episodeId, from: from, to: to, duration: duration));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _StandingAudioPlayer player;
  late _RecordingHistoryService historyService;
  late ProviderContainer container;

  setUp(() {
    player = _StandingAudioPlayer();
    historyService = _RecordingHistoryService();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        episodeRepositoryProvider.overrideWithValue(_KnownEpisodeRepository()),
        downloadServiceProvider.overrideWithValue(_NoDownloadService()),
        playbackHistoryRepositoryProvider.overrideWithValue(
          _EmptyHistoryRepository(),
        ),
        playbackHistoryServiceProvider.overrideWithValue(historyService),
        audioPlayerProvider.overrideWith((ref) {
          ref.onDispose(player.dispose);
          return player;
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  // Full metadata spares play() the subscription lookup for analytics.
  Future<void> playEpisode([String url = _url]) => controller().play(
    url,
    metadata: NowPlayingInfo(
      episodeUrl: url,
      episodeTitle: 'Episode',
      podcastTitle: 'Podcast',
      feedUrl: 'https://example.com/feed.xml',
    ),
  );

  test('reports a listener seek with where it came from', () async {
    await playEpisode();

    await controller().seek(const Duration(minutes: 1));
    await pumpEventQueue();

    check(historyService.seeks).deepEquals([
      (
        episodeId: _episodeId,
        from: _position,
        to: const Duration(minutes: 1),
        duration: _duration,
      ),
    ]);
  });

  test('reports the clamped target', () async {
    await playEpisode();

    await controller().seek(const Duration(minutes: 12));
    await pumpEventQueue();

    check(historyService.seeks).length.equals(1);
    check(historyService.seeks.single.to).equals(_duration);
  });

  test('does not report automatic seeks', () async {
    await playEpisode();

    await controller().seekAutomatically(const Duration(minutes: 1));
    await pumpEventQueue();

    check(historyService.seeks).isEmpty();
  });

  test('does not report a seek with nothing loaded', () async {
    await controller().seek(const Duration(minutes: 1));
    await pumpEventQueue();

    check(historyService.seeks).isEmpty();
  });

  test('does not report a seek overtaken by another episode', () async {
    await playEpisode();
    final gate = player.seekGate = Completer<void>();

    final seek = controller().seek(const Duration(minutes: 1));
    await pumpEventQueue();
    await playEpisode(_otherUrl);
    gate.complete();
    await seek;
    await pumpEventQueue();

    check(historyService.seeks).isEmpty();
  });

  test('a failed history write does not fail the seek', () async {
    await playEpisode();
    historyService.failSeeks = true;

    await controller().seek(const Duration(minutes: 1));
    await pumpEventQueue();

    check(historyService.seeks).isEmpty();
  });

  group('resume', () {
    test('reports a listener resume with its position', () async {
      await playEpisode();

      await controller().resume();
      await pumpEventQueue();

      check(historyService.resumes).deepEquals([
        (episodeId: _episodeId, position: _position, duration: _duration),
      ]);
    });

    test('does not report an automatic resume', () async {
      await playEpisode();

      await controller().resumeAutomatically();
      await pumpEventQueue();

      check(historyService.resumes).isEmpty();
    });
  });
}
