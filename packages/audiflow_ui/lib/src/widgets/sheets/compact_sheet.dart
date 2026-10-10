import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';

/// Shows a modal bottom sheet capped at [maxWidth] and placed at
/// [alignment] on screens wider than that.
///
/// Flutter's own `constraints` option always centers the capped sheet, so
/// this route spans the screen with a transparent surface and draws the
/// visible card itself. Taps on the transparent area beside the card
/// dismiss it, as a barrier tap would. On screens no wider than
/// [maxWidth] it looks like a regular full-width sheet.
Future<T?> showCompactSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  AlignmentDirectional alignment = AlignmentDirectional.bottomCenter,
  double maxWidth = LayoutConstants.contentMaxWidth,
  bool showDragHandle = true,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    elevation: 0,
    // Unbounded on purpose: CompactSheet does the capping and placement.
    constraints: const BoxConstraints(),
    builder: (sheetContext) => CompactSheet(
      alignment: alignment,
      maxWidth: maxWidth,
      showDragHandle: showDragHandle,
      child: builder(sheetContext),
    ),
  );
}

/// The visible card of [showCompactSheet].
class CompactSheet extends StatelessWidget {
  const CompactSheet({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.bottomCenter,
    this.maxWidth = LayoutConstants.contentMaxWidth,
    this.showDragHandle = true,
  });

  /// Gap between a start- or end-aligned card and the screen edge; matches
  /// the mini player's inset so a sheet opened from it lines up above it.
  static const double edgeGap = Spacing.sm;

  /// Width for short pickers and control sheets; wider leaves rows of
  /// mostly empty space on a tablet.
  static const double narrowWidth = 400;

  final Widget child;
  final AlignmentDirectional alignment;
  final double maxWidth;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCapped = maxWidth < screenWidth;
    final gap = isCapped && alignment.start != 0 ? edgeGap : 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Align(
          alignment: alignment,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            // Swallows taps so only the area beside the card dismisses.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: _card(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Material(
      color: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.sheet),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) const _DragHandle(),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Mirrors Material 3's sheet drag handle; the route's own handle would
/// sit on the transparent full-width surface instead of the card.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.bottomSheetTheme.dragHandleColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    return SizedBox(
      height: 48,
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
