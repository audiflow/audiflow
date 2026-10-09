import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Outlined pill naming the current choice; tapping it opens a menu of the
/// choices anchored under the pill, with the current one in `accent`.
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
    return Material(
      color: colors.surface,
      shape: StadiumBorder(side: BorderSide(color: colors.outline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _hasChoices ? () => _showMenu(context) : null,
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

  Future<void> _showMenu(BuildContext context) async {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final bottomLeft = box.localToGlobal(
      box.size.bottomLeft(Offset.zero),
      ancestor: overlay,
    );
    final colors = AppColors.of(context);
    final selectedStyle = AppTextStyles.body.copyWith(
      color: colors.accent,
      fontWeight: FontWeight.w600,
    );
    // The menu returns an index so choices without value equality (or
    // nullable ones) still round-trip.
    final chosen = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(
        bottomLeft & Size(box.size.width, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final (index, choice) in choices.indexed)
          PopupMenuItem(
            value: index,
            child: Text(
              labelOf(choice),
              style: _matches(choice) ? selectedStyle : null,
            ),
          ),
      ],
    );
    if (chosen == null || !context.mounted) return;
    final choice = choices[chosen];
    if (!_matches(choice)) {
      HapticsScope.of(context).play(HapticToken.selection);
    }
    onSelected(choice);
  }
}
