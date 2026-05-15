import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/utils/rate_app_service.dart';
import 'widgets/review_prompt_dialog.dart';

/// Returns whether the app is currently in the foreground.
///
/// Overridable in widget tests because `WidgetsBinding.instance
/// .lifecycleState` returns `null` under `TestWidgetsFlutterBinding`.
final reviewPromptForegroundCheckProvider = Provider<bool Function()>((ref) {
  return () =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
});

/// Listens to the review-prompt trigger and shows the dialog when the
/// app is in the foreground. Background events are dropped — the next
/// playback session re-arms the trigger.
class ReviewPromptGate extends ConsumerStatefulWidget {
  const ReviewPromptGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReviewPromptGate> createState() => _ReviewPromptGateState();
}

class _ReviewPromptGateState extends ConsumerState<ReviewPromptGate> {
  bool _dialogOpen = false;

  bool _isAppForeground() => ref.read(reviewPromptForegroundCheckProvider)();

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(reviewPromptTriggerEventsProvider, (
      previous,
      next,
    ) {
      if (next is! AsyncData<void>) return;
      unawaited(_maybeShow());
    });
    return widget.child;
  }

  Future<void> _maybeShow() async {
    if (_dialogOpen || !_isAppForeground() || !mounted) return;
    _dialogOpen = true;
    try {
      final action = await ReviewPromptDialog.show(context);
      if (!mounted) return;
      await _applyAction(action);
    } catch (e, st) {
      ref
          .read(appLoggerProvider)
          .w(
            '[ReviewPromptGate] failed to show prompt',
            error: e,
            stackTrace: st,
          );
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> _applyAction(ReviewPromptAction? action) async {
    final repo = ref.read(reviewPromptRepositoryProvider);
    switch (action) {
      case ReviewPromptAction.rateNow:
        await repo.markRated();
        await _openStore();
      case ReviewPromptAction.later:
        await repo.recordPromptShown();
      case ReviewPromptAction.dontAskAgain:
        await repo.markOptedOut();
      case null:
        // OS dismissal (back gesture / barrier) — treat as Later.
        await repo.recordPromptShown();
    }
  }

  Future<void> _openStore() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(rateAppServiceProvider).openStoreListing();
    } catch (e, st) {
      ref
          .read(appLoggerProvider)
          .w(
            '[ReviewPromptGate] openStoreListing failed',
            error: e,
            stackTrace: st,
          );
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.aboutRateAppLaunchFailed)),
        );
      }
    }
  }
}
