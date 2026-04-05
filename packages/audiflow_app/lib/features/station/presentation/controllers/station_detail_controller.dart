import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_detail_controller.g.dart';

@riverpod
Future<Station?> stationById(Ref ref, int stationId) {
  return ref.watch(stationRepositoryProvider).findById(stationId);
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

@riverpod
Future<Episode?> episodeById(Ref ref, int episodeId) {
  return ref.watch(episodeRepositoryProvider).getById(episodeId);
}
