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
  Future<List<Episode>> findEpisodesByPodcastId(Id pid) async {
    return isar.episodes.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<List<Episode>> findLatestEpisodes(
    Id pid, {
    DateTime? lastPubDate,
    required int limit,
  }) async {
    var filter = isar.episodes.where().filter().pidEqualTo(pid);
    if (lastPubDate != null) {
      filter = filter.publicationDateGreaterThan(lastPubDate);
    }
    return filter.sortByPublicationDateDesc().limit(limit).findAll();
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
