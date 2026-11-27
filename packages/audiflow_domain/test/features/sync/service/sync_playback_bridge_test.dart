import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _History implements PlaybackHistoryRepository {
  PlaybackHistory? stored;
  bool fail = false;

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async {
    if (fail) throw StateError('db closed');
    return stored;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _History history;
  late NowPlayingInfo? nowPlaying;
  late List<(int, Duration)> adopted;
  late SyncPlaybackBridge bridge;

  NowPlayingInfo info({String? key = 'ek1'}) => NowPlayingInfo(
    episodeUrl: 'https://example.com/a.mp3',
    episodeTitle: 'Episode',
    podcastTitle: 'Podcast',
    episode: Episode()
      ..id = 7
      ..episodeKey = key,
  );

  setUp(() {
    history = _History();
    nowPlaying = info();
    adopted = [];
    bridge = SyncPlaybackBridge(
      history: history,
      logger: Logger(level: Level.off),
      nowPlaying: () => nowPlaying,
      adoptPosition: (id, position) async => adopted.add((id, position)),
    );
  });

  group('onEpisodesMerged', () {
    test('moves the now-playing episode to its stored position', () async {
      history.stored = PlaybackHistory()..positionMs = 900000;

      await bridge.onEpisodesMerged({'ek0', 'ek1'});

      check(adopted).deepEquals([(7, const Duration(minutes: 15))]);
    });

    test('ignores other episodes', () async {
      history.stored = PlaybackHistory()..positionMs = 900000;

      await bridge.onEpisodesMerged({'ek2'});

      check(adopted).isEmpty();
    });

    test('a failed read is logged, not thrown', () async {
      history.fail = true;

      await bridge.onEpisodesMerged({'ek1'});

      check(adopted).isEmpty();
    });
  });
}
