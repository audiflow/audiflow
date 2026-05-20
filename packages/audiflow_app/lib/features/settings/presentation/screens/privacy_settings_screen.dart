import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/analytics_opt_in_tile.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPrivacyTitle)),
      body: ListView(children: const [AnalyticsOptInTile()]),
    );
  }
}
