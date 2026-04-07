import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// Displays developer-oriented information at the bottom of an
/// episode detail screen.
///
/// Only rendered when [devShowDeveloperInfoProvider] is true.
/// Shows the podcast RSS feed URL (tap to copy) and a link to
/// the matching smart playlist pattern in the GitHub repo.
class EpisodeDevInfoWidget extends ConsumerWidget {
  const EpisodeDevInfoWidget({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(devShowDeveloperInfoProvider);
    if (!enabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaries = ref.watch(patternSummariesProvider);

    // Find first pattern whose feedUrlHint is contained in the feed URL.
    final match = summaries
        .where((s) => feedUrl.contains(s.feedUrlHint))
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.developerSectionLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        _InfoCard(
          label: l10n.developerRssFeedUrl,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  feedUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              ActionChip(
                label: Text(l10n.developerCopyLabel),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: feedUrl));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.developerCopied)));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),
        _InfoCard(
          label: l10n.developerPatternLabel,
          child: InkWell(
            onTap: () => launchUrl(
              Uri.parse(
                match != null
                    ? SmartPlaylistUrls.patternDir(match.id)
                    : SmartPlaylistUrls.repo,
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    match?.displayName ?? l10n.developerPatternNotDefined,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: match != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          child,
        ],
      ),
    );
  }
}
