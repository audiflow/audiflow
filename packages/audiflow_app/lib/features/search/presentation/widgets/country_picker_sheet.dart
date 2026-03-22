import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Bottom sheet that displays a list of iTunes storefront countries.
class CountryPickerSheet extends StatelessWidget {
  const CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
    this.scrollController,
    super.key,
  });

  final String selectedCountry;
  final ValueChanged<String> onCountrySelected;
  final ScrollController? scrollController;

  /// Shows the picker as a modal bottom sheet and returns the selected code.
  static Future<String?> show(
    BuildContext context, {
    required String selectedCountry,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => CountryPickerSheet(
          selectedCountry: selectedCountry,
          onCountrySelected: (code) => Navigator.of(context).pop(code),
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final countries = PodcastCountries.all.entries.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            Spacing.sm,
          ),
          child: Column(
            children: [
              Text(
                l10n.searchRegionPickerTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.searchRegionPickerSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final entry = countries[index];
              final isSelected = entry.key == selectedCountry;
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key.toUpperCase()),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                selected: isSelected,
                onTap: () => onCountrySelected(entry.key),
              );
            },
          ),
        ),
      ],
    );
  }
}
