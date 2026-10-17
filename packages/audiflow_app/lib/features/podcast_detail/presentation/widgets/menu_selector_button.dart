import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Outlined pill naming the current choice; tapping it, or pressing and
/// sliding (see [ActionMenuTrigger]), opens a menu of the choices anchored
/// under the pill, with the current one checked in `accent`.
///
/// With a single choice the pill is a plain label (no chevron, no menu).
class MenuSelectorButton<T> extends StatelessWidget {
  const MenuSelectorButton({
    super.key,
    required this.choices,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.isSelected,
    this.leadingIcon,
  });

  final List<T> choices;
  final T selected;
  final String Function(T choice) labelOf;
  final ValueChanged<T> onSelected;

  /// Matches a choice against [selected]; defaults to `==`.
  final bool Function(T choice)? isSelected;
  final IconData? leadingIcon;

  bool get _hasChoices => 1 < choices.length;

  bool _matches(T choice) => isSelected?.call(choice) ?? choice == selected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ActionMenuTrigger(
      onOpen: _hasChoices ? _showMenu : null,
      builder: (context, open) => Material(
        color: colors.surface,
        shape: StadiumBorder(side: BorderSide(color: colors.outline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: EdgeInsets.only(
                left: leadingIcon == null ? Spacing.md : Spacing.sm,
                right: _hasChoices ? Spacing.sm : Spacing.md,
              ),
              child: _content(colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon case final icon?) ...[
          Icon(icon, size: 18, color: colors.inkSecondary),
          const SizedBox(width: Spacing.xs),
        ],
        Flexible(
          child: Text(
            labelOf(selected),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(color: colors.ink),
          ),
        ),
        if (_hasChoices) ...[
          const SizedBox(width: Spacing.xs),
          Icon(Icons.expand_more_rounded, size: 20, color: colors.inkSecondary),
        ],
      ],
    );
  }

  void _showMenu(BuildContext anchor, ActionMenuDrag? drag) {
    showActionMenu(
      context: anchor,
      placement: ActionMenuPlacement.below(anchor),
      sections: [
        [
          for (final choice in choices)
            ActionMenuEntry(
              label: labelOf(choice),
              checked: _matches(choice),
              onSelected: () => _choose(anchor, drag, choice),
            ),
        ],
      ],
      drag: drag,
    );
  }

  void _choose(BuildContext anchor, ActionMenuDrag? drag, T choice) {
    if (!_matches(choice) && needsSelectionHaptic(drag) && anchor.mounted) {
      HapticsScope.of(anchor).play(HapticToken.selection);
    }
    onSelected(choice);
  }
}
