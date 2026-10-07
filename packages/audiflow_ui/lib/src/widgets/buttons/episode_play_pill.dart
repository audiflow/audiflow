import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// Play pill (redesign section 3.2): a 32px rounded pill with a state
/// glyph and a time label.
///
/// State precedence (top wins):
/// 1. `isLoading` -> indeterminate spinner.
/// 2. `isCompleted` -> check glyph, `inkTertiary`.
/// 3. `isPlaying` -> pause glyph, `accent` on `accentTint`.
/// 4. otherwise -> play glyph, `ink` on `surfaceMuted`.
///
/// The pill never shows progress; partially played rows show it with a
/// bottom-edge line instead (see `BottomEdgeProgress`). The tappable
/// area extends to 44px tall around the 32px visual.
class EpisodePlayPill extends StatelessWidget {
  const EpisodePlayPill({
    super.key,
    required this.label,
    required this.isPlaying,
    required this.isLoading,
    required this.isCompleted,
    this.onPressed,
  });

  static const double height = 32;

  @visibleForTesting
  static const Key surfaceKey = ValueKey('episodePlayPillSurface');

  final String label;
  final bool isPlaying;
  final bool isLoading;
  final bool isCompleted;
  final VoidCallback? onPressed;

  bool get _showsPlaying => isPlaying && !isCompleted && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = _foreground(colors);

    // The outer detector covers the margin between the 32px visual and
    // the 44px touch target; taps on the visual go to its InkWell.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Spacing.minTouchTarget),
        child: Center(
          widthFactor: 1,
          child: SizedBox(
            key: surfaceKey,
            height: height,
            child: Material(
              color: _showsPlaying ? colors.accentTint : colors.surfaceMuted,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(onTap: onPressed, child: _content(foreground)),
            ),
          ),
        ),
      ),
    );
  }

  Color _foreground(AppColors colors) {
    if (isCompleted && !isLoading) return colors.inkTertiary;
    if (_showsPlaying) return colors.accent;
    return colors.ink;
  }

  Widget _content(Color foreground) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 8,
        end: label.isEmpty ? 8 : 12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(dimension: 18, child: _glyph(foreground)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.tabular(
                  AppTextStyles.meta.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _glyph(Color color) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    final icon = isCompleted
        ? Icons.check_rounded
        : isPlaying
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    return Icon(icon, size: 18, color: color);
  }
}
