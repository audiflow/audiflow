import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../haptics/haptic_token.dart';
import '../../haptics/haptics_scope.dart';
import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import 'action_menu_trigger.dart';
import 'menu_overlay.dart';

/// One action in an [ActionMenu], shown as a top tile or an item row.
class ActionMenuEntry {
  const ActionMenuEntry({
    this.icon,
    required this.label,
    required this.onSelected,
    this.destructive = false,
    this.enabled = true,
    this.checked = false,
  });

  /// Required for tiles; optional for item rows.
  final IconData? icon;
  final String label;
  final VoidCallback onSelected;

  /// Drawn in the `error` color, for actions that discard something
  /// (e.g. removing a download).
  final bool destructive;

  /// A disabled entry is drawn faded and cannot be chosen.
  final bool enabled;

  /// Marks the current choice of a selector, in `accent` with a check.
  final bool checked;
}

/// Where an [ActionMenu] appears on screen.
sealed class ActionMenuPlacement {
  const ActionMenuPlacement();

  /// The `…` popover's spot: the screen's top-right, just below [top]
  /// (usually the floating navigation's height). Fixed width.
  const factory ActionMenuPlacement.topRight({required double top}) =
      _TopRightPlacement;

  /// Under [anchor] (the trigger's context), aligned to whichever of its
  /// edges keeps the menu on screen; above it when there is no room below.
  /// Sized to its entries.
  factory ActionMenuPlacement.below(BuildContext anchor) {
    final box = anchor.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return const _AnchoredPlacement(Rect.zero);
    }
    return _AnchoredPlacement(box.localToGlobal(Offset.zero) & box.size);
  }

  /// The point the opening animation grows from.
  Alignment scaleOrigin(Size screen);
}

class _TopRightPlacement extends ActionMenuPlacement {
  const _TopRightPlacement({required this.top});

  final double top;

  @override
  Alignment scaleOrigin(Size screen) => Alignment.topRight;
}

class _AnchoredPlacement extends ActionMenuPlacement {
  const _AnchoredPlacement(this.anchor);

  final Rect anchor;

  @override
  Alignment scaleOrigin(Size screen) {
    if (screen.isEmpty) return Alignment.topCenter;
    return Alignment(
      anchor.center.dx / screen.width * 2 - 1,
      // The vertical center, since the menu may open above the anchor.
      anchor.center.dy / screen.height * 2 - 1,
    );
  }
}

/// Opens an [ActionMenu] at [placement].
///
/// Pass the [drag] an [ActionMenuTrigger] hands over when the menu was
/// opened by pressing and holding: the menu then highlights the entry under
/// the finger and chooses it when the finger lifts there. Lifting anywhere
/// else leaves the menu open for a tap.
///
/// The menu closes before the chosen entry runs, so an entry that opens a
/// sheet or dialog does not stack it above the popover.
Future<void> showActionMenu({
  required BuildContext context,
  required ActionMenuPlacement placement,
  List<ActionMenuEntry> tiles = const [],
  List<List<ActionMenuEntry>> sections = const [],
  ActionMenuDrag? drag,
}) async {
  final selected = await showMenuOverlay<ActionMenuEntry>(
    context: context,
    scaleOrigin: placement.scaleOrigin(MediaQuery.sizeOf(context)),
    builder: (context, choose) => ActionMenu(
      placement: placement,
      tiles: tiles,
      sections: sections,
      drag: drag,
      onChosen: choose,
    ),
  );
  selected?.onSelected();
}

/// Popover body: a row of tiles for the primary actions, then groups of
/// item rows separated by hairlines. Use [showActionMenu] to present it.
class ActionMenu extends StatefulWidget {
  const ActionMenu({
    super.key,
    required this.placement,
    required this.tiles,
    required this.sections,
    required this.onChosen,
    this.drag,
  });

  static const double width = 300;

  /// Narrowest a menu sized to its entries gets.
  static const double minAnchoredWidth = 200;

  @visibleForTesting
  static const Key surfaceKey = ValueKey('actionMenuSurface');

  final ActionMenuPlacement placement;
  final List<ActionMenuEntry> tiles;
  final List<List<ActionMenuEntry>> sections;
  final ActionMenuDrag? drag;
  final ValueChanged<ActionMenuEntry> onChosen;

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  late List<ActionMenuEntry> _entries;
  late List<GlobalKey> _entryKeys;
  final GlobalKey _viewportKey = GlobalKey();
  int? _highlighted;

