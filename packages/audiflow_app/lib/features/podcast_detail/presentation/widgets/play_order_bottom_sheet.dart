import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet for selecting an [AutoPlayOrder].
Future<void> showPlayOrderBottomSheet({
  required BuildContext context,
  required AutoPlayOrder currentOrder,
  required AutoPlayOrder resolvedParentOrder,
  required ValueChanged<AutoPlayOrder> onOrderSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => _PlayOrderSheet(
      currentOrder: currentOrder,
      resolvedParentOrder: resolvedParentOrder,
      onOrderSelected: (order) {
        Navigator.of(sheetContext).pop();
        onOrderSelected(order);
      },
    ),
  );
}

class _PlayOrderSheet extends StatelessWidget {
  const _PlayOrderSheet({
    required this.currentOrder,
    required this.resolvedParentOrder,
    required this.onOrderSelected,
  });

  final AutoPlayOrder currentOrder;
  final AutoPlayOrder resolvedParentOrder;
  final ValueChanged<AutoPlayOrder> onOrderSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: RadioGroup<AutoPlayOrder>(
        groupValue: currentOrder,
        onChanged: (value) {
          if (value != null) onOrderSelected(value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                l10n.playOrderMenuTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            RadioListTile<AutoPlayOrder>(
              title: Text(
                l10n.playOrderDefault(_orderLabel(l10n, resolvedParentOrder)),
              ),
              value: AutoPlayOrder.defaultOrder,
            ),
            RadioListTile<AutoPlayOrder>(
              title: Text(l10n.playOrderOldestFirst),
              value: AutoPlayOrder.oldestFirst,
            ),
            RadioListTile<AutoPlayOrder>(
              title: Text(l10n.playOrderAsDisplayed),
              value: AutoPlayOrder.asDisplayed,
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts an [AutoPlayOrder] to a human-readable label.
///
/// For [AutoPlayOrder.defaultOrder], falls back to the "oldest first" label
/// since that is the base default when no parent override exists.
String _orderLabel(AppLocalizations l10n, AutoPlayOrder order) {
  return switch (order) {
    AutoPlayOrder.defaultOrder => l10n.playOrderOldestFirst,
    AutoPlayOrder.oldestFirst => l10n.playOrderOldestFirst,
    AutoPlayOrder.asDisplayed => l10n.playOrderAsDisplayed,
  };
}
