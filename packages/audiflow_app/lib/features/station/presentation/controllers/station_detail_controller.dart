import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_detail_controller.g.dart';

@riverpod
Future<Station?> stationById(Ref ref, int stationId) {
  return ref.watch(stationRepositoryProvider).findById(stationId);
}

@riverpod
Stream<List<StationEpisode>> stationEpisodes(Ref ref, int stationId) {
  return ref.watch(stationEpisodeRepositoryProvider).watchByStation(stationId);
}

@riverpod
Stream<List<StationPodcast>> stationPodcasts(Ref ref, int stationId) {
  return ref.watch(stationPodcastRepositoryProvider).watchByStation(stationId);
}

@riverpod
Future<Episode?> episodeById(Ref ref, int episodeId) {
  return ref.watch(episodeRepositoryProvider).getById(episodeId);
}