  @override
  void initState() {
    super.initState();
    _indexEntries();
    _follow(widget.drag);
  }

  @override
  void didUpdateWidget(ActionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tiles != widget.tiles ||
        oldWidget.sections != widget.sections) {
      _indexEntries();
    }
    if (oldWidget.drag != widget.drag) {
      oldWidget.drag?.removeListener(_onDrag);
      _follow(widget.drag);
    }
  }

  @override
  void dispose() {
    widget.drag?.removeListener(_onDrag);
    super.dispose();
  }

  void _indexEntries() {
    _entries = [...widget.tiles, ...widget.sections.expand((s) => s)];
    _entryKeys = List.generate(_entries.length, (_) => GlobalKey());
    _highlighted = null;
  }

  void _follow(ActionMenuDrag? drag) {
    if (drag == null || drag.phase != ActionMenuDragPhase.moving) return;
    drag.addListener(_onDrag);
    // Entries have no layout until the first frame; the finger may already
    // rest on one.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onDrag());
  }

  void _onDrag() {
    final drag = widget.drag;
    if (!mounted || drag == null) return;
    switch (drag.phase) {
      case ActionMenuDragPhase.moving:
        _highlight(_entryIndexAt(drag.position));
      case ActionMenuDragPhase.released:
        drag.removeListener(_onDrag);
        final index = _entryIndexAt(drag.position);
        if (index == null) {
          _highlight(null);
        } else {
          drag.markChosenOnRelease();
          _choose(_entries[index]);
        }
      case ActionMenuDragPhase.cancelled:
        drag.removeListener(_onDrag);
        _highlight(null);
    }
  }

  int? _entryIndexAt(Offset globalPosition) {
    // Rows scrolled out of a tall menu still have layout beyond its clip.
    if (!_contains(_viewportKey, globalPosition)) return null;
    for (final (index, key) in _entryKeys.indexed) {
      if (_entries[index].enabled && _contains(key, globalPosition)) {
        return index;
      }
    }
    return null;
  }

  bool _contains(GlobalKey key, Offset globalPosition) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final local = box.globalToLocal(globalPosition);
    return (Offset.zero & box.size).contains(local);
  }

  void _highlight(int? index) {
    if (index == _highlighted) return;
    setState(() => _highlighted = index);
    if (index != null) HapticsScope.of(context).play(HapticToken.selection);
  }

  void _choose(ActionMenuEntry entry) => widget.onChosen(entry);

  @override
  Widget build(BuildContext context) {
    return switch (widget.placement) {
      _TopRightPlacement(:final top) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.md,
            top,
            Spacing.screenHorizontal - Spacing.xs,
            Spacing.md,
          ),
          child: SizedBox(width: ActionMenu.width, child: _surface(context)),
        ),
      ),
      _AnchoredPlacement(:final anchor) => CustomSingleChildLayout(
        delegate: _AnchoredMenuLayout(
          anchor: anchor,
          // The view's own insets: the menu is laid out in screen
          // coordinates, while the padding inherited from the trigger may
          // already be consumed by a SafeArea around it.
          safeArea: MediaQueryData.fromView(View.of(context)).padding,
        ),
        child: IntrinsicWidth(child: _surface(context)),
      ),
    };
  }

  Widget _surface(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      key: ActionMenu.surfaceKey,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorders.xl,
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppBorders.xl,
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          key: _viewportKey,
          padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _groups(colors),
          ),
        ),
      ),
    );
  }

  List<Widget> _groups(AppColors colors) {
    // Entries are numbered in the order _indexEntries flattened them.
    var next = 0;
    List<int> take(int count) {
      final start = next;
      next += count;
      return [for (var index = start; index < next; index++) index];
    }

    final groups = <Widget>[
      if (widget.tiles.isNotEmpty)
        _TileRow(tiles: [for (final i in take(widget.tiles.length)) _tile(i)]),
      for (final section in widget.sections)
        if (section.isNotEmpty)
          Column(children: [for (final i in take(section.length)) _item(i)]),
    ];
    return [
      for (final (index, group) in groups.indexed) ...[
        if (0 < index)
          Divider(height: Spacing.md + 1, thickness: 1, color: colors.hairline),
        group,
      ],
    ];
  }

  Widget _tile(int index) => _Tile(
    key: _entryKeys[index],
    entry: _entries[index],
    highlighted: index == _highlighted,
    onTap: () => _choose(_entries[index]),
  );

  Widget _item(int index) => _Item(
    key: _entryKeys[index],
    entry: _entries[index],
    highlighted: index == _highlighted,
    onTap: () => _choose(_entries[index]),
  );
}

