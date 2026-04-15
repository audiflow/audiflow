import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_label_format.dart';

/// Inline status text rendered next to the sleep-timer icon on the
/// full player screen. Shows nothing when no timer is running.
///
/// Refreshes once per second while a duration timer is active so the
/// countdown stays current.
class SleepTimerStatusLabel extends ConsumerStatefulWidget {
  const SleepTimerStatusLabel({super.key});

  @override
  ConsumerState<SleepTimerStatusLabel> createState() =>
      _SleepTimerStatusLabelState();
}

class _SleepTimerStatusLabelState extends ConsumerState<SleepTimerStatusLabel> {
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepTimerControllerProvider);
    final l10n = AppLocalizations.of(context);
    final label = formatSleepTimerShortLabel(state.config, l10n);
    if (label == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
