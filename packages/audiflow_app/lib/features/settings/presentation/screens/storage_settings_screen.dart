import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/opml_export_controller.dart';
import '../controllers/opml_import_controller.dart';
import 'opml_import_preview_screen.dart';

/// Screen for managing storage and data: cache, search history,
/// OPML import/export, and full data reset.
class StorageSettingsScreen extends ConsumerWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsStorageTitle)),
      body: ListView(
        children: [
          _CacheTile(ref: ref),
          _PodcastCacheTile(ref: ref),
          _SearchHistoryTile(context: context),
          const Divider(),
          const _OpmlSection(),
          const Divider(),
          _DangerZoneSection(context: context, ref: ref),
        ],
      ),
    );
  }
}

class _CacheTile extends StatelessWidget {
  const _CacheTile({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.storageImageCache),
      subtitle: Text(l10n.storageImageCacheSubtitle),
      trailing: OutlinedButton(
        onPressed: () => _confirmClearCache(context),
        child: Text(l10n.commonClear),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storageClearCacheTitle),
        content: Text(l10n.storageClearCacheContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.storageCacheCleared)));
            },
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
  }
}

class _PodcastCacheTile extends StatelessWidget {
  const _PodcastCacheTile({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.storagePodcastCache),
      subtitle: Text(l10n.storagePodcastCacheSubtitle),
      trailing: OutlinedButton(
        onPressed: () => _confirmClear(context),
        child: Text(l10n.commonClear),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storageClearPodcastCacheTitle),
        content: Text(l10n.storageClearPodcastCacheContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final ds = ref.read(smartPlaylistLocalDatasourceProvider);
              final configRepo = ref.read(
                smartPlaylistConfigRepositoryProvider,
              );
              final subRepo = ref.read(subscriptionRepositoryProvider);
              await ds.clearAll();
              await configRepo.clearDiskCache();
              await subRepo.clearAllHttpCacheHeaders();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.storagePodcastCacheCleared)),
                );
              }
            },
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
  }
}

class _SearchHistoryTile extends StatelessWidget {
  const _SearchHistoryTile({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.storageSearchHistory),
      subtitle: Text(l10n.storageSearchHistorySubtitle),
      trailing: OutlinedButton(
        onPressed: () => _confirmClearHistory(context),
        child: Text(l10n.commonClear),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storageClearSearchHistoryTitle),
        content: Text(l10n.storageClearSearchHistoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.storageSearchHistoryCleared)),
              );
            },
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );
  }
}

class _OpmlSection extends ConsumerWidget {
  const _OpmlSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(children: [_ExportTile(), _ImportTile()]);
  }
}

class _ExportTile extends ConsumerWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    ref.listen(opmlExportControllerProvider, (_, next) {
      final message = switch (next) {
        OpmlExportEmpty() => l10n.storageExportEmpty,
        OpmlExportSuccess() => l10n.storageExportSuccess,
        OpmlExportError(:final message) => l10n.storageExportError(message),
        _ => null,
      };
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return ListTile(
      title: Text(l10n.storageExportTitle),
      subtitle: Text(l10n.storageExportSubtitle),
      trailing: OutlinedButton(
        onPressed: () =>
            ref.read(opmlExportControllerProvider.notifier).export(),
        child: Text(l10n.storageExport),
      ),
    );
  }
}

class _ImportTile extends ConsumerWidget {
  const _ImportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    ref.listen(opmlImportControllerProvider, (_, next) {
      switch (next) {
        case OpmlPickSuccess(:final entries, :final subscribedFeedUrls):
          _navigateToPreview(
            context,
            entries: entries,
            subscribedFeedUrls: subscribedFeedUrls,
          );
        case OpmlPickError(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        case OpmlPickCancelled():
        case OpmlPickIdle():
        case OpmlPickLoading():
          break;
      }
    });

    return ListTile(
      title: Text(l10n.storageImportTitle),
      subtitle: Text(l10n.storageImportSubtitle),
      trailing: OutlinedButton(
        onPressed: () =>
            ref.read(opmlImportControllerProvider.notifier).pickAndParse(),
        child: Text(l10n.storageImport),
      ),
    );
  }

  Future<void> _navigateToPreview(
    BuildContext context, {
    required List<OpmlEntry> entries,
    required Set<String> subscribedFeedUrls,
  }) async {
    final result = await Navigator.push<OpmlImportResult>(
      context,
      MaterialPageRoute<OpmlImportResult>(
        builder: (_) => OpmlImportPreviewScreen(
          entries: entries,
          subscribedFeedUrls: subscribedFeedUrls,
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => _ImportSummaryDialog(result: result),
    );
  }
}

class _ImportSummaryDialog extends StatelessWidget {
  const _ImportSummaryDialog({required this.result});

  final OpmlImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[l10n.storageImportedCount(result.succeeded.length)];
    if (result.alreadySubscribed.isNotEmpty) {
      lines.add(
        l10n.storageAlreadySubscribedCount(result.alreadySubscribed.length),
      );
    }
    if (result.failed.isNotEmpty) {
      lines.add(l10n.storageFailedCount(result.failed.length));
    }

    return AlertDialog(
      title: Text(l10n.storageImportComplete),
      content: Text(lines.join('\n')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }
}

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.storageDangerZone,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colorScheme.error),
          ),
        ),
        ListTile(
          title: Text(
            l10n.storageResetTitle,
            style: TextStyle(color: colorScheme.error),
          ),
          subtitle: Text(l10n.storageResetSubtitle),
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ResetConfirmationDialog(
        onConfirm: () async {
          try {
            final repo = ref.read(appSettingsRepositoryProvider);
            await repo.clearAll();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.storageResetComplete)),
              );
            }
          } on Exception catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.storageResetFailed(e.toString()))),
              );
            }
          }
        },
      ),
    );
  }
}

class _ResetConfirmationDialog extends StatefulWidget {
  const _ResetConfirmationDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  State<_ResetConfirmationDialog> createState() =>
      _ResetConfirmationDialogState();
}

class _ResetConfirmationDialogState extends State<_ResetConfirmationDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final valid = _controller.text == 'RESET';
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.storageResetDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.storageResetDialogContent),
          const SizedBox(height: 16),
          Text(l10n.storageResetTypeConfirm),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'RESET',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isValid
              ? () {
                  Navigator.pop(context);
                  widget.onConfirm();
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(l10n.storageResetButton),
        ),
      ],
    );
  }
}
