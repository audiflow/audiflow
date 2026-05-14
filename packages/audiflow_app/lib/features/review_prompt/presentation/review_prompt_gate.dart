import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/utils/rate_app_service.dart';
import 'widgets/review_prompt_dialog.dart';

/// Hooks into the review-prompt event stream and shows the dialog when
/// the app is in the foreground.
///
/// If the trigger fires while the app is backgrounded, the event is
/// dropped — the next playback session re-arms the trigger so we get
/// another chance.
class ReviewPromptGate extends ConsumerStatefulWidget {
  const ReviewPromptGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReviewPromptGate> createState() => _ReviewPromptGateState();
}

class _ReviewPromptGateState extends ConsumerState<ReviewPromptGate> {
  bool _dialogOpen = false;

  bool _isAppForeground() {
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(reviewPromptTriggerEventsProvider, (_, _) {
      unawaited(_maybeShow());
    });
    return widget.child;
  }

  Future<void> _maybeShow() async {
    if (_dialogOpen) return;
    if (!_isAppForeground()) return;

    _dialogOpen = true;
    try {
      final action = await ReviewPromptDialog.show(context);
      if (!mounted) return;
      await _applyAction(action);
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> _applyAction(ReviewPromptAction? action) async {
    final repo = ref.read(reviewPromptRepositoryProvider);
    final now = DateTime.now();

    switch (action) {
      case ReviewPromptAction.rateNow:
        await repo.markUserRated();
        await repo.recordPromptShown(now);
        await ref.read(rateAppServiceProvider).openStoreListing();
      case ReviewPromptAction.later:
        await repo.recordPromptShown(now);
      case ReviewPromptAction.dontAskAgain:
        await repo.markOptedOut();
        await repo.recordPromptShown(now);
      case null:
        await repo.recordPromptShown(now);
    }
  }
}
