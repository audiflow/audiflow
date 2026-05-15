import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// User action picked from the review prompt dialog.
enum ReviewPromptAction { rateNow, later, dontAskAgain }

/// Modal dialog asking the user to rate the app.
///
/// Returns the picked [ReviewPromptAction], or `null` if the dialog is
/// dismissed by the OS (e.g. back gesture). Callers should treat `null`
/// the same as [ReviewPromptAction.later] (do not opt the user out).
class ReviewPromptDialog extends StatelessWidget {
  const ReviewPromptDialog({super.key});

  static Future<ReviewPromptAction?> show(BuildContext context) {
    return showDialog<ReviewPromptAction>(
      context: context,
      builder: (_) => const ReviewPromptDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reviewPromptTitle),
      content: Text(l10n.reviewPromptBody),
      actionsOverflowAlignment: OverflowBarAlignment.end,
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ReviewPromptAction.dontAskAgain),
          child: Text(l10n.reviewPromptDontAskAgain),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ReviewPromptAction.later),
          child: Text(l10n.reviewPromptLater),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ReviewPromptAction.rateNow),
          child: Text(l10n.reviewPromptRateNow),
        ),
      ],
    );
  }
}
