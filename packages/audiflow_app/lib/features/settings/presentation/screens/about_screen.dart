import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Screen showing app info, version, licenses, and support links.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          _AppHeader(theme: theme),
          _VersionTile(
            version: packageInfo.version,
            buildNumber: packageInfo.buildNumber,
          ),
          const Divider(),
          _LicensesTile(context: context),
          _FeedbackTile(context: context),
          _RateAppTile(context: context),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Symbols.podcasts, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Audiflow', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Your podcast companion',
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
    return ListTile(
      title: const Text('Version'),
      subtitle: Text('$version ($buildNumber)'),
    );
  }
}

class _LicensesTile extends StatelessWidget {
  const _LicensesTile({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Open Source Licenses'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          showLicensePage(context: context, applicationName: 'Audiflow'),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  const _FeedbackTile({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Send Feedback'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
      },
    );
  }
}

class _RateAppTile extends StatelessWidget {
  const _RateAppTile({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Rate the App'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
      },
    );
  }
}
