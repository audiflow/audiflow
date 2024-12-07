import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_repository.g.dart';

abstract class EpisodeRepository {
  Future<Episode?> findEpisode(Id id);

  Future<List<Episode?>> findEpisodes(Iterable<Id> ids);

  Future<List<Episode>> queryEpisodes({
    required Id pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  });

  Future<Episode?> findLatestEpisode(Id pid);

  Future<List<Episode>> findLatestEpisodes(
    Id pid, {
    required DateTime publishedAfter,
    int limit = 10,
  });

  Future<int> count({required Id pid});

  Future<void> saveEpisode(Episode episode);

  Future<void> saveEpisodes(List<Episode> episodes);

  Future<void> deleteEpisodes(List<int> eids);
}

@Riverpod(keepAlive: true)
EpisodeRepository episodeRepository(EpisodeRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
