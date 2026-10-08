import 'package:audiflow_core/audiflow_core.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../player/models/playback_history.dart';
import '../../player/repositories/playback_history_repository.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../models/download_origin.dart';
import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';
import '../repositories/download_repository_impl.dart';
import '../../subscription/extensions/subscription_extensions.dart';
import '../../subscription/models/subscriptions.dart';
import 'download_service.dart';

part 'download_retention_service.g.dart';

@Riverpod(keepAlive: true)
DownloadRetentionService downloadRetentionService(Ref ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  return DownloadRetentionService(
    downloadRepository: ref.watch(downloadRepositoryProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    playbackHistoryRepository: ref.watch(playbackHistoryRepositoryProvider),
    isAutoDeletePlayedEnabled: () => ref.read(downloadAutoDeletePlayedProvider),
    deleteDownload: (task) => downloadService.deleteAuto(task.id),
    logger: ref.watch(namedLoggerProvider('DownloadRetention')),
  );
}

/// Removes auto-downloaded episodes the listener no longer needs.
///
/// Only [DownloadOrigin.auto] downloads are ever removed; downloads the
/// listener requested are left alone.
class DownloadRetentionService {
  DownloadRetentionService({
    required this._downloadRepository,
    required this._episodeRepository,
    required this._playbackHistoryRepository,
    required this._isAutoDeletePlayedEnabled,
    required this._deleteDownload,
    this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DownloadRepository _downloadRepository;
  final EpisodeRepository _episodeRepository;
  final PlaybackHistoryRepository _playbackHistoryRepository;
  final bool Function() _isAutoDeletePlayedEnabled;

  /// Removes the task, its file, and anything derived from it, but only
  /// while the task is still auto; returns whether it did. Injected so the
  /// background isolate, which has no download queue, can supply its own
  /// implementation.
  final Future<bool> Function(DownloadTask task) _deleteDownload;
  final Logger? _logger;
  final DateTime Function() _clock;

  /// Deletes completed auto downloads whose episode was finished at least
  /// [AppConstants.playedDownloadGracePeriod] ago. Returns the number
  /// deleted.
  ///
  /// The grace period is checked against the episode's current completion
  /// time, so marking an episode unplayed within the window keeps its file.
  Future<int> sweepPlayed() async {
    if (!_isAutoDeletePlayedEnabled()) return 0;

    final completed = await _downloadRepository.getByStatus(
      const DownloadStatus.completed(),
    );
    var deleted = 0;
    for (final task in completed) {
      if (task.downloadOrigin != DownloadOrigin.auto) continue;
      if (!await _isPastGracePeriod(task.episodeId)) continue;
      if (await _tryDeleteAuto(task)) deleted++;
    }
    if (0 < deleted) _logger?.i('Deleted $deleted played auto downloads');
    return deleted;
  }

  Future<bool> _isPastGracePeriod(int episodeId) async {
    final history = await _playbackHistoryRepository.getByEpisodeId(episodeId);
    final completedAt = history?.completedAt;
    if (completedAt == null) return false;
    final deadline = completedAt.add(AppConstants.playedDownloadGracePeriod);
    return !_clock().isBefore(deadline);
  }

  /// Statuses of downloads that hold, or will hold, a file. Failed and
  /// cancelled tasks take no space, so they do not count toward the limit.
  static final _retainedStatuses = <DownloadStatus>{
    const DownloadStatus.pending(),
    const DownloadStatus.downloading(),
    const DownloadStatus.paused(),
    const DownloadStatus.completed(),
  };

  /// Deletes the oldest unstarted auto downloads of [subscription] beyond
  /// its keep count (falling back to [defaultKeepCount]). Returns the
  /// number deleted.
  ///
  /// Episodes the listener has started or finished neither count toward
  /// the limit nor get deleted here; finished ones are left to
  /// [sweepPlayed].
  ///
  /// Best-effort: failures are logged and reported as 0 so a trim problem
  /// never marks an otherwise successful feed sync as failed.
  Future<int> trimForSubscription(
    Subscription subscription, {
    required int defaultKeepCount,
  }) async {
    try {
      return await _trim(subscription, defaultKeepCount);
    } catch (e, stack) {
      // Isar reports storage failures as Error subclasses too.
      _logger?.w(
        'Failed to trim auto downloads of podcast ${subscription.id}',
        error: e,
        stackTrace: stack,
      );
      return 0;
    }
  }

  Future<int> _trim(Subscription subscription, int defaultKeepCount) async {
    final keepCount = subscription.effectiveKeepCount(defaultKeepCount);
    final candidates = await _unstartedAutoDownloads(subscription.id);
    if (candidates.length <= keepCount) return 0;

    var deleted = 0;
    for (final candidate in candidates.skip(keepCount)) {
      if (await _tryDeleteAuto(candidate.task)) deleted++;
    }
    _logger?.i(
      'Trimmed $deleted auto downloads of podcast ${subscription.id} '
      'to keep $keepCount',
    );
    return deleted;
  }

  /// Unstarted auto downloads of [podcastId], newest episode first.
  Future<List<_Candidate>> _unstartedAutoDownloads(int podcastId) async {
    final episodes = {
      for (final episode in await _episodeRepository.getByPodcastId(podcastId))
        episode.id: episode,
    };
    final history = await _playbackHistoryRepository.getByPodcastId(podcastId);
    final candidates = [
      for (final task in await _downloadRepository.getByEpisodeIds(
        episodes.keys,
      ))
        if (task.downloadOrigin == DownloadOrigin.auto &&
            _retainedStatuses.contains(task.downloadStatus) &&
            _isUnstarted(history[task.episodeId]))
          if (episodes[task.episodeId] case final episode?)
            _Candidate(task, episode),
    ];
    // Equal dates fall back to the task ID (later task is newer) so the
    // same episodes are kept on every run.
    return candidates..sort((a, b) {
      final byDate = b.sortDate.compareTo(a.sortDate);
      return byDate != 0 ? byDate : b.task.id.compareTo(a.task.id);
    });
  }

  static bool _isUnstarted(PlaybackHistory? history) =>
      history == null ||
      (history.positionMs == 0 && history.completedAt == null);

  /// One undeletable file must not keep the rest of the pass from running.
  ///
  /// The row is re-read first: a manual download request may have promoted
  /// the task since it was listed, and the listener's choice wins. The
  /// fresh row is what gets deleted, so its current status is what the
  /// deleter sees. The deleter re-checks the origin atomically with the
  /// delete, since a keep request can still land after this read.
  Future<bool> _tryDeleteAuto(DownloadTask task) async {
    try {
      final current = await _downloadRepository.getById(task.id);
      if (current == null || current.downloadOrigin != DownloadOrigin.auto) {
        return false;
      }
      return await _deleteDownload(current);
    } on Exception catch (e, stack) {
      _logger?.w(
        'Failed to delete auto download ${task.id}',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}

class _Candidate {
  _Candidate(this.task, this.episode);

  final DownloadTask task;
  final Episode episode;

  /// Publish date, or the download's creation time for feeds that omit it.
  DateTime get sortDate => episode.publishedAt ?? task.createdAt;
}
