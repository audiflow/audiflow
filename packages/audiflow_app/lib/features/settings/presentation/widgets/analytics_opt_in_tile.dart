import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/analytics_opt_in_controller.dart';

class AnalyticsOptInTile extends ConsumerWidget {
  const AnalyticsOptInTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(analyticsOptInControllerProvider);
    return SwitchListTile(
      title: Text(l10n.settingsAnalyticsTitle),
      subtitle: Text(l10n.settingsAnalyticsSubtitle),
      value: value,
      onChanged: (v) =>
          ref.read(analyticsOptInControllerProvider.notifier).setOptIn(v),
    );
  }
}
