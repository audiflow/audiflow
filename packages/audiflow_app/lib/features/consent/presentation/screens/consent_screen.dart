import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/privacy_consent_controller.dart';
import '../utils/in_app_browser_launcher_provider.dart';
import '../utils/privacy_policy_url.dart';

/// Pre-onboarding consent screen.
///
/// Shows a bundled summary plus a link that opens the full privacy policy
/// in the platform in-app browser (SFSafariViewController / Custom Tabs).
/// Accepting the policy persists the consent flag and forwards the user to
/// the onboarding carousel.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreed = false;

  Future<void> _openFullPolicy() async {
    final lang = Localizations.localeOf(context).languageCode;
    final uri = buildPrivacyPolicyUrl(lang: lang);
    final launcher = ref.read(inAppBrowserLauncherProvider);
    await launcher(uri);
  }

  Future<void> _onContinuePressed() async {
    await ref.read(privacyConsentControllerProvider.notifier).markAccepted();
    if (!mounted) return;
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Symbols.privacy_tip,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.consentTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.consentIntro,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _SummaryBullet(text: l10n.consentSummaryUsage),
                    _SummaryBullet(text: l10n.consentSummaryCrash),
                    _SummaryBullet(text: l10n.consentSummaryNoPii),
                    _SummaryBullet(text: l10n.consentSummaryOptOut),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: _openFullPolicy,
                        icon: const Icon(Symbols.open_in_new, size: 18),
                        label: Text(l10n.consentReadFullLink),
                      ),
                    ),
                  ],
                ),
              ),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                title: Text(l10n.consentAgreeCheckbox),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _agreed ? _onContinuePressed : null,
                child: Text(l10n.consentContinueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBullet extends StatelessWidget {
  const _SummaryBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Icon(
              Symbols.check_circle,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
