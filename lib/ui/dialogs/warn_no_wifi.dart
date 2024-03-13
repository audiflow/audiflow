import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

void warnNoWifi(
  BuildContext context,
  WidgetRef ref, {
  required String caption,
  required String proceedCaption,
  required VoidCallback onProceed,
}) {
  final theme = Theme.of(context);
  final l10n = L10n.of(context)!;

  showAdaptiveDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.wifi_off_rounded,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 14),
            Text(
              l10n.titleNoFiFi,
              style: TextStyle(color: theme.colorScheme.tertiary),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              caption,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                NavigationHelper.pushSettings();
              },
              child: Text(
                l10n.captionWarnSettingNavigation,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.hintColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    onProceed();
                  },
                  child: Text(proceedCaption),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
