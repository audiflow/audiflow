import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_list_entry_repository.g.dart';

abstract class EpisodeListEntryRepository {
  Future<int> count(int pid);

  Future<List<EpisodeListEntry>> query(
    int pid, {
    int? lastOrdinal,
    bool ascending = true,
    int? limit,
  });

  Future<EpisodeListEntry?> findBy({
    required int pid,
    int? eid,
    int? order,
  });

  Future<List<EpisodeListEntry>> populate(
    int pid,
    List<int> episodeIds,
  );

  Future<void> addAll(List<EpisodeListEntry> entries);

  Future<void> clear(int pid);
}

@Riverpod(keepAlive: true)
EpisodeListEntryRepository episodeListEntryRepository(
  EpisodeListEntryRepositoryRef ref,
) {
  // * Override this in the main method
  throw UnimplementedError();
}
