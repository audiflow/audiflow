import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

const _url = 'https://example.com/a.mp3';
const _episodeId = 7;

/// Records the engine calls in order instead of playing audio.
class _RecordingAudioPlayer extends AudioPlayer {
  _RecordingAudioPlayer() : super(handleInterruptions: false);

  final List<String> calls = [];

  @override
  Duration? get duration => const Duration(minutes: 10);

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
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> seek(Duration? position, {int? index}) async =>
      calls.add('seek ${position?.inMilliseconds}');
}

class _KnownEpisodeRepository implements EpisodeRepository {
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => Episode()
    ..id = _episodeId
    ..podcastId = 1
    ..guid = 'guid'
    ..title = 'Episode'
    ..audioUrl = _url;

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

class _QuietHistoryService implements PlaybackHistoryService {
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
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _RecordingAudioPlayer player;
  late _RecordingHistoryRepository history;
  late ProviderContainer container;

  setUp(() {
    player = _RecordingAudioPlayer();
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

  // Full metadata spares play() the subscription lookup for analytics.
  Future<void> playEpisode() => controller().play(
    _url,
    metadata: const NowPlayingInfo(
      episodeUrl: _url,
      episodeTitle: 'Episode',
      podcastTitle: 'Podcast',
      feedUrl: 'https://example.com/feed.xml',
    ),
  );

  test('pauses before moving back to the position', () async {
    await playEpisode();
    player.calls.clear();

    await controller().pauseAt(const Duration(seconds: 60));

    check(player.calls).deepEquals(['pause', 'seek 60000']);
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
}
