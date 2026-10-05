import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Widget host that listens to [SleepTimerController.events] and shows
/// a snackbar while the app is in the foreground when a timer fires, or
/// when it is cancelled because the listener left its target.
///
/// Wrap a wide widget (e.g. body of a Scaffold) so ScaffoldMessenger is
/// in scope. No-op if ScaffoldMessenger is unavailable.
class SleepTimerSnackbarHost extends ConsumerStatefulWidget {
  const SleepTimerSnackbarHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SleepTimerSnackbarHost> createState() =>
      _SleepTimerSnackbarHostState();
}

class _SleepTimerSnackbarHostState
    extends ConsumerState<SleepTimerSnackbarHost> {
  StreamSubscription<SleepTimerEvent>? _sub;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(sleepTimerControllerProvider.notifier);
    _sub = notifier.events.listen(_showSnackbar);
  }

  void _showSnackbar(SleepTimerEvent event) {
    if (!mounted || _isInBackground) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final l10n = AppLocalizations.of(context);
    final message = switch (event) {
      SleepTimerFired() => l10n.sleepTimerFiredSnackbar,
      SleepTimerCancelled() => l10n.sleepTimerCancelledSnackbar,
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  // A snackbar queued while hidden would surface stale on return.
  static bool get _isInBackground =>
      switch (WidgetsBinding.instance.lifecycleState) {
        AppLifecycleState.hidden ||
        AppLifecycleState.paused ||
        AppLifecycleState.detached => true,
        _ => false,
      };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
