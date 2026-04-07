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
    final repo = ref.watch(smartPlaylistConfigRepositoryProvider);
    final schemaVersion = ref.watch(smartPlaylistSchemaVersionProvider);

    final match = repo.findMatchingPattern(null, feedUrl);

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.developerSectionLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // RSS Feed URL
        Text(l10n.developerRssFeedUrl, style: labelStyle),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                feedUrl,
                style: valueStyle?.copyWith(fontFamily: 'monospace'),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              iconSize: 16,
              tooltip: l10n.developerCopyLabel,
              icon: Icon(
                Symbols.content_copy,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: feedUrl));
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.developerCopied)));
              },
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),

        // Smart Playlist Pattern
        Text(l10n.developerPatternLabel, style: labelStyle),
        const SizedBox(height: Spacing.xs),
        GestureDetector(
          onTap: () async {
            final url = 0 < schemaVersion && match != null
                ? SmartPlaylistUrls.patternDir(
                    match.id,
                    schemaVersion: schemaVersion,
                  )
                : SmartPlaylistUrls.repo;
            try {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            } on Exception catch (e) {
              debugPrint('Failed to launch pattern URL: $e');
            }
          },
          child: Text(
            match?.displayName ?? l10n.developerPatternNotDefined,
            style: valueStyle?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
