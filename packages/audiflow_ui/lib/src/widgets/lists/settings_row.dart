import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/spacing.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';
import 'settings_trailing.dart';

/// A row inside a [GroupedSection] (redesign section 3.7).
///
/// Optional leading 32px icon tile (one `accentTint` tint for every
/// row), title, optional one-line subtitle, and an optional
/// [SettingsTrailing] control. Height is at least 54, or 60 with a
/// subtitle.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });

  static const double iconTileSize = 32;
  static const double _iconGap = 12;

  /// Separator inset that lines hairlines up with the title when rows
  /// carry an icon tile.
  static const double separatorIndentWithIcon =
      Spacing.rowHorizontal + iconTileSize + _iconGap;

  @visibleForTesting
  static const Key iconTileKey = ValueKey('settingsRowIconTile');

  final String title;
  final String? subtitle;
  final IconData? icon;
  final SettingsTrailing? trailing;

  /// Row tap. A toggle trailing replaces it with flipping the switch.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: subtitle == null ? 54 : 60),
      child: InkWell(
        onTap: trailing?.rowTap(onTap) ?? onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.rowHorizontal,
            vertical: Spacing.sm,
          ),
          child: _content(context, colors),
        ),
      ),
    );
    return trailing?.mergesSemantics ?? false
        ? MergeSemantics(child: row)
        : row;
  }

  Widget _content(BuildContext context, AppColors colors) {
    return Row(
      children: [
        if (icon != null) ...[
          _IconTile(icon: icon!, colors: colors),
          const SizedBox(width: _iconGap),
        ],
        Expanded(child: _labels(colors)),
        if (trailing != null) ...[
          const SizedBox(width: _iconGap),
          trailing!.build(context),
        ],
      ],
    );
  }

  Widget _labels(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(color: colors.ink),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
          ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.colors});

  final IconData icon;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: SettingsRow.iconTileSize,
      child: DecoratedBox(
        key: SettingsRow.iconTileKey,
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: AppBorders.sm,
        ),
        child: Icon(icon, size: 18, color: colors.accent),
      ),
    );
  }
}