/// Puts an anchored menu under its anchor, or above it when there is no
/// room below, keeping it inside the safe area.
class _AnchoredMenuLayout extends SingleChildLayoutDelegate {
  const _AnchoredMenuLayout({required this.anchor, required this.safeArea});

  static const double _gap = Spacing.xs;
  static const double _margin = Spacing.sm;

  final Rect anchor;
  final EdgeInsets safeArea;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = math.min(
      ActionMenu.width,
      constraints.maxWidth - _margin * 2,
    );
    return BoxConstraints(
      minWidth: math.min(ActionMenu.minAnchoredWidth, maxWidth),
      maxWidth: maxWidth,
      maxHeight: math.max(
        0,
        constraints.maxHeight - safeArea.vertical - _margin * 2,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final leftAligned = anchor.center.dx < size.width / 2;
    final left = leftAligned ? anchor.left : anchor.right - childSize.width;
    return Offset(
      _clamp(left, _margin, size.width - _margin - childSize.width),
      _top(size, childSize),
    );
  }

  double _top(Size size, Size childSize) {
    final minTop = safeArea.top + _margin;
    final maxTop = size.height - safeArea.bottom - _margin - childSize.height;
    final below = anchor.bottom + _gap;
    if (below <= maxTop) return math.max(minTop, below);
    final above = anchor.top - _gap - childSize.height;
    if (minTop <= above) return above;
    return _clamp(below, minTop, maxTop);
  }

  // Unlike num.clamp, tolerates max < min (a menu wider or taller than the
  // room) by favoring min, so the menu's start stays on screen.
  double _clamp(double value, double min, double max) =>
      math.max(min, math.min(value, max));

  @override
  bool shouldRelayout(_AnchoredMenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor || safeArea != oldDelegate.safeArea;
}

class _TileRow extends StatelessWidget {
  const _TileRow({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (0 < index) const SizedBox(width: Spacing.sm),
          Expanded(child: tile),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.entry,
    required this.highlighted,
    required this.onTap,
  });

  final ActionMenuEntry entry;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = entry.enabled ? colors.ink : colors.inkTertiary;
    return Material(
      color: highlighted ? colors.outline : colors.surfaceMuted,
      borderRadius: AppBorders.lg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: entry.enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm + Spacing.xs,
            horizontal: Spacing.xs,
          ),
          child: Column(
            children: [
              Icon(entry.icon, size: 22, color: color),
              const SizedBox(height: Spacing.xs + Spacing.xxs),
              Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
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

class _Item extends StatelessWidget {
  const _Item({
    super.key,
    required this.entry,
    required this.highlighted,
    required this.onTap,
  });

  final ActionMenuEntry entry;
  final bool highlighted;
  final VoidCallback onTap;

  Color _color(BuildContext context, AppColors colors) {
    if (!entry.enabled) return colors.inkTertiary;
    if (entry.destructive) return Theme.of(context).colorScheme.error;
    if (entry.checked) return colors.accent;
    return colors.ink;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = _color(context, colors);
    return Ink(
      decoration: BoxDecoration(
        color: highlighted ? colors.surfaceSunken : null,
        borderRadius: AppBorders.md,
      ),
      child: InkWell(
        borderRadius: AppBorders.md,
        onTap: entry.enabled ? onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: Spacing.minTouchTarget + Spacing.xs,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + Spacing.xs,
              vertical: Spacing.sm,
            ),
            child: _content(color),
          ),
        ),
      ),
    );
  }

  Widget _content(Color color) {
    return Row(
      children: [
        if (entry.icon case final icon?) ...[
          Icon(icon, size: 22, color: color),
          const SizedBox(width: Spacing.md),
        ],
        Expanded(
          child: Text(
            entry.label,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: entry.checked ? FontWeight.w600 : null,
            ),
          ),
        ),
        if (entry.checked) ...[
          const SizedBox(width: Spacing.sm),
          Icon(Icons.check_rounded, size: 20, color: color),
        ],
      ],
    );
  }
}
