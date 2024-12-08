import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class EpisodeRepositoryHandleHandler implements EpisodeRepository {
  EpisodeRepositoryHandleHandler(this._ref, this._inner);

  final Ref _ref;
  final EpisodeRepository _inner;

  @override
  Future<Episode?> findEpisode(Id id) => _inner.findEpisode(id);

  @override
  Future<List<Episode?>> findEpisodes(Iterable<Id> ids) =>
      _inner.findEpisodes(ids);

  @override
  Future<List<Episode>> queryEpisodes({
    required Id pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) =>
      _inner.queryEpisodes(
        pid: pid,
        lastOrdinal: lastOrdinal,
        ascending: ascending,
        limit: limit,
      );

  @override
  Future<Episode?> findLatestEpisode(Id pid) => _inner.findLatestEpisode(pid);

  @override
  Future<List<Episode>> findLatestEpisodes(
    Id pid, {
    required DateTime publishedAfter,
    int limit = 10,
  }) =>
      _inner.findLatestEpisodes(
        pid,
        publishedAfter: publishedAfter,
        limit: limit,
      );

  @override
  Future<int> count({required Id pid}) => _inner.count(pid: pid);

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _inner.saveEpisode(episode);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodeUpdatedEvent(episode));
  }

  @override
  Future<void> saveEpisodes(List<Episode> episodes) async {
    await _inner.saveEpisodes(episodes);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodesUpdatedEvent(episodes.toList()));
  }

  @override
  Future<void> deleteEpisodes(List<int> eids) async {
    await _inner.deleteEpisodes(eids);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodesDeletedEvent(eids));
  }
}
