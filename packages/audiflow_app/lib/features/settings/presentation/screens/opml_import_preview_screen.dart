import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final importService = OpmlImportService(repository: repo);
    final result = await importService.importEntries(selectedEntries);

    if (!mounted) return;

    // Pop back and return the result
    Navigator.of(context).pop(result);
  }
}
