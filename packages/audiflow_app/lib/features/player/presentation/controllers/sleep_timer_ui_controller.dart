import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Widget host that listens to [SleepTimerController.events] and shows
/// a snackbar when a timer fires while the app is in the foreground.
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
    _sub = notifier.events.listen((event) {
      if (event is! SleepTimerFired) return;
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      final l10n = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sleepTimerFiredSnackbar)),
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
