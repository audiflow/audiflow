import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// iOS-style segmented control (redesign 4.2 sticky bar): equal-width
/// segments on a sunken pill track, the selected one on a sliding
/// `surface` thumb.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  static const double height = 36;
  static const double _inset = 3;

  @visibleForTesting
  static const Key trackKey = ValueKey('segmentedControlTrack');

  @visibleForTesting
  static const Key thumbKey = ValueKey('segmentedControlThumb');

  /// Values with their labels, in display order.
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final index = segments.indexWhere((segment) => segment.$1 == selected);
    return DecoratedBox(
      key: trackKey,
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: AppBorders.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.all(_inset),
        child: SizedBox(
          height: height - _inset * 2,
          child: Stack(
            children: [
              if (0 <= index) _thumb(colors, index),
              Row(
                children: [
                  for (final (value, label) in segments)
                    Expanded(child: _segment(colors, value, label)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(AppColors colors, int index) {
    // Alignment runs -1..1 across the track; segment i's center sits at
    // the matching fraction once the thumb is one segment wide.
    final count = segments.length;
    final x = count == 1 ? 0.0 : -1 + 2 * index / (count - 1);
    return AnimatedAlign(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment(x, 0),
      child: FractionallySizedBox(
        widthFactor: 1 / count,
        heightFactor: 1,
        child: DecoratedBox(
          key: thumbKey,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppBorders.pill,
            boxShadow: AppShadows.raised,
          ),
        ),
      ),
    );
  }

  Widget _segment(AppColors colors, T value, String label) {
    final isSelected = value == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? colors.ink : colors.inkSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
