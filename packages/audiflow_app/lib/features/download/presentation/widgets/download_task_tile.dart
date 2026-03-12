import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Tile displaying a download task with progress and actions.
class DownloadTaskTile extends StatelessWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    required this.episodeTitle,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
    this.onDelete,
  });

  final DownloadTask task;
  final String episodeTitle;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  double get _progress {
    final total = task.totalBytes;
    if (total == null || total == 0) return 0;
    return task.downloadedBytes / total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = DownloadStatus.fromDbValue(task.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          _StatusIcon(status: status, colorScheme: colorScheme),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episodeTitle,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (status is DownloadStatusDownloading)
                  LinearProgressIndicator(value: _progress, minHeight: 3)
                else
                  Text(
                    _statusLabel(status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: status is DownloadStatusFailed
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ..._buildActions(status),
        ],
      ),
    );
  }

  String _statusLabel(DownloadStatus status) {
    return switch (status) {
      DownloadStatusPending() => 'Pending',
      DownloadStatusDownloading() => 'Downloading',
      DownloadStatusPaused() => 'Paused',
      DownloadStatusCompleted() => 'Completed',
      DownloadStatusFailed() => task.lastError ?? 'Failed',
      DownloadStatusCancelled() => 'Cancelled',
    };
  }

  List<Widget> _buildActions(DownloadStatus status) {
    return switch (status) {
      DownloadStatusDownloading() => [
        IconButton(icon: const Icon(Icons.pause, size: 20), onPressed: onPause),
      ],
      DownloadStatusPaused() => [
        IconButton(
          icon: const Icon(Icons.play_arrow, size: 20),
          onPressed: onResume,
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onCancel,
        ),
      ],
      DownloadStatusPending() => [
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onCancel,
        ),
      ],
      DownloadStatusFailed() || DownloadStatusCancelled() => [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: onRetry,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
      ],
      DownloadStatusCompleted() => [
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
      ],
    };
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.colorScheme});

  final DownloadStatus status;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      DownloadStatusDownloading() => (Icons.downloading, colorScheme.primary),
      DownloadStatusPending() => (Icons.schedule, colorScheme.onSurfaceVariant),
      DownloadStatusPaused() => (Icons.pause_circle, colorScheme.tertiary),
      DownloadStatusCompleted() => (Icons.check_circle, colorScheme.primary),
      DownloadStatusFailed() => (Icons.error, colorScheme.error),
      DownloadStatusCancelled() => (Icons.cancel, colorScheme.onSurfaceVariant),
    };

    return Icon(icon, color: color, size: 24);
  }
}
