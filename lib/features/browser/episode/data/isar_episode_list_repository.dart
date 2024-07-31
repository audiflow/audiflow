import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarEpisodeListEntryRepository implements EpisodeListEntryRepository {
  IsarEpisodeListEntryRepository(this._isar);

  final Isar _isar;

  @override
  Future<int> count(int pid) {
    return _isar.episodeListEntrys.where().filter().pidEqualTo(pid).count();
  }

  @override
  Future<List<EpisodeListEntry>> findAllOf(int pid) {
    return _isar.episodeListEntrys
        .where()
        .filter()
        .pidEqualTo(pid)
        .sortByOrder()
        .findAll();
  }

  @override
  Future<EpisodeListEntry?> findBy({
    required int pid,
    int? eid,
    int? order,
  }) =>
      _isar.episodeListEntrys
          .where()
          .filter()
          .pidEqualTo(pid)
          .optional(eid != null, (q) => q.eidEqualTo(eid!))
          .optional(order != null, (q) => q.orderEqualTo(order!))
          .findFirst();

  @override
  Future<List<EpisodeListEntry>> populate(
    int pid,
    List<int> episodeIds,
  ) async {
    final entries = episodeIds
        .mapIndexed(
          (index, eid) => EpisodeListEntry(
            pid: pid,
            eid: eid,
            order: index,
          ),
        )
        .toList();

    await _isar.writeTxn(() => _isar.episodeListEntrys.putAll(entries));
    return entries;
  }

  @override
  Future<void> addAll(List<EpisodeListEntry> entries) async {
    await _isar.writeTxn(() => _isar.episodeListEntrys.putAll(entries));
  }

  @override
  Future<void> clear(int pid) async {
    await _isar.writeTxn(
      () {
        return _isar.episodeListEntrys
            .where()
            .filter()
            .pidEqualTo(pid)
            .deleteAll();
      },
    );
  }
}
