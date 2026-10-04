import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _FakeChapterRepository implements ChapterRepository {
  _FakeChapterRepository(this.chapters);

  final List<EpisodeChapter> chapters;

  @override
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) async =>
      chapters.where((c) => c.episodeId == episodeId).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FixedNowPlaying extends NowPlayingController {
  _FixedNowPlaying(this._initial);
  final NowPlayingInfo? _initial;

  @override
  NowPlayingInfo? build() => _initial;
}

class _Position extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;

  void set(Duration value) => state = value;
}

EpisodeChapter _chapter(int sortOrder, int startMs) => EpisodeChapter()
  ..id = sortOrder
  ..episodeId = 1
  ..sortOrder = sortOrder
  ..title = 'Chapter $sortOrder'
  ..startMs = startMs;

NowPlayingInfo _nowPlaying({Duration? savedPosition, bool withEpisode = true}) {
  return NowPlayingInfo(
    episodeUrl: 'https://example.com/a.mp3',
    episodeTitle: 'Episode',
    podcastTitle: 'Podcast',
    savedPosition: savedPosition,
    episode: withEpisode ? (Episode()..id = 1) : null,
  );
}

PlaybackProgress _progress(Duration position, {Duration? duration}) =>
    PlaybackProgress(
      position: position,
      duration: duration ?? const Duration(minutes: 10),
      bufferedPosition: Duration.zero,
    );

void main() {
  late PlaybackProgress? progress;

  ProviderContainer makeContainer({
    required NowPlayingInfo? nowPlaying,
    List<EpisodeChapter>? chapters,
  }) {
    final container = ProviderContainer(
      overrides: [
        chapterRepositoryProvider.overrideWithValue(
          _FakeChapterRepository(
            chapters ?? [_chapter(1, 60000), _chapter(0, 0)],
          ),
        ),
        nowPlayingControllerProvider.overrideWith(
          () => _FixedNowPlaying(nowPlaying),
        ),
        playbackProgressProvider.overrideWith((ref) => progress),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => progress = null);

  group('currentEpisodeChaptersProvider', () {
    test('is empty when nothing is playing', () async {
      final container = makeContainer(nowPlaying: null);
      expect(await container.read(currentEpisodeChaptersProvider.future), []);
    });

    test('is empty for an episode without a local record', () async {
      final container = makeContainer(
        nowPlaying: _nowPlaying(withEpisode: false),
      );
      expect(await container.read(currentEpisodeChaptersProvider.future), []);
    });

    test('orders chapters by start time', () async {
      final container = makeContainer(nowPlaying: _nowPlaying());
      final chapters = await container.read(
        currentEpisodeChaptersProvider.future,
      );
      expect(chapters.map((c) => c.startMs), [0, 60000]);
    });
  });

  group('currentChapterProvider', () {
    Future<CurrentChapter?> readCurrent(ProviderContainer container) async {
      container.listen(currentChapterProvider, (_, _) {});
      await container.read(currentEpisodeChaptersProvider.future);
      return container.read(currentChapterProvider);
    }

    test('picks the chapter containing the live position', () async {
      progress = _progress(const Duration(seconds: 90));
      final container = makeContainer(nowPlaying: _nowPlaying());
      final current = await readCurrent(container);
      expect(current?.index, 1);
      expect(current?.chapter.title, 'Chapter 1');
    });

    test('falls back to the saved position while idle', () async {
      progress = _progress(Duration.zero, duration: Duration.zero);
      final container = makeContainer(
        nowPlaying: _nowPlaying(savedPosition: const Duration(seconds: 70)),
      );
      expect((await readCurrent(container))?.index, 1);
    });

    test('is null before a late first chapter', () async {
      progress = _progress(const Duration(seconds: 5));
      final container = makeContainer(
        nowPlaying: _nowPlaying(),
        chapters: [_chapter(0, 30000)],
      );
      expect(await readCurrent(container), isNull);
    });

    test('is null for an episode without chapters', () async {
      progress = _progress(const Duration(seconds: 5));
      final container = makeContainer(
        nowPlaying: _nowPlaying(),
        chapters: const [],
      );
      expect(await readCurrent(container), isNull);
    });

    test('does not notify while the position stays in a chapter', () async {
      final position = NotifierProvider<_Position, Duration>(_Position.new);
      final container = ProviderContainer(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(
            _FakeChapterRepository([_chapter(0, 0), _chapter(1, 60000)]),
          ),
          nowPlayingControllerProvider.overrideWith(
            () => _FixedNowPlaying(_nowPlaying()),
          ),
          playbackProgressProvider.overrideWith(
            (ref) => _progress(ref.watch(position)),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notified = <int?>[];
      container.listen(
        currentChapterProvider,
        (_, next) => notified.add(next?.index),
      );
      await container.read(currentEpisodeChaptersProvider.future);
      container.read(currentChapterProvider);
      notified.clear();

      container.read(position.notifier).set(const Duration(seconds: 10));
      container.read(currentChapterProvider);
      container.read(position.notifier).set(const Duration(seconds: 20));
      container.read(currentChapterProvider);
      container.read(position.notifier).set(const Duration(seconds: 61));
      container.read(currentChapterProvider);

      expect(notified, [1]);
    });
  });
}
