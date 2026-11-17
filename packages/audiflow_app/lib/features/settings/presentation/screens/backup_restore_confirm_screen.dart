import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../parental_control/domain/gate_guard.dart';
import '../../../parental_control/providers/gate_guard_provider.dart';
import '../controllers/backup_restore_controller.dart';

/// Shows what a validated backup holds, read from its header alone, and
/// restores it once the user agrees.
class BackupRestoreConfirmScreen extends ConsumerWidget {
  const BackupRestoreConfirmScreen({required this.file, super.key});

  final SnapshotFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final header = file.header;
    final counts = header.counts;
    final running =
        ref.watch(backupRestoreControllerProvider) is BackupRestoreRunning;
    final created = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_jm().format(header.createdAt.toLocal());

    ref.listen(backupRestoreControllerProvider, (_, next) {
      final messenger = ScaffoldMessenger.of(context);
      switch (next) {
        case BackupRestoreDone():
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.backupRestoreSuccess)),
          );
          Navigator.of(context).pop();
        case BackupRestoreError():
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.backupRestoreFailed)),
          );
        case BackupRestoreIdle() || BackupRestoreRunning():
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestoreConfirmTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.backupRestoreCreated(created, _platformName(header.platform)),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(l10n.backupRestorePodcasts(counts.podcasts)),
          Text(l10n.backupRestoreEpisodes(counts.episodes)),
          Text(l10n.backupRestoreQueue(counts.queue)),
          Text(l10n.backupRestoreStations(counts.stations)),
          const SizedBox(height: 24),
          Text(
            l10n.backupRestoreMergeNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: running ? null : () => _restore(context, ref),
            child: running
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.backupRestoreAction),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    // A restore can change parental flags, so Restricted Mode guards it
    // like a data reset.
    final allowed = await ref
        .read(gateGuardProvider)
        .requireUnlock(context, reason: GateReason.restoreBackup);
    if (!context.mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).parentalControlAccessDenied,
          ),
        ),
      );
      return;
    }
    await ref.read(backupRestoreControllerProvider.notifier).restore(file);
  }

  static String _platformName(String platform) => switch (platform) {
    'ios' => 'iOS',
    'android' => 'Android',
    _ => platform,
  };
}
