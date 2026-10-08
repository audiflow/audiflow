import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Store-region button beside the search field (redesign 4.7): an
/// outlined pill with the region code, as tall as the field.
class SearchCountryChip extends StatelessWidget {
  const SearchCountryChip({
    required this.countryCode,
    required this.onTap,
    super.key,
  });

  final String countryCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final displayName =
        PodcastCountries.all[countryCode] ?? countryCode.toUpperCase();

    return Semantics(
      button: true,
      label: l10n.searchRegionCurrent(displayName),
      excludeSemantics: true,
      // The excluded InkWell's tap must be offered here instead.
      onTap: onTap,
      child: Tooltip(
        message: l10n.searchRegionLabel,
        child: Material(
          color: colors.surface,
          shape: StadiumBorder(side: BorderSide(color: colors.outline)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Spacing.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: Spacing.md - Spacing.xxs,
                  end: Spacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCode.toUpperCase(),
                      style: AppTextStyles.label.copyWith(color: colors.ink),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: colors.inkSecondary,
                    ),
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
