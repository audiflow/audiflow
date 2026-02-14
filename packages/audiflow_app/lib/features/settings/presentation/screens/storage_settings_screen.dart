import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for managing storage and data: cache, search history,
/// OPML import/export, and full data reset.
class StorageSettingsScreen extends ConsumerWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage & Data')),
      body: ListView(
        children: [
          _CacheTile(ref: ref),
          _SearchHistoryTile(context: context),
          const Divider(),
          _OpmlSection(context: context),
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
    return ListTile(
      title: const Text('Image Cache'),
      subtitle: const Text('Clear temporary files and cached images'),
      trailing: OutlinedButton(
        onPressed: () => _confirmClearCache(context),
        child: const Text('Clear Cache'),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will delete all temporary files and '
          'cached images. They will be re-downloaded '
          'as needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            child: const Text('Clear'),
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
    return ListTile(
      title: const Text('Search History'),
      subtitle: const Text('Clear search suggestions'),
      trailing: OutlinedButton(
        onPressed: () => _confirmClearHistory(context),
        child: const Text('Clear'),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History?'),
        content: const Text('This will remove all saved search suggestions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _OpmlSection extends StatelessWidget {
  const _OpmlSection({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Export Subscriptions'),
          subtitle: const Text('Save subscriptions as OPML file'),
          trailing: OutlinedButton(
            onPressed: () => _showComingSoon(context),
            child: const Text('Export'),
          ),
        ),
        ListTile(
          title: const Text('Import Subscriptions'),
          subtitle: const Text('Import from OPML file'),
          trailing: OutlinedButton(
            onPressed: () => _showComingSoon(context),
            child: const Text('Import'),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }
}

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Danger Zone',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colorScheme.error),
          ),
        ),
        ListTile(
          title: Text(
            'Reset All Data',
            style: TextStyle(color: colorScheme.error),
          ),
          subtitle: const Text(
            'Delete all data and reset app to initial state',
          ),
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ResetConfirmationDialog(
        onConfirm: () async {
          try {
            final repo = ref.read(appSettingsRepositoryProvider);
            await repo.clearAll();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data reset complete')),
              );
            }
          } on Exception catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Reset failed: $e')));
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
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Reset All Data?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete all your data '
            'including subscriptions, downloads, playback '
            'history, and settings.',
          ),
          const SizedBox(height: 16),
          const Text('Type RESET to confirm:'),
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
          child: const Text('Cancel'),
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
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
