import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_repository.g.dart';

abstract class EpisodeRepository {
  Future<Episode?> findEpisode(Id id);

  Future<List<Episode?>> findEpisodes(Iterable<Id> ids);

  Future<List<Episode>> findEpisodesByPodcastId(Id pid);

  Future<List<Episode>> findLatestEpisodes(
    Id pid, {
    DateTime? lastPubDate,
    required int limit,
  });

  Future<void> saveEpisode(Episode episode);

  Future<void> saveEpisodes(Iterable<Episode> episodes);
}

@Riverpod(keepAlive: true)
EpisodeRepository episodeRepository(EpisodeRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
