import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _FakeChapterRepository implements ChapterRepository {
  _FakeChapterRepository(this.chapters);

  final List<EpisodeChapter> chapters;

  @override
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) async =>
      chapters.where((c) => c.episodeId == episodeId).toList();

  @override
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) =>
      Stream.fromFuture(getByEpisodeId(episodeId));

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Emits whatever the test pushes, like the store's watch query.
class _LiveChapterRepository implements ChapterRepository {
  final controller = StreamController<List<EpisodeChapter>>.broadcast();

  @override
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) =>
      controller.stream;

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

  // The provider is auto-disposed; a listener keeps it alive until the
  // store's first emission.
  Future<List<EpisodeChapter>> readChapters(ProviderContainer container) {
    container.listen(currentEpisodeChaptersProvider, (_, _) {});
    return container.read(currentEpisodeChaptersProvider.future);
  }

  group('currentEpisodeChaptersProvider', () {
    test('is empty when nothing is playing', () async {
      final container = makeContainer(nowPlaying: null);
      check(await readChapters(container)).isEmpty();
    });

    test('is empty for an episode without a local record', () async {
      final container = makeContainer(
        nowPlaying: _nowPlaying(withEpisode: false),
      );
      check(await readChapters(container)).isEmpty();
    });

    test('orders chapters by start time', () async {
      final container = makeContainer(nowPlaying: _nowPlaying());
      final chapters = await readChapters(container);
      check(chapters.map((c) => c.startMs)).deepEquals([0, 60000]);
    });

    test('follows chapter changes in the store', () async {
      final repository = _LiveChapterRepository();
      addTearDown(repository.controller.close);
      final container = ProviderContainer(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(repository),
          nowPlayingControllerProvider.overrideWith(
            () => _FixedNowPlaying(_nowPlaying()),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(currentEpisodeChaptersProvider, (_, _) {});

      repository.controller.add([_chapter(0, 0)]);
      await Future<void>.delayed(Duration.zero);
      check(
        container.read(currentEpisodeChaptersProvider).value,
      ).isNotNull().length.equals(1);

      repository.controller.add([_chapter(1, 60000), _chapter(0, 0)]);
      await Future<void>.delayed(Duration.zero);
      check(
        container
            .read(currentEpisodeChaptersProvider)
            .value!
            .map((c) => c.startMs),
      ).deepEquals([0, 60000]);
    });
  });

  group('currentChapterProvider', () {
    Future<CurrentChapter?> readCurrent(ProviderContainer container) async {
      container.listen(currentChapterProvider, (_, _) {});
      await readChapters(container);
      return container.read(currentChapterProvider);
    }

    test('picks the chapter containing the live position', () async {
      progress = _progress(const Duration(seconds: 90));
      final container = makeContainer(nowPlaying: _nowPlaying());
      final current = await readCurrent(container);
      check(current?.index).equals(1);
      check(current?.chapter.title).equals('Chapter 1');
    });

    test('falls back to the saved position while idle', () async {
      progress = _progress(Duration.zero, duration: Duration.zero);
      final container = makeContainer(
        nowPlaying: _nowPlaying(savedPosition: const Duration(seconds: 70)),
      );
      check((await readCurrent(container))?.index).equals(1);
    });

    test('is null before a late first chapter', () async {
      progress = _progress(const Duration(seconds: 5));
      final container = makeContainer(
        nowPlaying: _nowPlaying(),
        chapters: [_chapter(0, 30000)],
      );
      check(await readCurrent(container)).isNull();
    });

    test('is null for an episode without chapters', () async {
      progress = _progress(const Duration(seconds: 5));
      final container = makeContainer(
        nowPlaying: _nowPlaying(),
        chapters: const [],
      );
      check(await readCurrent(container)).isNull();
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
      await readChapters(container);
      container.read(currentChapterProvider);
      notified.clear();

      container.read(position.notifier).set(const Duration(seconds: 10));
      container.read(currentChapterProvider);
      container.read(position.notifier).set(const Duration(seconds: 20));
      container.read(currentChapterProvider);
      container.read(position.notifier).set(const Duration(seconds: 61));
      container.read(currentChapterProvider);

      check(notified).deepEquals([1]);
    });
  });
}
