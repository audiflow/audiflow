import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../menus/action_menu_trigger.dart';

/// 44px white circular button floating over content (redesign 3.3),
/// typically the back button of a detail screen.
class FloatingNavButton extends StatelessWidget {
  const FloatingNavButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @visibleForTesting
  static const Key surfaceKey = ValueKey('floatingNavButtonSurface');

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox.square(
      dimension: Spacing.minTouchTarget,
      child: DecoratedBox(
        key: surfaceKey,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.floating,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: _FloatingIconButton(
            icon: icon,
            tooltip: tooltip,
            onPressed: onPressed,
            color: colors.ink,
          ),
        ),
      ),
    );
  }
}

/// One action inside [FloatingNavActions].
@immutable
class FloatingNavAction {
  const FloatingNavAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : onOpenMenu = null;

  /// A button that opens a menu on a tap, or on a press-and-hold that
  /// slides to an item (see [ActionMenuTrigger]).
  const FloatingNavAction.menu({
    required this.icon,
    required this.tooltip,
    required ActionMenuOpener this.onOpenMenu,
  }) : onPressed = null;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final ActionMenuOpener? onOpenMenu;
}

/// White pill grouping icon buttons on the trailing side of a floating
/// navigation bar (redesign 3.3), e.g. [search | settings | more].
class FloatingNavActions extends StatelessWidget {
  const FloatingNavActions({super.key, required this.actions});

  @visibleForTesting
  static const Key surfaceKey = ValueKey('floatingNavActionsSurface');

  final List<FloatingNavAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorders.pill,
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppBorders.pill,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: Spacing.minTouchTarget,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in actions)
                if (action.onOpenMenu case final onOpenMenu?)
                  ActionMenuTrigger(
                    onOpen: onOpenMenu,
                    builder: (context, open) => _FloatingIconButton(
                      icon: action.icon,
                      tooltip: action.tooltip,
                      onPressed: open,
                      color: colors.ink,
                    ),
                  )
                else
                  _FloatingIconButton(
                    icon: action.icon,
                    tooltip: action.tooltip,
                    onPressed: action.onPressed,
                    color: colors.ink,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      color: color,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: Spacing.minTouchTarget,
        height: Spacing.minTouchTarget,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
