import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Episode row menu item that keeps an auto download, so every row menu
/// offers it with the same icon and label.
///
/// Callers show it only for a task whose `isRemovableByRetention` is true.
class KeepDownloadMenuTile extends StatelessWidget {
  const KeepDownloadMenuTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.push_pin_outlined),
      title: Text(AppLocalizations.of(context).downloadKeep),
      onTap: onTap,
    );
  }
}
