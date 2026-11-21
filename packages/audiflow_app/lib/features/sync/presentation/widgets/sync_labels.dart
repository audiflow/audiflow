import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

String syncPhaseLabel(AppLocalizations l10n, SyncPhase phase) =>
    switch (phase) {
      SyncPhase.unavailable || SyncPhase.off => l10n.syncStatusOff,
      SyncPhase.idle => l10n.syncStatusIdle,
      SyncPhase.connecting => l10n.syncStatusConnecting,
      SyncPhase.connected => l10n.syncStatusConnected,
      SyncPhase.retrying => l10n.syncStatusRetrying,
      SyncPhase.failed => l10n.syncStatusFailed,
    };

/// What the user can do about a refusal, by `SyncRelayFailure.code`.
String syncFailureText(AppLocalizations l10n, String? code) => switch (code) {
  RelayError.unauthorized ||
  RelayError.revoked ||
  SyncRelayFailure.notEnrolled => l10n.syncFailedRemoved,
  RelayError.tooOld => l10n.syncFailedTooOld,
  RelayError.exists => l10n.syncFailedSetup,
  SyncRelayFailure.unreadableFrame => l10n.syncFailedUnreadable,
  _ => l10n.syncFailedOther,
};

/// Runs a [SyncController] change, logging and reporting a failure (a
/// key store or database error) in a snackbar.
Future<bool> runSyncAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(SyncController controller) action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context).syncActionFailed;
  try {
    await action(ref.read(syncControllerProvider));
    return true;
  } on Object catch (e, stack) {
    ref
        .read(namedLoggerProvider('SyncSettings'))
        .e('Sync change failed', error: e, stackTrace: stack);
    messenger.showSnackBar(SnackBar(content: Text(message)));
    return false;
  }
}
