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

/// Records the engine calls in order instead of playing audio.
///
/// [holdPause] keeps the engine pause open, as a slow platform call does.
class _RecordingAudioPlayer extends AudioPlayer {
  _RecordingAudioPlayer(this.calls) : super(handleInterruptions: false);

  final List<String> calls;
  Completer<void>? holdPause;
  bool _playing = false;

  @override
  Duration? get duration => const Duration(minutes: 10);

  @override
  bool get playing => _playing;

  @override
  Future<Duration?> setUrl(
    String url, {
    Map<String, String>? headers,
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async => duration;

  @override
  Future<void> play() async => _playing = true;

  @override
  Future<void> pause() async {
    _playing = false;
    calls.add('pause');
    await holdPause?.future;
  }

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> seek(Duration? position, {int? index}) async =>
      calls.add('seek ${position?.inMilliseconds}');
}

class _KnownEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => Episode()
    ..id = audioUrl == _url ? _episodeId : _otherEpisodeId
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

/// Records saved positions, the store a resume reads.
class _RecordingHistoryRepository implements PlaybackHistoryRepository {
  final List<int> savedPositionsMs = [];

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async => null;

  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  }) async => savedPositionsMs.add(positionMs);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Logs paused-position saves into the engine call log, so tests can see
/// which came first.
class _QuietHistoryService implements PlaybackHistoryService {
  _QuietHistoryService(this.calls);

  final List<String> calls;

  /// Keeps the paused-position save open, as a slow database write does.
  Completer<void>? holdSave;

  @override
  void onPlaybackResumed() {}

  @override
  Future<void> onListenerResumed(
    int episodeId, {
    required Duration position,
    required Duration duration,
  }) async {}

  @override
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {}

  @override
  Future<void> onProgressUpdate(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async {}

  @override
  Future<void> onPlaybackPaused(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async {
    calls.add('save paused');
    await holdSave?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _RecordingAudioPlayer player;
  late _RecordingHistoryRepository history;
  late _QuietHistoryService historyService;
  late ProviderContainer container;
  late StreamController<PlaybackProgress> progress;

  setUp(() {
    progress = StreamController<PlaybackProgress>.broadcast();
    final calls = <String>[];
    player = _RecordingAudioPlayer(calls);
    history = _RecordingHistoryRepository();
    container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        episodeRepositoryProvider.overrideWithValue(_KnownEpisodeRepository()),
        downloadServiceProvider.overrideWithValue(_NoDownloadService()),
        playbackHistoryRepositoryProvider.overrideWithValue(history),
        playbackHistoryServiceProvider.overrideWithValue(
          historyService = _QuietHistoryService(calls),
        ),
        playbackProgressStreamProvider.overrideWith((ref) => progress.stream),
        audioPlayerProvider.overrideWith((ref) {
          ref.onDispose(player.dispose);
          return player;
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await progress.close();
  });

  AudioPlayerController controller() =>
      container.read(audioPlayerControllerProvider.notifier);

  // Full metadata spares play() the subscription lookup for analytics.
  Future<void> playEpisode([String url = _url]) async {
    await controller().play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: 'Episode',
        podcastTitle: 'Podcast',
        feedUrl: 'https://example.com/feed.xml',
      ),
    );
    // A position just past the boundary, as when the crossing is seen.
    container.listen(playbackProgressStreamProvider, (_, _) {});
    progress.add(
      const PlaybackProgress(
        position: Duration(milliseconds: 60200),
        duration: Duration(minutes: 10),
        bufferedPosition: Duration.zero,
      ),
    );
    await pumpEventQueue();
  }

  test('pauses before moving back to the position', () async {
    await playEpisode();
    player.calls.clear();

    await controller().pauseAt(const Duration(seconds: 60));

    check(player.calls).deepEquals(['pause', 'save paused', 'seek 60000']);
  });

  test('saves the position as the resume point', () async {
    await playEpisode();
    history.savedPositionsMs.clear();

    await controller().pauseAt(const Duration(seconds: 60));

    check(history.savedPositionsMs).deepEquals([60000]);
  });

  test('announces the seek as the player\'s own', () async {
    await playEpisode();
    final events = <PlayerLifecycleEvent>[];
    final sub = container
        .read(playerLifecycleEventsProvider)
        .listen(events.add);
    addTearDown(sub.cancel);

    await controller().pauseAt(const Duration(seconds: 60));
    await pumpEventQueue();

    check(events.whereType<SeekStartedLifecycle>()).single
      ..has((e) => e.automatic, 'automatic').isTrue()
      ..has((e) => e.target, 'target').equals(const Duration(seconds: 60));
  });

  test('silences the engine before the paused position is saved', () async {
    await playEpisode();
    await pumpEventQueue();
    player.calls.clear();
    player.holdPause = Completer<void>();

    final paused = controller().pauseAt(const Duration(seconds: 60));
    await pumpEventQueue();
    // A slow engine pause holds everything after it, so nothing is saved
    // while audio may still be playing.
    check(player.calls).deepEquals(['pause']);

    player.holdPause!.complete();
    await paused;
    check(player.calls).deepEquals(['pause', 'save paused', 'seek 60000']);
  });

  test('a play of another episode during the pause keeps the old '
      'boundary off it', () async {
    await playEpisode();
    player.calls.clear();
    history.savedPositionsMs.clear();
    final hold = Completer<void>();
    player.holdPause = hold;

    final paused = controller().pauseAt(const Duration(seconds: 60));
    await pumpEventQueue();
    player.holdPause = null;
    await playEpisode(_otherUrl);
    hold.complete();
    await paused;
    await pumpEventQueue();

    check(player.calls.where((call) => call.startsWith('seek'))).isEmpty();
    check(history.savedPositionsMs).isEmpty();
  });

  test('a resume during the paused-position save keeps playing on', () async {
    await playEpisode();
    player.calls.clear();
    history.savedPositionsMs.clear();
    final hold = Completer<void>();
    historyService.holdSave = hold;

    final paused = controller().pauseAt(const Duration(seconds: 60));
    await pumpEventQueue();
    await controller().resume();
    hold.complete();
    await paused;
    await pumpEventQueue();

    // Moving playing audio back to the boundary would be an audible jump.
    check(player.calls.where((call) => call.startsWith('seek'))).isEmpty();
    check(history.savedPositionsMs).isEmpty();
  });
}
