import 'package:flutter/material.dart';

import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// Large, left-aligned title for top-level tabs (redesign section 1).
///
/// Sits in the scroll content rather than an app bar, so callers place it
/// under the status bar themselves (e.g. inside a `SafeArea`).
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.title, {super.key, this.trailing});

  final String title;

  /// Optional control aligned with the title's baseline row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.sm,
        Spacing.screenHorizontal,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayTitle.copyWith(color: colors.ink),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Section title row with an optional [count] beside the title and an
/// optional trailing control (redesign 4.1).
///
/// The trailing control gets at most [maxTrailingShare] of the row, so a
/// large text size squeezes it (a trailing `Row` can let its labels
/// ellipsize) instead of overflowing, and the title always keeps a share.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;

  /// Item count shown after the title in a quieter style.
  final int? count;

  final Widget? trailing;

  static const double maxTrailingShare = 0.75;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: SizedBox(
        height: Spacing.minTouchTarget,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(child: _title(AppColors.of(context))),
              if (trailing case final trailing?)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * maxTrailingShare,
                  ),
                  child: trailing,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
            ),
          ),
        ),
        if (count case final count?) ...[
          const SizedBox(width: Spacing.xs + Spacing.xxs),
          Text(
            '$count',
            style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
          ),
        ],
      ],
    );
  }
}
