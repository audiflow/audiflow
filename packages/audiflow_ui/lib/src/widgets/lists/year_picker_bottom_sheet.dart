import 'package:flutter/material.dart';

/// Shows a bottom sheet with a list of years to pick from.
///
/// Returns the selected year, or null if dismissed.
Future<int?> showYearPickerBottomSheet({
  required BuildContext context,
  required List<int> years,
  required int currentYear,
}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Jump to year', style: theme.textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == currentYear;

                  return ListTile(
                    title: Text(
                      year == 0 ? 'Unknown' : '$year',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, year),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
