import 'package:audiflow_domain/audiflow_domain.dart' show namedLoggerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'played_status_helper.dart';

/// Asks to mark all [episodeIds] played (or unplayed) with [confirmText],
/// then marks them and confirms in a snackbar. Used by the
/// podcast and series `…` menus.
Future<void> confirmAndMarkAllPlayed({
  required BuildContext context,
  required List<int> episodeIds,
  required bool played,
  required String confirmText,
}) async {
  if (episodeIds.isEmpty) return;
  final l10n = AppLocalizations.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(confirmText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          // Short label: the dialog already says "all", and a long one
          // pushes the actions onto separate lines.
          child: Text(played ? l10n.markAsPlayed : l10n.markAsUnplayed),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await setEpisodesPlayedStatus(
      container,
      episodeIds: episodeIds,
      played: played,
    );
  } on Object catch (e, stack) {
    container
        .read(namedLoggerProvider('MarkAllPlayed'))
        .e('Marking all episodes failed', error: e, stackTrace: stack);
    messenger.showSnackBar(SnackBar(content: Text(l10n.podcastMarkAllFailed)));
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        played
            ? l10n.podcastMarkAllPlayedDone
            : l10n.podcastMarkAllUnplayedDone,
      ),
    ),
  );
}
