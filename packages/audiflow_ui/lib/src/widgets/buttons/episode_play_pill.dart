import 'package:flutter/material.dart';

/// Outlined pill containing a leading state visual and a label.
///
/// State precedence (top wins):
/// 1. `isLoading` -> indeterminate spinner.
/// 2. `isCompleted` -> `check_circle_outline`, muted.
/// 3. `isPlaying` -> progress ring with pause icon.
/// 4. `isInProgress` -> progress ring with play icon.
/// 5. otherwise -> filled play circle.
///
/// `progressFraction` is consumed only by the ring states. It is silently
/// clamped to `[0.0, 1.0]`. When null the ring renders the value as 0.
class EpisodePlayPill extends StatelessWidget {
  const EpisodePlayPill({
    super.key,
    required this.label,
    required this.isPlaying,
    required this.isLoading,
    required this.isCompleted,
    required this.isInProgress,
    this.progressFraction,
    this.onPressed,
  });

  final String label;
  final bool isPlaying;
  final bool isLoading;
  final bool isCompleted;
  final bool isInProgress;
  final double? progressFraction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foreground = isCompleted
        ? colorScheme.onSurfaceVariant
        : colorScheme.primary;
    final borderColor = isCompleted
        ? colorScheme.outlineVariant
        : colorScheme.outline;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Material(
        color: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: _buildLeading(foreground),
                ),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(Color color) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    if (isCompleted) {
      return Icon(Icons.check_circle_outline, size: 20, color: color);
    }
    if (isPlaying || isInProgress) {
      final raw = progressFraction ?? 0.0;
      final clamped = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0).toDouble();
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: 2,
              color: color,
              backgroundColor: color.withValues(alpha: 0.18),
            ),
          ),
          Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 12,
            color: color,
          ),
        ],
      );
    }
    return Icon(Icons.play_circle_filled, size: 20, color: color);
  }
}
