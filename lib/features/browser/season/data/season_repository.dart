import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_repository.g.dart';

abstract class SeasonRepository {
  Future<Season?> findSeason(Id id);

  Future<List<Season>> findPodcastSeasons(Id pid);

  Future<void> saveSeasons(Iterable<Season> seasons);
}

@Riverpod(keepAlive: true)
SeasonRepository seasonRepository(SeasonRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
