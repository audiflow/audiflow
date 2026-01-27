import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

/// Displays an icon representing download status.
///
/// Shows different icons based on download state:
/// - Not downloaded: download icon
/// - Pending: clock icon with queue position
/// - Downloading: progress ring
/// - Paused: pause icon
/// - Completed: checkmark
/// - Failed: error icon
class DownloadStatusIcon extends StatelessWidget {
  const DownloadStatusIcon({
    super.key,
    required this.task,
    this.size = 24.0,
    this.onTap,
  });

  /// The download task, or null if not downloaded.
  final DownloadTask? task;

  /// Icon size.
  final double size;

  /// Callback when icon is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (task == null) {
      return _buildIconButton(
        icon: Icons.download_outlined,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return task!.downloadStatus.when(
      pending: () => _buildIconButton(
        icon: Icons.schedule,
        color: colorScheme.onSurfaceVariant,
      ),
      downloading: () => _buildProgressRing(colorScheme),
      paused: () => _buildIconButton(
        icon: Icons.pause_circle_outline,
        color: colorScheme.primary,
      ),
      completed: () => _buildIconButton(
        icon: Icons.check_circle,
        color: colorScheme.primary,
      ),
      failed: () =>
          _buildIconButton(icon: Icons.error_outline, color: colorScheme.error),
      cancelled: () => _buildIconButton(
        icon: Icons.download_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color}) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size + 16, minHeight: size + 16),
    );
  }

  Widget _buildProgressRing(ColorScheme colorScheme) {
    final progress = task!.progress;

    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.pause, size: size * 0.6),
            color: colorScheme.primary,
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: size, minHeight: size),
          ),
        ],
      ),
    );
  }
}
