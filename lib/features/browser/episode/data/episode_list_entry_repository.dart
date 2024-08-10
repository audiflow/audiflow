import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_list_entry_repository.g.dart';

abstract class EpisodeListEntryRepository {
  Future<int> count(int pid, EpisodeListEntryRole role);

  Future<List<EpisodeListEntry>> findAllOf(int pid, EpisodeListEntryRole role);

  Future<EpisodeListEntry?> findBy({
    required int pid,
    required EpisodeListEntryRole role,
    int? eid,
    int? order,
  });

  Future<List<EpisodeListEntry>> populate(
    int pid,
    EpisodeListEntryRole role,
    List<int> episodeIds,
  );

  Future<void> addAll(List<EpisodeListEntry> entries);

  Future<void> clear(int pid, EpisodeListEntryRole role);
}

@Riverpod(keepAlive: true)
EpisodeListEntryRepository episodeListEntryRepository(
  EpisodeListEntryRepositoryRef ref,
) {
  // * Override this in the main method
  throw UnimplementedError();
}
