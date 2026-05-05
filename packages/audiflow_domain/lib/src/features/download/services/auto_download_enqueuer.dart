import 'package:logger/logger.dart';

import '../../feed/repositories/episode_repository.dart';
import '../../feed/services/feed_sync_diagnostic.dart';
import '../../subscription/models/subscriptions.dart';
import '../repositories/download_repository.dart';

/// Result of an auto-download enqueue pass over a single subscription.
class AutoDownloadEnqueueResult {
  const AutoDownloadEnqueueResult({
    required this.inspected,
    required this.created,
    required this.skipped,
  });

  /// Episodes considered (i.e. unprocessed pending list size).
  final int inspected;

  /// New download tasks actually created.
  final int created;

  /// Episodes skipped (duplicate active task, missing audio URL, or
  /// auto-download disabled on the subscription).
  final int skipped;
}

/// Idempotent auto-download enqueuer used by both foreground and background
/// sync paths.
///
/// Reads the per-podcast list of episodes that have not yet been processed
/// by the auto-download pipeline, optionally creates download tasks for
/// them when the subscription has auto-download enabled, and marks every
/// inspected episode as processed regardless. This prevents the previous
/// bug where the foreground path detected new episodes but only the
/// background path enqueued downloads — once foreground stored a GUID, the
/// next background sync saw it as "known" and never enqueued the download.
class AutoDownloadEnqueuer {
  AutoDownloadEnqueuer({
    required EpisodeRepository episodeRepo,
    required DownloadRepository downloadRepo,
    Logger? logger,
    FeedSyncDiagnosticSink? onDiagnostic,
  }) : _episodeRepo = episodeRepo,
       _downloadRepo = downloadRepo,
       _logger = logger,
       _onDiagnostic = onDiagnostic ?? noopFeedSyncDiagnosticSink;

  final EpisodeRepository _episodeRepo;
  final DownloadRepository _downloadRepo;
  final Logger? _logger;
  final FeedSyncDiagnosticSink _onDiagnostic;

  /// Processes pending auto-download episodes for [subscription].
  ///
  /// When [subscription.autoDownload] is true, episodes with a non-empty
  /// audio URL are enqueued for download (subject to deduplication inside
  /// [DownloadRepository.createDownload]). When auto-download is disabled
  /// for the subscription, episodes are still marked as processed so that
  /// later toggling auto-download on does not retroactively enqueue old
  /// episodes — matching prior behaviour.
  ///
  /// [wifiOnly] is the global "Wi-Fi only download" preference applied to
  /// any newly created tasks.
  Future<AutoDownloadEnqueueResult> enqueueForSubscription(
    Subscription subscription, {
    required bool wifiOnly,
  }) async {
    final pending = await _episodeRepo.getPendingAutoDownloadByPodcastId(
      subscription.id,
    );
    if (pending.isEmpty) {
      return const AutoDownloadEnqueueResult(
        inspected: 0,
        created: 0,
        skipped: 0,
      );
    }

    var created = 0;
    var skipped = 0;
    final processedIds = <int>[];

    for (final episode in pending) {
      processedIds.add(episode.id);

      if (!subscription.autoDownload) {
        skipped++;
        continue;
      }
      if (episode.audioUrl.isEmpty) {
        skipped++;
        continue;
      }

      try {
        final task = await _downloadRepo.createDownload(
          episodeId: episode.id,
          audioUrl: episode.audioUrl,
          wifiOnly: wifiOnly,
        );
        if (task == null) {
          skipped++;
        } else {
          created++;
        }
      } catch (e, stack) {
        // Do not mark the episode processed when enqueue fails so a future
        // sync can retry. Roll the ID back out of processedIds.
        processedIds.removeLast();
        _logger?.e(
          'AutoDownloadEnqueuer: failed to create download for episode '
          '${episode.id} (podcast ${subscription.id})',
          error: e,
          stackTrace: stack,
        );
      }
    }

    if (processedIds.isNotEmpty) {
      await _episodeRepo.markAutoDownloadEnqueued(processedIds);
    }

    _onDiagnostic('feed-sync:auto-download', {
      'podcastId': subscription.id,
      'title': subscription.title,
      'autoDownloadEnabled': subscription.autoDownload,
      'inspected': pending.length,
      'created': created,
      'skipped': skipped,
    });

    return AutoDownloadEnqueueResult(
      inspected: pending.length,
      created: created,
      skipped: skipped,
    );
  }
}
