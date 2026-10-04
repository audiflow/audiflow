import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_label_format.dart';

/// Status line under the sleep-timer sheet title describing the active
/// timer. Renders nothing when no timer is running.
///
/// Refreshes once per second only while a duration timer is active, so
/// the countdown stays current without rebuilding for other modes.
class SleepTimerSheetStatusLine extends StatefulWidget {
  const SleepTimerSheetStatusLine({required this.config, super.key});

  final SleepTimerConfig config;

  @override
  State<SleepTimerSheetStatusLine> createState() =>
      _SleepTimerSheetStatusLineState();
}

class _SleepTimerSheetStatusLineState extends State<SleepTimerSheetStatusLine> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(SleepTimerSheetStatusLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    final isDuration = widget.config is SleepTimerConfigDuration;
    if (isDuration && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!isDuration && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  String _formatClock(DateTime deadline) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(deadline),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = formatSleepTimerSheetStatus(
      widget.config,
      AppLocalizations.of(context),
      formatClock: _formatClock,
    );
    if (label == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Text(
      label,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
