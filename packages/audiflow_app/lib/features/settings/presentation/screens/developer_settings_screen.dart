import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

// TEMP: target RSS used to debug the dropped-episode cleanup path in
// FeedSyncExecutor. Remove along with the ListTile once the bug is fixed.
const _debugDropEpisodesFeedUrl = 'https://anchor.fm/s/105fe6388/podcast/rss';

/// Settings screen for developer-oriented preferences.
///
/// Shows a contribute link to the smartplaylist repo, a toggle
/// for developer info in episode detail, and a browsable list
/// of all smart playlist patterns.
class DeveloperSettingsScreen extends ConsumerWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devInfoEnabled = ref.watch(devShowDeveloperInfoProvider);
    final summaries = ref.watch(patternSummariesProvider);
    final schemaVersion = ref.watch(smartPlaylistSchemaVersionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDeveloperTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          final repo = ref.read(smartPlaylistConfigRepositoryProvider);
          final rootMeta = await repo.fetchRootMeta();
          await repo.reconcileCache(rootMeta.patterns);
          repo.setPatternSummaries(rootMeta.patterns);
          ref
              .read(patternSummariesProvider.notifier)
              .setSummaries(rootMeta.patterns);
          ref
              .read(smartPlaylistSchemaVersionProvider.notifier)
              .setSchemaVersion(rootMeta.schemaVersion);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Contribute link
            ListTile(
              title: Text(l10n.developerContributeLabel),
              subtitle: Text(
                l10n.developerContributeRepo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Symbols.open_in_new,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              onTap: () async {
                try {
                  final ok = await launchUrl(
                    Uri.parse(SmartPlaylistUrls.repo),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) debugPrint('launchUrl returned false for repo URL');
                } on Exception catch (e) {
                  debugPrint('Failed to launch repo URL: $e');
                }
              },
            ),
            const Divider(height: 1),

            // Developer info toggle
            SwitchListTile(
              title: Text(l10n.developerShowInfoTitle),
              subtitle: Text(l10n.developerShowInfoSubtitle),
              value: devInfoEnabled,
              onChanged: (_) => unawaited(
                ref.read(devShowDeveloperInfoProvider.notifier).toggle(),
              ),
            ),
            const Divider(height: 1),

            // TEMP: trigger a forced feed sync against the anchor.fm feed
            // that has dropped episodes, to debug the drop-cleanup path in
            // FeedSyncExecutor. Remove once the bug is fixed.
            if (kDebugMode) ...[
              ListTile(
                leading: const Icon(Symbols.bug_report),
                title: const Text('[DEBUG] Force sync anchor.fm feed'),
                subtitle: const Text(_debugDropEpisodesFeedUrl),
                trailing: const Icon(Symbols.play_arrow),
                onTap: () => _runDebugFeedSync(context, ref),
              ),
              const Divider(height: 1),
            ],

            // Pattern list header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.developerPatternsHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Pattern items
            ...summaries.map((summary) {
              final enabled = 0 < schemaVersion;
              return ListTile(
                title: Text(summary.displayName),
                dense: true,
                trailing: enabled
                    ? Icon(
                        Symbols.chevron_right,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
                onTap: enabled
                    ? () async {
                        try {
                          final ok = await launchUrl(
                            Uri.parse(
                              SmartPlaylistUrls.patternDir(
                                summary.id,
                                schemaVersion: schemaVersion,
                              ),
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                          if (!ok) {
                            debugPrint(
                              'launchUrl returned false for pattern URL',
                            );
                          }
                        } on Exception catch (e) {
                          debugPrint('Failed to launch pattern URL: $e');
                        }
                      }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  // TEMP debug helper. Looks up the subscription by feed URL and runs
  // FeedSyncExecutor.syncFeed with forceRefresh=true so the drop-cleanup
  // branch always executes. Diagnostics are printed via debugPrint so they
  // can be read from the Flutter console alongside the existing Sentry
  // breadcrumbs emitted by FeedSyncExecutor.
  Future<void> _runDebugFeedSync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    void showSnack(String message) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getByFeedUrl(
      _debugDropEpisodesFeedUrl,
    );
    if (subscription == null) {
      showSnack('Not subscribed to $_debugDropEpisodesFeedUrl');
      return;
    }

    final logger = ref.read(namedLoggerProvider('DebugFeedSync'));
    final executor = FeedSyncExecutor(
      subscriptionRepo: subscriptionRepo,
      episodeRepo: ref.read(episodeRepositoryProvider),
      settingsRepo: ref.read(appSettingsRepositoryProvider),
      feedParser: ref.read(feedParserServiceProvider),
      dio: ref.read(dioProvider),
      logger: logger,
      onDiagnostic: (event, data) {
        debugPrint('[DebugFeedSync] $event $data');
      },
    );

    showSnack('Syncing "${subscription.title}"...');
    final result = await executor.syncFeed(
      subscription,
      forceRefresh: true,
      // Bypass If-None-Match / If-Modified-Since so the server can't
      // short-circuit us with a 304 and hide dropped episodes.
      skipConditionalHeaders: true,
    );

    if (result.success) {
      final count = result.newEpisodeCount ?? 0;
      showSnack(
        'Sync OK: $count new episodes '
        '(skipped=${result.skipped}). Check console for drop diagnostics.',
      );
    } else {
      showSnack('Sync failed: ${result.errorMessage ?? 'unknown error'}');
    }
  }
}
