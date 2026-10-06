import 'package:logger/logger.dart';

import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/services/feed_sync_diagnostic.dart';
import '../../subscription/extensions/subscription_extensions.dart';
import '../../subscription/models/subscriptions.dart';
import '../models/download_origin.dart';
import '../repositories/download_repository.dart';
import 'auto_download_pause_service.dart';

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

  /// Episodes skipped (duplicate active task, missing audio URL, older
  /// than the keep count allows, or auto-download disabled on the
  /// subscription).
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
    required this._episodeRepo,
    required this._downloadRepo,
    this._pauseService,
    this._logger,
    FeedSyncDiagnosticSink? onDiagnostic,
  }) : _onDiagnostic = onDiagnostic ?? noopFeedSyncDiagnosticSink;

  final EpisodeRepository _episodeRepo;
  final DownloadRepository _downloadRepo;

  /// Tracks inactivity; null disables the inactivity pause.
  final AutoDownloadPauseService? _pauseService;
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
  ///
  /// Only the newest pending episodes up to the podcast's keep count
  /// (falling back to [defaultKeepCount]) are enqueued; older ones are just
  /// marked processed, so a long-unsynced feed does not download episodes
  /// that retention would immediately delete.
  Future<AutoDownloadEnqueueResult> enqueueForSubscription(
    Subscription subscription, {
    required bool wifiOnly,
    required int defaultKeepCount,
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

    final limit = _creationLimit(subscription, defaultKeepCount);
    var created = 0;
    var skipped = 0;
    final processedIds = <int>[];

    // A paused podcast is treated like one with auto-download off: its
    // episodes are still marked processed so resuming does not backfill.
    final isActive =
        subscription.autoDownload && subscription.autoDownloadPausedAt == null;
    // Newest first, counting only tasks actually created, so an episode
    // without audio or with an existing download does not use up a slot.
    for (final episode in _newestFirst(pending)) {
      processedIds.add(episode.id);

      if (!isActive) {
        skipped++;
        continue;
      }
      if (episode.audioUrl.isEmpty || limit <= created) {
        skipped++;
        continue;
      }

      try {
        final task = await _downloadRepo.createDownload(
          episodeId: episode.id,
          audioUrl: episode.audioUrl,
          wifiOnly: wifiOnly,
          origin: DownloadOrigin.auto,
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
    await _pauseService?.recordAutoDownloads(subscription.id, created);

    _onDiagnostic('feed-sync:auto-download', {
      'podcastId': subscription.id,
      'title': subscription.title,
      'autoDownloadEnabled': subscription.autoDownload,
      'autoDownloadPaused': subscription.autoDownloadPausedAt != null,
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

  /// Tasks one pass may create: the keep count, further capped by what the
  /// inactivity pause still allows.
  int _creationLimit(Subscription subscription, int defaultKeepCount) {
    final keepCount = subscription.effectiveKeepCount(defaultKeepCount);
    final allowance = _pauseService?.remainingAllowance(subscription);
    if (allowance == null || keepCount < allowance) return keepCount;
    return allowance;
  }

  /// [episodes] most recently published first. Episodes without a publish
  /// date rank oldest; ties keep their original order.
  static List<Episode> _newestFirst(List<Episode> episodes) {
    final indexed = episodes.indexed.toList()
      ..sort((a, b) {
        final byDate = _comparePublishedDescending(a.$2, b.$2);
        return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
      });
    return [for (final entry in indexed) entry.$2];
  }

  static int _comparePublishedDescending(Episode a, Episode b) {
    final aDate = a.publishedAt;
    final bDate = b.publishedAt;
    if (aDate == null) return bDate == null ? 0 : 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }
}
