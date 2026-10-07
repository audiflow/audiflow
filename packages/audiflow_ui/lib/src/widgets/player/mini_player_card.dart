import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import '../indicators/progress_line.dart';

/// Floating mini player card above the tab bar (redesign section 3.5).
///
/// Purely presentational: the app supplies the artwork and the action
/// buttons (skip forward, play/pause), and reacts to [onTap] by opening
/// the full player. No remaining-time text, by spec.
class MiniPlayerCard extends StatelessWidget {
  const MiniPlayerCard({
    super.key,
    required this.artwork,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.progress,
    this.onTap,
    this.semanticLabel,
  });

  static const double height = 64;
  static const double artworkSize = 44;

  /// Horizontal inset so the card floats clear of the screen edges.
  static const double margin = Spacing.sm;

  @visibleForTesting
  static const Key surfaceKey = ValueKey('miniPlayerCardSurface');

  final Widget artwork;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  /// Playback progress in `[0, 1]`; the line is hidden until it starts.
  final double? progress;
  final VoidCallback? onTap;

  /// Label for the card as a whole, e.g. "Now playing: title, podcast".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(margin, 0, margin, margin),
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: DecoratedBox(
          key: surfaceKey,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppBorders.card,
            boxShadow: AppShadows.floating,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: AppBorders.card,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: BottomEdgeProgress(
                fraction: progress,
                fillColor: colors.brand,
                child: SizedBox(height: height, child: _content(colors)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppColors colors) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, end: Spacing.xs),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppBorders.sm,
            child: SizedBox.square(dimension: artworkSize, child: artwork),
          ),
          const SizedBox(width: Spacing.md - Spacing.xs),
          Expanded(child: _labels(colors)),
          ...actions,
        ],
      ),
    );
  }

  Widget _labels(AppColors colors) {
    return ExcludeSemantics(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
          ),
        ],
      ),
    );
  }
}
