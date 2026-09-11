import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../l10n/app_localizations.dart';

/// Preview screen for OPML import showing a selectable list
/// of podcast entries parsed from the OPML file.
class OpmlImportPreviewScreen extends ConsumerStatefulWidget {
  const OpmlImportPreviewScreen({
    required this.entries,
    required this.subscribedFeedUrls,
    super.key,
  });

  final List<OpmlEntry> entries;
  final Set<String> subscribedFeedUrls;

  @override
  ConsumerState<OpmlImportPreviewScreen> createState() =>
      _OpmlImportPreviewScreenState();
}

class _OpmlImportPreviewScreenState
    extends ConsumerState<OpmlImportPreviewScreen> {
  late final Set<String> _selectedFeedUrls;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Pre-select all entries NOT already subscribed
    _selectedFeedUrls = widget.entries
        .where((e) => !widget.subscribedFeedUrls.contains(e.feedUrl))
        .map((e) => e.feedUrl)
        .toSet();
  }

  int get _selectedCount => _selectedFeedUrls.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.opmlImportTitle)),
      body: ListView.builder(
        itemCount: widget.entries.length,
        itemBuilder: (context, index) {
          final entry = widget.entries[index];
          final isSubscribed = widget.subscribedFeedUrls.contains(
            entry.feedUrl,
          );
          final isSelected = _selectedFeedUrls.contains(entry.feedUrl);

          return CheckboxListTile(
            value: isSelected,
            onChanged: _isImporting
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selectedFeedUrls.add(entry.feedUrl);
                      } else {
                        _selectedFeedUrls.remove(entry.feedUrl);
                      }
                    });
                  },
            title: Text(
              entry.title,
              style: isSubscribed
                  ? theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )
                  : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.feedUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                if (isSubscribed)
                  Text(
                    l10n.opmlAlreadySubscribed,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_selectedCount < 1 || _isImporting)
                ? null
                : _importSelected,
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.opmlImportSelected(_selectedCount)),
          ),
        ),
      ),
    );
  }

  Future<void> _importSelected() async {
    setState(() => _isImporting = true);

    final selectedEntries = widget.entries
        .where((e) => _selectedFeedUrls.contains(e.feedUrl))
        .toList();

    final repo = ref.read(subscriptionRepositoryProvider);
    final syncService = ref.read(feedSyncServiceProvider);
    final logger = ref.read(namedLoggerProvider('OpmlImport'));
    final importService = OpmlImportService(repository: repo);
    final result = await importService.importEntries(selectedEntries);

    // OPML gives a title and a feed URL and nothing else, so imported
    // podcasts land in the library with no artwork. Fetch their feeds now
    // to fill that in. Not awaited: the summary dialog must not wait on one
    // request per feed, and the library list is Isar-backed, so rows update
    // on their own as each feed resolves. The sync service is a keepAlive
    // singleton, so the work outlives this screen.
    if (result.succeeded.isNotEmpty) {
      unawaited(
        _syncImportedFeeds(syncService, logger, [
          for (final entry in result.succeeded) entry.feedUrl,
        ]),
      );
    }

    if (!mounted) return;

    // Pop back and return the result
    Navigator.of(context).pop(result);
  }

  /// Fetches [feedUrls] so the imported podcasts gain their channel
  /// metadata.
  ///
  /// Swallows failures because the caller does not await this: an escaping
  /// error would surface as an unhandled async error long after the screen
  /// is gone. The import itself already succeeded, and the next feed
  /// refresh retries the backfill. Uses `catch` rather than `on Exception`
  /// because Isar throws Error subclasses.
  Future<void> _syncImportedFeeds(
    FeedSyncService syncService,
    Logger logger,
    List<String> feedUrls,
  ) async {
    try {
      await syncService.syncFeedsByUrls(feedUrls);
    } catch (e, stack) {
      logger.w(
        'Post-import feed sync failed; details fill in on the next refresh',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
