import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/helpers/played_status_helper.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _audioUrl = 'https://example.com/episode.mp3';

class _FakeEpisodeRepository extends Fake implements EpisodeRepository {
  _FakeEpisodeRepository(this.episode);

  final Episode? episode;

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async =>
      audioUrl == _audioUrl ? episode : null;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async => podcastId == 3
      ? [
          for (final id in [11, 12, 13]) Episode()..id = id,
        ]
      : [];
}

class _FakeHistoryService extends Fake implements PlaybackHistoryService {
  final completed = <int>[];
  final incompleted = <int>[];

  @override
  Future<void> markCompleted(int episodeId) async => completed.add(episodeId);

  @override
  Future<void> markIncomplete(int episodeId) async =>
      incompleted.add(episodeId);

  @override
  Future<int> markAllCompleted(Iterable<int> episodeIds) async {
    completed.addAll(episodeIds);
    return episodeIds.length;
  }

  @override
  Future<int> markAllIncomplete(Iterable<int> episodeIds) async {
    incompleted.addAll(episodeIds);
    return episodeIds.length;
  }
}

void main() {
  late _FakeHistoryService historyService;

  ProviderContainer createContainer(Episode? episode) {
    historyService = _FakeHistoryService();
    final container = ProviderContainer(
      overrides: [
        episodeRepositoryProvider.overrideWithValue(
          _FakeEpisodeRepository(episode),
        ),
        playbackHistoryServiceProvider.overrideWithValue(historyService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('marks an unplayed episode completed', () async {
    final container = createContainer(Episode()..id = 7);

    await togglePlayedStatus(
      container,
      audioUrl: _audioUrl,
      isCurrentlyCompleted: false,
    );

    check(historyService.completed).deepEquals([7]);
    check(historyService.incompleted).isEmpty();
  });

  test('marks a played episode incomplete', () async {
    final container = createContainer(Episode()..id = 7);

    await togglePlayedStatus(
      container,
      audioUrl: _audioUrl,
      isCurrentlyCompleted: true,
    );

    check(historyService.incompleted).deepEquals([7]);
    check(historyService.completed).isEmpty();
  });

  test('does nothing when the episode is not persisted', () async {
    final container = createContainer(null);

    await togglePlayedStatus(
      container,
      audioUrl: _audioUrl,
      isCurrentlyCompleted: false,
    );

    check(historyService.completed).isEmpty();
    check(historyService.incompleted).isEmpty();
  });

  test('refreshes cached progress after toggling', () async {
    final container = createContainer(Episode()..id = 7);
    var builds = 0;
    final keyed = podcastEpisodeProgressProvider('https://example.com/feed');
    final probe = ProviderContainer(
      parent: container,
      overrides: [
        podcastEpisodeProgressProvider.overrideWith((ref, _) async {
          builds++;
          return const {};
        }),
      ],
    );
    addTearDown(probe.dispose);
    final subscription = probe.listen(keyed, (_, _) {});
    addTearDown(subscription.close);
    await probe.read(keyed.future);
    check(builds).equals(1);

    await togglePlayedStatus(
      probe,
      audioUrl: _audioUrl,
      isCurrentlyCompleted: false,
    );
    await probe.read(keyed.future);

    check(builds).equals(2);
  });

  test('marks every episode of a podcast played', () async {
    final container = createContainer(null);

    final count = await setPodcastPlayedStatus(
      container,
      podcastId: 3,
      played: true,
    );

    check(count).equals(3);
    check(historyService.completed).deepEquals([11, 12, 13]);
  });

  test('marks every episode of a podcast unplayed', () async {
    final container = createContainer(null);

    final count = await setPodcastPlayedStatus(
      container,
      podcastId: 3,
      played: false,
    );

    check(count).equals(3);
    check(historyService.incompleted).deepEquals([11, 12, 13]);
  });
}
