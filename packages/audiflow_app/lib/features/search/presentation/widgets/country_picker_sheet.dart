import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Bottom sheet that displays a list of iTunes storefront countries.
class CountryPickerSheet extends StatefulWidget {
  static final _countries = PodcastCountries.all.entries.toList();

  /// Fixed height per row — ensures scroll offset calculation is exact.
  static const _kTileHeight = 72.0;

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
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;

    final index = CountryPickerSheet._countries.indexWhere(
      (e) => e.key == widget.selectedCountry,
    );
    if (index < 0) return;

    // Center the selected item in the visible area
    final viewportHeight = controller.position.viewportDimension;
    final targetOffset =
        index * CountryPickerSheet._kTileHeight -
        (viewportHeight - CountryPickerSheet._kTileHeight) / 2;
    final clamped = targetOffset.clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    controller.jumpTo(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final countries = CountryPickerSheet._countries;

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
            controller: widget.scrollController,
            itemCount: countries.length,
            itemExtent: CountryPickerSheet._kTileHeight,
            itemBuilder: (context, index) {
              final entry = countries[index];
              final isSelected = entry.key == widget.selectedCountry;
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key.toUpperCase()),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                selected: isSelected,
                onTap: () => widget.onCountrySelected(entry.key),
              );
            },
          ),
        ),
      ],
    );
  }
}
