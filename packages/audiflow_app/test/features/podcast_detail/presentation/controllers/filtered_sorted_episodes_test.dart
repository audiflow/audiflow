import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _feedUrl = 'https://example.com/feed.xml';

String _audioUrl(String name) => 'https://example.com/$name.mp3';

PodcastItem _item(String name, int day) => PodcastItem(
  parsedAt: DateTime(2026),
  sourceUrl: _feedUrl,
  title: name,
  description: '',
  enclosureUrl: _audioUrl(name),
  publishDate: DateTime(2026, 1, day),
);

EpisodeWithProgress _progress(
  int id,
  String name, {
  int positionMs = 0,
  DateTime? completedAt,
  bool withHistory = true,
}) => EpisodeWithProgress(
  episode: Episode()
    ..id = id
    ..podcastId = 1
    ..guid = name
    ..title = name
    ..audioUrl = _audioUrl(name),
  history: withHistory
      ? (PlaybackHistory()
          ..episodeId = id
          ..positionMs = positionMs
          ..durationMs = 1000
          ..completedAt = completedAt)
      : null,
);

void main() {
  // fresh: stored, never played. started: in progress. done: played.
  // replay: played with a saved position. unstored: no local record.
  final items = [
    _item('fresh', 1),
    _item('started', 2),
    _item('done', 3),
    _item('replay', 4),
    _item('unstored', 5),
  ];
  final progressByUrl = {
    _audioUrl('fresh'): _progress(1, 'fresh', withHistory: false),
    _audioUrl('started'): _progress(2, 'started', positionMs: 300),
    _audioUrl('done'): _progress(3, 'done', completedAt: DateTime(2026, 2)),
    _audioUrl('replay'): _progress(
      4,
      'replay',
      positionMs: 200,
      completedAt: DateTime(2026, 2),
    ),
  };

  late StreamController<Set<int>> downloads;

  setUp(() => downloads = StreamController<Set<int>>.broadcast());
  tearDown(() => downloads.close());

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        podcastDetailProvider.overrideWith(
          (ref, _) async => ParsedFeed(
            podcast: PodcastFeed(
              parsedAt: DateTime(2026),
              sourceUrl: _feedUrl,
              title: 'Podcast',
              description: '',
            ),
            episodes: items,
          ),
        ),
        podcastEpisodeProgressProvider.overrideWith(
          (ref, _) async => progressByUrl,
        ),
        completedDownloadEpisodeIdsProvider.overrideWith(
          (ref) => downloads.stream,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<List<String>> titles(
    ProviderContainer container,
    EpisodeFilter filter, {
    SortOrder sortOrder = SortOrder.ascending,
  }) async {
    final provider = filteredSortedEpisodesProvider(
      _feedUrl,
      filter,
      sortOrder,
    );
    final episodes = await container.read(provider.future);
    return episodes.map((e) => e.title).toList();
  }

  group('filteredSortedEpisodes', () {
    test('all keeps every episode, sorted by date', () async {
      final container = createContainer();
      check(
        await titles(container, EpisodeFilter.all),
      ).deepEquals(['fresh', 'started', 'done', 'replay', 'unstored']);
      check(
        await titles(
          container,
          EpisodeFilter.all,
          sortOrder: SortOrder.descending,
        ),
      ).deepEquals(['unstored', 'replay', 'done', 'started', 'fresh']);
    });

    test('unplayed keeps untouched and unstored episodes', () async {
      final container = createContainer();
      check(
        await titles(container, EpisodeFilter.unplayed),
      ).deepEquals(['fresh', 'unstored']);
    });

    test('in progress keeps started, unfinished episodes', () async {
      final container = createContainer();
      check(
        await titles(container, EpisodeFilter.inProgress),
      ).deepEquals(['started']);
    });

    test('played keeps played episodes, whatever their position', () async {
      final container = createContainer();
      check(
        await titles(container, EpisodeFilter.played),
      ).deepEquals(['done', 'replay']);
    });

    test('downloaded keeps episodes with a completed download', () async {
      final container = createContainer();
      final provider = filteredSortedEpisodesProvider(
        _feedUrl,
        EpisodeFilter.downloaded,
        SortOrder.ascending,
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await pumpEventQueue();
      downloads.add({1, 3, 99});

      final episodes = await container.read(provider.future);
      check(episodes.map((e) => e.title)).deepEquals(['fresh', 'done']);
    });

    test('downloaded refreshes when downloads change', () async {
      final container = createContainer();
      final provider = filteredSortedEpisodesProvider(
        _feedUrl,
        EpisodeFilter.downloaded,
        SortOrder.ascending,
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await pumpEventQueue();
      downloads.add({2});
      await pumpEventQueue();
      check(
        subscription.read().value?.map((e) => e.title),
      ).isNotNull().deepEquals(['started']);

      // A download completing adds the episode.
      downloads.add({2, 4});
      await pumpEventQueue();
      check(
        subscription.read().value?.map((e) => e.title),
      ).isNotNull().deepEquals(['started', 'replay']);

      // Removing a download drops it.
      downloads.add({4});
      await pumpEventQueue();
      check(
        subscription.read().value?.map((e) => e.title),
      ).isNotNull().deepEquals(['replay']);
    });
  });

  group('matchesEpisodeFilter', () {
    test('an unstored episode is unplayed and nothing else', () {
      for (final filter in EpisodeFilter.values) {
        final expected =
            filter == EpisodeFilter.all || filter == EpisodeFilter.unplayed;
        check(
          because: '$filter',
          matchesEpisodeFilter(
            filter,
            progress: null,
            downloadedEpisodeIds: const {1},
          ),
        ).equals(expected);
      }
    });
  });
}
