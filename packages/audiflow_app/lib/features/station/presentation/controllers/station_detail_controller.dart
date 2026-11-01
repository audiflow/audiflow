import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_detail_controller.g.dart';

@riverpod
Stream<Station?> stationById(Ref ref, int stationId) {
  return ref.watch(stationRepositoryProvider).watchById(stationId);
}

@riverpod
Stream<List<StationEpisode>> stationEpisodes(Ref ref, int stationId) {
  final station = ref.watch(stationByIdProvider(stationId));
  final ascending = station.when(
    data: (s) => s?.episodeSort == StationEpisodeSort.oldest,
    loading: () => false,
    error: (_, _) => false,
  );
  final grouped = station.when(
    data: (s) => s?.groupByPodcast ?? false,
    loading: () => false,
    error: (_, _) => false,
  );
  return ref
      .watch(stationEpisodeRepositoryProvider)
      .watchByStation(stationId, ascending: ascending, grouped: grouped);
}

@riverpod
Stream<List<StationPodcast>> stationPodcasts(Ref ref, int stationId) {
  return ref.watch(stationPodcastRepositoryProvider).watchByStation(stationId);
}

/// A station list row with everything it needs to build at its final height.
typedef StationEpisodeRow = ({
  StationEpisode stationEpisode,
  Episode episode,
  Subscription? subscription,
});

/// Loads the episodes and podcasts behind the station's list in one pass.
///
/// Rows used to load their own episode, so a row rebuilt above the viewport
/// while scrolling up showed a placeholder and then grew to its real height,
/// pushing the visible rows down.
@riverpod
Future<List<StationEpisodeRow>> stationEpisodeRows(
  Ref ref,
  int stationId,
) async {
  final stationEpisodes = await ref.watch(
    stationEpisodesProvider(stationId).future,
  );
  final episodes = await ref
      .watch(episodeRepositoryProvider)
      .getByIds(stationEpisodes.map((se) => se.episodeId).toList());
  final episodeById = {for (final e in episodes) e.id: e};

  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final podcastIds = {for (final e in episodes) e.podcastId}.toList();
  final subscriptions = await Future.wait(
    podcastIds.map(subscriptionRepo.getById),
  );
  final subscriptionById = {
    for (var i = 0; i < podcastIds.length; i++) podcastIds[i]: subscriptions[i],
  };

  return [
    for (final se in stationEpisodes)
      if (episodeById[se.episodeId] case final episode?)
        (
          stationEpisode: se,
          episode: episode,
          subscription: subscriptionById[episode.podcastId],
        ),
  ];
}
