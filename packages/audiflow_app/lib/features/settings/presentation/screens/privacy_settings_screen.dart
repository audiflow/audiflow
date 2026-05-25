import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../consent/presentation/utils/in_app_browser_launcher_provider.dart';
import '../../../consent/presentation/utils/privacy_policy_url.dart';
import '../widgets/analytics_opt_in_tile.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPrivacyTitle)),
      body: ListView(
        children: [
          const AnalyticsOptInTile(),
          ListTile(
            leading: const Icon(Symbols.policy),
            title: Text(l10n.settingsPrivacyPolicyLinkTitle),
            subtitle: Text(l10n.settingsPrivacyPolicyLinkSubtitle),
            trailing: const Icon(Symbols.open_in_new, size: 18),
            onTap: () async {
              final lang = Localizations.localeOf(context).languageCode;
              final uri = buildPrivacyPolicyUrl(lang: lang);
              final launcher = ref.read(inAppBrowserLauncherProvider);
              await launcher(uri);
            },
          ),
        ],
      ),
    );
  }
}
