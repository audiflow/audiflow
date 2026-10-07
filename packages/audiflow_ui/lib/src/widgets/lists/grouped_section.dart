import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/shadows.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import 'settings_row.dart';

/// A grouped list section (redesign principle "grouped lists over
/// cards"): related rows share one rounded `surface`, separated by
/// hairlines, with an optional overline header and a footer note.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.separatorIndent = Spacing.rowHorizontal,
    this.margin = const EdgeInsets.symmetric(
      horizontal: Spacing.screenHorizontal,
    ),
  });

  @visibleForTesting
  static const Key surfaceKey = ValueKey('groupedSectionSurface');

  final List<Widget> children;
  final String? header;
  final String? footer;

  /// Leading inset of the separators. Rows with an icon tile pass
  /// [SettingsRow.separatorIndentWithIcon] so lines start at the text.
  final double separatorIndent;

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) _Header(text: header!, color: colors.inkTertiary),
          _surface(colors),
          if (footer != null) _Footer(text: footer!, color: colors.inkTertiary),
        ],
      ),
    );
  }

  Widget _surface(AppColors colors) {
    return DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorders.groupedSurface,
        boxShadow: AppShadows.groupedSurface,
      ),
      // A transparent Material above the decoration so row ink splashes
      // paint on the surface instead of underneath it.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppBorders.groupedSurface,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _withSeparators(colors.hairline),
        ),
      ),
    );
  }

  List<Widget> _withSeparators(Color color) {
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (0 < index) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            color: color,
            indent: separatorIndent,
          ),
        );
      }
      rows.add(children[index]);
    }
    return rows;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.rowHorizontal,
        end: Spacing.rowHorizontal,
        bottom: Spacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(text, style: AppTextStyles.overline.copyWith(color: color)),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.rowHorizontal,
        end: Spacing.rowHorizontal,
        top: Spacing.sm,
      ),
      child: Text(text, style: AppTextStyles.meta.copyWith(color: color)),
    );
  }
}
