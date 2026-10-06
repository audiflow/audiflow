import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Picker for how many unstarted auto-downloads to keep.
///
/// With [globalKeepCount] set, it also offers "use default", reported to
/// [onChanged] as null.
class KeepCountDropdown extends StatelessWidget {
  const KeepCountDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.globalKeepCount,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final int? globalKeepCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final global = globalKeepCount;
    return DropdownButton<int?>(
      value: value,
      onChanged: onChanged,
      items: [
        if (global != null)
          DropdownMenuItem(
            child: Text(l10n.downloadsKeepCountFollowGlobal(global)),
          ),
        for (final count in SettingsDefaults.autoDownloadKeepCountOptions)
          DropdownMenuItem(
            value: count,
            child: Text(l10n.downloadsKeepCountOption(count)),
          ),
      ],
    );
  }
}
