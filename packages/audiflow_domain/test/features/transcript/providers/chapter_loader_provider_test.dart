import 'package:checks/checks.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _FakeChapterService implements ChapterService {
  _FakeChapterService({required this.changed});

  final bool changed;
  final List<int> requested = [];

  @override
  Future<bool> ensureChapters(int episodeId) async {
    requested.add(episodeId);
    return changed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _CountingChapterRepository implements ChapterRepository {
  int reads = 0;

  @override
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) async {
    reads++;
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NowPlaying extends NowPlayingController {
  @override
  NowPlayingInfo? build() => null;

  void play(int episodeId) => state = NowPlayingInfo(
    episodeUrl: 'https://example.com/$episodeId.mp3',
    episodeTitle: 'Episode $episodeId',
    podcastTitle: 'Podcast',
    episode: Episode()..id = episodeId,
  );
}

void main() {
  late _FakeChapterService service;
  late _CountingChapterRepository repository;

  ProviderContainer makeContainer({required bool changed}) {
    service = _FakeChapterService(changed: changed);
    repository = _CountingChapterRepository();
    final container = ProviderContainer(
      overrides: [
        chapterServiceProvider.overrideWithValue(service),
        chapterRepositoryProvider.overrideWithValue(repository),
        nowPlayingControllerProvider.overrideWith(_NowPlaying.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('loads chapters when an episode becomes now playing', () async {
    final container = makeContainer(changed: false);
    container.read(nowPlayingChapterLoaderProvider);
    check(service.requested).isEmpty();

    (container.read(nowPlayingControllerProvider.notifier) as _NowPlaying).play(
      7,
    );
    await Future<void>.delayed(Duration.zero);

    check(service.requested).deepEquals([7]);
  });

  test('refreshes the episode chapters when new ones are stored', () async {
    final container = makeContainer(changed: true);
    final sub = container.listen(episodeChaptersProvider(7), (_, _) {});
    addTearDown(sub.close);
    await container.read(episodeChaptersProvider(7).future);
    check(repository.reads).equals(1);

    container.read(nowPlayingChapterLoaderProvider);
    (container.read(nowPlayingControllerProvider.notifier) as _NowPlaying).play(
      7,
    );
    await Future<void>.delayed(Duration.zero);
    await container.read(episodeChaptersProvider(7).future);

    check(repository.reads).equals(2);
  });

  test('does not refresh when nothing changed', () async {
    final container = makeContainer(changed: false);
    final sub = container.listen(episodeChaptersProvider(7), (_, _) {});
    addTearDown(sub.close);
    await container.read(episodeChaptersProvider(7).future);

    container.read(nowPlayingChapterLoaderProvider);
    (container.read(nowPlayingControllerProvider.notifier) as _NowPlaying).play(
      7,
    );
    await Future<void>.delayed(Duration.zero);
    await container.read(episodeChaptersProvider(7).future);

    check(repository.reads).equals(1);
  });
}
