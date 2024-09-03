import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';

class IsarEpisodeRepository implements EpisodeRepository {
  IsarEpisodeRepository(this.isar);

  final Isar isar;

  @override
  Future<Episode?> findEpisode(Id id) async {
    return isar.episodes.get(id);
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<Id> ids) async {
    return isar.episodes.getAll(ids.toList());
  }

  @override
  Future<List<Episode>> queryEpisodes({
    required Id pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) async {
    return isar.episodes
        .where()
        .optional(
          true,
          (q) => lastOrdinal == null
              ? q.pidEqualToAnyOrdinal(pid)
              : ascending
                  ? q.pidEqualToOrdinalGreaterThan(pid, lastOrdinal)
                  : q.pidEqualToOrdinalLessThan(pid, lastOrdinal),
        )
        .optional(
          true,
          (q) => ascending ? q.sortByOrdinal() : q.sortByOrdinalDesc(),
        )
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<Episode?> findLatestEpisode(Id pid) async {
    return isar.episodes
        .where()
        .pidEqualToAnyOrdinal(pid)
        .sortByOrdinalDesc()
        .findFirst();
  }

  @override
  Future<int> count({required Id pid}) async {
    return isar.episodes.count();
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await isar.writeTxn(() => isar.episodes.put(episode));
  }

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await isar.writeTxn(() => isar.episodes.putAll(episodes.toList()));
  }
}
