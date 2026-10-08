import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../download/models/download_task.dart';
import '../../download/repositories/download_repository.dart';
import '../../download/repositories/download_repository_impl.dart';
import '../../download/services/download_service.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';

part 'dropped_episode_remover.g.dart';

@Riverpod(keepAlive: true)
DroppedEpisodeRemover droppedEpisodeRemover(Ref ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  return DroppedEpisodeRemover(
    episodeRepository: ref.watch(episodeRepositoryProvider),
    downloadRepository: ref.watch(downloadRepositoryProvider),
    deleteDownload: (task) => downloadService.delete(task.id),
    logger: ref.watch(namedLoggerProvider('FeedSync')),
  );
}

/// Outcome of [DroppedEpisodeRemover.remove].
final class DroppedEpisodeRemoval {
  const DroppedEpisodeRemoval({
    required this.deletedCount,
    required this.keptCount,
  });

  static const none = DroppedEpisodeRemoval(deletedCount: 0, keptCount: 0);

  /// Episodes deleted together with their downloads.
  final int deletedCount;

  /// Dropped episodes kept because their download could not be removed yet.
  final int keptCount;

  /// Whether every dropped episode is gone. While it is not, the caller
  /// must not store the feed's cache validators: a later 304 would skip
  /// the parse that finds the kept episodes again.
  bool get isComplete => keptCount == 0;
}

/// Removes episodes a feed no longer lists, together with their downloads.
///
/// Once the episode row is gone nothing can reach its download any more,
/// so manual and auto downloads alike are deleted first: their files would
/// otherwise stay on disk with no way to find or remove them.
class DroppedEpisodeRemover {
  DroppedEpisodeRemover({
    required this._episodeRepository,
    required this._downloadRepository,
    required this._deleteDownload,
    this._logger,
  });

  final EpisodeRepository _episodeRepository;
  final DownloadRepository _downloadRepository;

  /// Cancels the task if it is in flight, removes its file and record, and
  /// reconciles stations. Injected so the background isolate, which has no
  /// download queue, can supply its own implementation.
  final Future<void> Function(DownloadTask task) _deleteDownload;
  final Logger? _logger;

  /// Deletes the episodes of [podcastId] whose GUID is in [guids], and their
  /// downloads.
  ///
  /// An episode whose download could not be removed is kept, so the next
  /// sync, which still sees its GUID missing from the feed, retries it
  /// instead of leaving an unreachable download behind.
  Future<DroppedEpisodeRemoval> remove(int podcastId, Set<String> guids) async {
    if (guids.isEmpty) return DroppedEpisodeRemoval.none;
    final episodeIdsByGuid = await _resolveEpisodeIds(podcastId, guids);
    final keptEpisodeIds = await _deleteDownloads(episodeIdsByGuid.values);
    final keptGuids = {
      for (final MapEntry(key: guid, value: episodeId)
          in episodeIdsByGuid.entries)
        if (keptEpisodeIds.contains(episodeId)) guid,
    };
    if (keptGuids.isNotEmpty) {
      _logger?.w(
        'Kept ${keptGuids.length} dropped episodes of podcast $podcastId '
        'until their downloads can be removed',
      );
    }
    final deletedCount = await _episodeRepository.deleteByPodcastIdAndGuids(
      podcastId,
      guids.difference(keptGuids),
    );
    return DroppedEpisodeRemoval(
      deletedCount: deletedCount,
      keptCount: keptGuids.length,
    );
  }

  /// Resolved before the episode rows are deleted, since downloads are
  /// keyed by episode ID, not GUID.
  Future<Map<String, int>> _resolveEpisodeIds(
    int podcastId,
    Set<String> guids,
  ) async {
    final idsByGuid = <String, int>{};
    for (final guid in guids) {
      final episode = await _episodeRepository.getByPodcastIdAndGuid(
        podcastId,
        guid,
      );
      if (episode != null) idsByGuid[guid] = episode.id;
    }
    return idsByGuid;
  }

  /// Deletes every download of [episodeIds]. Returns the IDs of episodes
  /// whose download is still there.
  Future<Set<int>> _deleteDownloads(Iterable<int> episodeIds) async {
    if (episodeIds.isEmpty) return const {};
    final tasks = await _downloadRepository.getByEpisodeIds(episodeIds);
    final keptEpisodeIds = <int>{};
    for (final task in tasks) {
      if (!await _tryDelete(task)) keptEpisodeIds.add(task.episodeId);
    }
    if (tasks.isNotEmpty) {
      _logger?.i(
        'Deleted ${tasks.length - keptEpisodeIds.length} of ${tasks.length} '
        'downloads of dropped episodes',
      );
    }
    return keptEpisodeIds;
  }

  /// One undeletable file must not stop the sync or the other deletions.
  ///
  /// Success is judged by the record being gone: the background deleter
  /// returns normally but skips a task another isolate is downloading.
  Future<bool> _tryDelete(DownloadTask task) async {
    try {
      await _deleteDownload(task);
      final removed = await _downloadRepository.getById(task.id) == null;
      if (!removed) {
        _logger?.i('Download ${task.id} is still in use; retrying next sync');
      }
      return removed;
    } catch (e, stack) {
      // Isar reports storage failures as Error subclasses, not Exception.
      _logger?.w(
        'Failed to delete download ${task.id} of dropped episode '
        '${task.episodeId}',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
