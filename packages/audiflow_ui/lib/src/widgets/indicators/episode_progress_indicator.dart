import 'package:flutter/material.dart';

/// Displays episode progress state: unplayed, in-progress, or completed.
///
/// Shows "X min left" for in-progress, checkmark for completed,
/// and nothing for unplayed episodes.
class EpisodeProgressIndicator extends StatelessWidget {
  const EpisodeProgressIndicator({
    super.key,
    required this.isCompleted,
    required this.isInProgress,
    this.remainingTimeFormatted,
  });

  final bool isCompleted;
  final bool isInProgress;
  final String? remainingTimeFormatted;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildCompleted(context);
    }
    if (isInProgress && remainingTimeFormatted != null) {
      return _buildInProgress(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCompleted(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          'Played',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildInProgress(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      remainingTimeFormatted!,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.tertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
