import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Summary of download state for a set of episode IDs.
class BatchDownloadState {
  const BatchDownloadState({
    required this.downloadableCount,
    required this.activeTaskIds,
    required this.pausedTaskIds,
  });

  /// Episodes with no download task, or with failed/cancelled status.
  final int downloadableCount;

  /// Task IDs that are pending or downloading.
  final List<int> activeTaskIds;

  /// Task IDs that are paused.
  final List<int> pausedTaskIds;

  bool get hasDownloadable => 0 < downloadableCount;
  bool get hasActive => activeTaskIds.isNotEmpty;
  bool get hasPaused => pausedTaskIds.isNotEmpty;
}

/// Computes download menu state for a set of episode IDs.
///
/// [allTasks] should come from watching `allDownloadsProvider`.
BatchDownloadState computeBatchDownloadState({
  required List<int> episodeIds,
  required List<DownloadTask> allTasks,
}) {
  final tasksByEpisode = <int, DownloadTask>{};
  for (final task in allTasks) {
    tasksByEpisode[task.episodeId] = task;
  }

  var downloadableCount = 0;
  final activeTaskIds = <int>[];
  final pausedTaskIds = <int>[];

  for (final episodeId in episodeIds) {
    final task = tasksByEpisode[episodeId];
    if (task == null) {
      downloadableCount++;
      continue;
    }
    switch (task.downloadStatus) {
      case DownloadStatusPending():
      case DownloadStatusDownloading():
        activeTaskIds.add(task.id);
      case DownloadStatusPaused():
        pausedTaskIds.add(task.id);
      case DownloadStatusFailed():
      case DownloadStatusCancelled():
        downloadableCount++;
      case DownloadStatusCompleted():
        break;
    }
  }

  return BatchDownloadState(
    downloadableCount: downloadableCount,
    activeTaskIds: activeTaskIds,
    pausedTaskIds: pausedTaskIds,
  );
}

/// Shows confirmation dialog and triggers batch download for the given
/// episode IDs.
Future<void> handleBatchDownload({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> episodeIds,
}) async {
  if (episodeIds.isEmpty) return;

  final l10n = AppLocalizations.of(context);
  final limit = ref.read(batchDownloadLimitProvider);
  final downloadCount = episodeIds.length <= limit ? episodeIds.length : limit;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.downloadAllConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.downloadAllConfirmContent(downloadCount)),
          if (limit < episodeIds.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.downloadAllLimitNote(limit),
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.downloadAllEpisodes),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final downloadService = ref.read(downloadServiceProvider);
  final queued = await downloadService.downloadEpisodes(episodeIds);

  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.downloadAllQueued(queued))),
  );
}

/// Cancels all active (pending/downloading) downloads for the given task IDs.
Future<void> handleBatchCancel({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> taskIds,
}) async {
  if (taskIds.isEmpty) return;

  final downloadService = ref.read(downloadServiceProvider);
  var cancelled = 0;
  for (final taskId in taskIds) {
    await downloadService.cancel(taskId);
    cancelled++;
  }

  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.downloadCancelAllDone(cancelled))),
  );
}

/// Resumes all paused downloads for the given task IDs.
Future<void> handleBatchResume({
  required BuildContext context,
  required WidgetRef ref,
  required List<int> taskIds,
}) async {
  if (taskIds.isEmpty) return;

  final downloadService = ref.read(downloadServiceProvider);
  var resumed = 0;
  for (final taskId in taskIds) {
    await downloadService.resume(taskId);
    resumed++;
  }

  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.downloadResumeAllDone(resumed))));
}
