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
    return isar.seasons.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<void> saveSeasons(Iterable<Season> seasons) async {
    await isar.writeTxn(() => isar.seasons.putAll(seasons.toList()));
  }
}
