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
    final schemaVersion = ref.watch(smartPlaylistSchemaVersionProvider);

    final match = summaries
        .where((s) => feedUrl.contains(s.feedUrlHint))
        .firstOrNull;

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
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: Spacing.md,
                    bottom: Spacing.xs,
                  ),
                  child: Text(l10n.developerRssFeedUrl, style: labelStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          feedUrl,
                          style: valueStyle?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(
                            Symbols.content_copy,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: feedUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.developerCopied)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: Spacing.md,
                    bottom: Spacing.xs,
                  ),
                  child: Text(l10n.developerPatternLabel, style: labelStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse(
                        match != null
                            ? SmartPlaylistUrls.patternDir(
                                match.id,
                                schemaVersion: schemaVersion,
                              )
                            : SmartPlaylistUrls.repoBranch(
                                schemaVersion: schemaVersion,
                              ),
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      match?.displayName ?? l10n.developerPatternNotDefined,
                      style: valueStyle?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
