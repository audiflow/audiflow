import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/onboarding_completion_controller.dart';

/// Permanent "Getting Started" hub for re-discovery of features
/// and migration guidance, accessible from Settings.
class GettingStartedHubScreen extends ConsumerWidget {
  const GettingStartedHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gettingStartedTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _HubTile(
            icon: Symbols.swap_horiz,
            title: l10n.gettingStartedMigrateTitle,
            subtitle: l10n.gettingStartedMigrateSubtitle,
            onTap: () => context.go(AppRoutes.migrationGuide),
          ),
          _HubTile(
            icon: Symbols.search,
            title: l10n.gettingStartedSearchTitle,
            subtitle: l10n.gettingStartedSearchSubtitle,
            onTap: () => context.go(AppRoutes.search),
          ),
          _HubTile(
            icon: Symbols.queue_music,
            title: l10n.gettingStartedStationsTitle,
            subtitle: l10n.gettingStartedStationsSubtitle,
            onTap: () => context.go(AppRoutes.stationNew),
          ),
          _HubTile(
            icon: Symbols.auto_awesome,
            title: l10n.gettingStartedSmartPlaylistsTitle,
            subtitle: l10n.gettingStartedSmartPlaylistsSubtitle,
            onTap: () => context.go(AppRoutes.search),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Symbols.replay),
            title: Text(l10n.gettingStartedReplayCarousel),
            onTap: () async {
              await ref
                  .read(onboardingCompletionControllerProvider.notifier)
                  .reset();
              if (!context.mounted) return;
              context.go(AppRoutes.onboarding);
            },
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: const Icon(Symbols.chevron_right),
      onTap: onTap,
      isThreeLine: true,
    );
  }
}
