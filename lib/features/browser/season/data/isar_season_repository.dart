import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:isar/isar.dart';

class IsarSeasonRepository implements SeasonRepository {
  IsarSeasonRepository(this.isar);

  final Isar isar;

  @override
  Future<Season?> findSeason(Id id) {
    return isar.seasons.get(id);
  }

  @override
  Future<List<Season>> findPodcastSeasons(Id pid) {
    return isar.seasons
        .where()
        .filter()
        .pidEqualTo(pid)
        .sortByLatestPublicationDateDesc()
        .findAll();
  }

  @override
  Future<void> saveSeasons(Iterable<Season> seasons) async {
    await isar.writeTxn(() => isar.seasons.putAll(seasons.toList()));
  }

  @override
  Future<SeasonStats?> findSeasonStats(Id id) => isar.seasonStats.get(id);

  @override
  Future<List<SeasonStats?>> findSeasonStatsList(Iterable<int> seasonIds) =>
      isar.seasonStats.getAll(seasonIds.toList());

  @override
  Future<SeasonStats> updateSeasonStat(SeasonStatsUpdateParam param) async {
    return isar.writeTxn(() => _updateSeasonStat(param));
  }

  Future<SeasonStats> _updateSeasonStat(
    SeasonStatsUpdateParam param,
  ) async {
    final stats = await isar.seasonStats.get(param.id);
    final newStats = SeasonStats(
      id: param.id,
      completedEpisodeIds:
          param.completedEpisodeIds ?? stats?.completedEpisodeIds ?? const [],
    );
    await isar.seasonStats.put(newStats);
    return newStats;
  }

  @override
  Future<void> deleteAll(Iterable<int> ids) async {
    await isar.writeTxn(
      () => Future.wait(
        [
          isar.seasons.deleteAll(ids.toList()),
          isar.seasonStats.deleteAll(ids.toList()),
        ],
      ),
    );
  }
}
