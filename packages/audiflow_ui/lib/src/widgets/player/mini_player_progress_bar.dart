import 'package:flutter/material.dart';

/// A thin progress bar for the mini player.
///
/// Displays playback progress as a linear indicator at the top of the
/// mini player. Shows both playback progress and buffered progress.
class MiniPlayerProgressBar extends StatelessWidget {
  const MiniPlayerProgressBar({
    super.key,
    required this.progress,
    this.bufferedProgress = 0.0,
    this.height = 2.0,
  });

  /// Current playback progress from 0.0 to 1.0.
  final double progress;

  /// Buffered progress from 0.0 to 1.0.
  final double bufferedProgress;

  /// Height of the progress bar.
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Background track
          Container(height: height, color: colorScheme.surfaceContainerHighest),
          // Buffered progress
          FractionallySizedBox(
            widthFactor: bufferedProgress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          // Playback progress
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(height: height, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
