import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// One action in an [ActionMenu], shown as a top tile or an item row.
class ActionMenuEntry {
  const ActionMenuEntry({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  /// Drawn in the `error` color, for actions that discard something
  /// (e.g. removing a download).
  final bool destructive;
}

/// Opens the `…` popover (redesign 4.2) anchored to the screen's top-right,
/// just below [top] (usually the floating navigation's height).
///
/// The menu closes before the chosen entry runs, so an entry that opens a
/// sheet or dialog does not stack it above the popover.
Future<void> showActionMenu({
  required BuildContext context,
  required double top,
  List<ActionMenuEntry> tiles = const [],
  List<List<ActionMenuEntry>> sections = const [],
}) async {
  final selected = await showGeneralDialog<ActionMenuEntry>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (context, _, _) =>
        ActionMenu(top: top, tiles: tiles, sections: sections),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(curved),
          alignment: Alignment.topRight,
          child: child,
        ),
      );
    },
  );
  selected?.onSelected();
}

/// Popover body: a row of tiles for the primary actions, then groups of
/// item rows separated by hairlines. Use [showActionMenu] to present it.
class ActionMenu extends StatelessWidget {
  const ActionMenu({
    super.key,
    required this.top,
    required this.tiles,
    required this.sections,
  });

  static const double width = 300;

  @visibleForTesting
  static const Key surfaceKey = ValueKey('actionMenuSurface');

  final double top;
  final List<ActionMenuEntry> tiles;
  final List<List<ActionMenuEntry>> sections;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final groups = <Widget>[
      if (tiles.isNotEmpty) _TileRow(tiles: tiles),
      for (final section in sections)
        if (section.isNotEmpty) _ItemGroup(items: section),
    ];
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.md,
          top,
          Spacing.screenHorizontal - Spacing.xs,
          Spacing.md,
        ),
        child: DecoratedBox(
          key: surfaceKey,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppBorders.xl,
            boxShadow: AppShadows.floating,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: AppBorders.xl,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < groups.length; index++) ...[
                      if (0 < index)
                        Divider(
                          height: Spacing.md + 1,
                          thickness: 1,
                          color: colors.hairline,
                        ),
                      groups[index],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TileRow extends StatelessWidget {
  const _TileRow({required this.tiles});

  final List<ActionMenuEntry> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < tiles.length; index++) ...[
          if (0 < index) const SizedBox(width: Spacing.sm),
          Expanded(child: _Tile(entry: tiles[index])),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.entry});

  final ActionMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.surfaceMuted,
      borderRadius: AppBorders.lg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm + Spacing.xs,
            horizontal: Spacing.xs,
          ),
          child: Column(
            children: [
              Icon(entry.icon, size: 22, color: colors.ink),
              const SizedBox(height: Spacing.xs + Spacing.xxs),
              Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemGroup extends StatelessWidget {
  const _ItemGroup({required this.items});

  final List<ActionMenuEntry> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    return Column(
      children: [
        for (final item in items)
          _item(context, item, item.destructive ? error : colors.ink),
      ],
    );
  }

  Widget _item(BuildContext context, ActionMenuEntry item, Color color) {
    return InkWell(
      borderRadius: AppBorders.md,
      onTap: () => Navigator.of(context).pop(item),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: Spacing.minTouchTarget + Spacing.xs,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm + Spacing.xs,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.body.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
