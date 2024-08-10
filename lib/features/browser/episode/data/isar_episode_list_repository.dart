import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarEpisodeListEntryRepository implements EpisodeListEntryRepository {
  IsarEpisodeListEntryRepository(this._isar);

  final Isar _isar;

  @override
  Future<int> count(int pid, EpisodeListEntryRole role) {
    return _isar.episodeListEntrys
        .where()
        .pidRoleEqualToAnyOrder(pid, role)
        .count();
  }

  @override
  Future<List<EpisodeListEntry>> findAllOf(int pid, EpisodeListEntryRole role) {
    return _isar.episodeListEntrys
        .where()
        .pidRoleEqualToAnyOrder(pid, role)
        .sortByOrder()
        .findAll();
  }

  @override
  Future<EpisodeListEntry?> findBy({
    required int pid,
    required EpisodeListEntryRole role,
    int? eid,
    int? order,
  }) =>
      _isar.episodeListEntrys
          .where()
          .pidRoleEqualToAnyOrder(pid, role)
          .filter()
          .optional(eid != null, (q) => q.eidEqualTo(eid!))
          .optional(order != null, (q) => q.orderEqualTo(order!))
          .findFirst();

  @override
  Future<List<EpisodeListEntry>> populate(
    int pid,
    EpisodeListEntryRole role,
    List<int> episodeIds,
  ) async {
    final entries = episodeIds
        .mapIndexed(
          (index, eid) => EpisodeListEntry(
            pid: pid,
            role: role,
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
  Future<void> clear(int pid, EpisodeListEntryRole role) async {
    await _isar.writeTxn(
      () {
        return _isar.episodeListEntrys
            .where()
            .pidRoleEqualToAnyOrder(pid, role)
            .deleteAll();
      },
    );
  }
}
