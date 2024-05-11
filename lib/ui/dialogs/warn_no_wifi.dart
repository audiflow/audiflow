import 'dart:async';

import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

Future<bool?> warnNoWifi(
  BuildContext context, {
  required String caption,
  required String proceedCaption,
}) {
  final theme = Theme.of(context);
  final l10n = L10n.of(context);

  void confirmed() {
    Navigator.of(context, rootNavigator: true).pop(true);
  }

  void cancelled() {
    Navigator.of(context, rootNavigator: true).pop(false);
  }

  return showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      return Consumer(
        builder: (context, ref, _) {
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
                    cancelled();
                    ref.read(routerProvider).pushSettings();
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
                      onPressed: cancelled,
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: confirmed,
                      child: Text(proceedCaption),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
