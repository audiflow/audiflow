import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../utils/feedback_service.dart';
import '../utils/rate_app_service.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAboutTitle)),
      body: ListView(
        children: [
          _AppHeader(theme: theme),
          _VersionTile(
            version: packageInfo.version,
            buildNumber: packageInfo.buildNumber,
          ),
          const Divider(),
          _LicensesTile(context: context),
          const _FeedbackTile(),
          const _RateAppTile(),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Symbols.podcasts, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('audiflow', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            l10n.aboutTagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.aboutVersion),
      subtitle: Text('$version ($buildNumber)'),
    );
  }
}

class _LicensesTile extends StatelessWidget {
  const _LicensesTile({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.aboutLicenses),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          showLicensePage(context: context, applicationName: 'audiflow'),
    );
  }
}

class _FeedbackTile extends ConsumerWidget {
  const _FeedbackTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.aboutSendFeedback),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final logger = ref.read(appLoggerProvider);
        final service = ref.read(feedbackServiceProvider);
        try {
          final ok = await service.openFeedback();
          if (!ok) {
            logger.w('[Feedback] openFeedback returned false');
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.aboutSendFeedbackLaunchFailed)),
            );
          }
        } on PlatformException catch (e, st) {
          logger.w('[Feedback] openFeedback failed', error: e, stackTrace: st);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.aboutSendFeedbackLaunchFailed)),
          );
        } on MissingPluginException catch (e, st) {
          logger.w(
            '[Feedback] url_launcher plugin missing',
            error: e,
            stackTrace: st,
          );
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.aboutSendFeedbackLaunchFailed)),
          );
        }
      },
    );
  }
}

class _RateAppTile extends ConsumerWidget {
  const _RateAppTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.aboutRateApp),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final logger = ref.read(appLoggerProvider);
        final service = ref.read(rateAppServiceProvider);
        // Tapping the explicit rate tile = user willing to rate → never
        // auto-prompt again, even if the store launch itself fails.
        await ref.read(reviewPromptRepositoryProvider).markRated();
        try {
          await service.openStoreListing();
        } on PlatformException catch (e, st) {
          logger.w(
            '[RateApp] openStoreListing failed',
            error: e,
            stackTrace: st,
          );
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.aboutRateAppLaunchFailed)),
          );
        } on MissingPluginException catch (e, st) {
          logger.w(
            '[RateApp] in_app_review plugin missing',
            error: e,
            stackTrace: st,
          );
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.aboutRateAppLaunchFailed)),
          );
        }
      },
    );
  }
}
