import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, DuckInterruptionBehavior;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Screen for configuring playback settings: speed, skip
/// durations, auto-complete threshold, and continuous playback.
class PlaybackSettingsScreen extends ConsumerWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final speed = repo.getPlaybackSpeed();
    final skipForward = repo.getSkipForwardSeconds();
    final skipBackward = repo.getSkipBackwardSeconds();
    final threshold = repo.getAutoCompleteThreshold();
    final continuous = repo.getContinuousPlayback();
    final autoPlayOrder = repo.getAutoPlayOrder();
    final duckBehavior = repo.getDuckInterruptionBehavior();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPlaybackTitle)),
      body: ListView(
        children: [
          _PlaybackSpeedTile(
            speed: speed,
            onChanged: (v) => _updateSpeed(ref, repo, v),
          ),
          _SkipForwardTile(
            seconds: skipForward,
            onChanged: (v) => _update(ref, () => repo.setSkipForwardSeconds(v)),
          ),
          _SkipBackwardTile(
            seconds: skipBackward,
            onChanged: (v) =>
                _update(ref, () => repo.setSkipBackwardSeconds(v)),
          ),
          _AutoCompleteThresholdTile(
            threshold: threshold,
            onChanged: (v) =>
                _update(ref, () => repo.setAutoCompleteThreshold(v)),
          ),
          SwitchListTile(
            title: Text(l10n.playbackContinuousTitle),
            subtitle: Text(l10n.playbackContinuousSubtitle),
            value: continuous,
            onChanged: (v) => _update(ref, () => repo.setContinuousPlayback(v)),
          ),
          _AutoPlayOrderTile(
            order: autoPlayOrder,
            onChanged: (v) => _update(ref, () => repo.setAutoPlayOrder(v)),
          ),
          _DuckInterruptionBehaviorTile(
            behavior: duckBehavior,
            onChanged: (v) =>
                _update(ref, () => repo.setDuckInterruptionBehavior(v)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSpeed(
    WidgetRef ref,
    AppSettingsRepository repo,
    double speed,
  ) async {
    // Use controller's setSpeed to apply to player and persist in one call
    await ref.read(audioPlayerControllerProvider.notifier).setSpeed(speed);
    ref.invalidate(appSettingsRepositoryProvider);
  }

  Future<void> _update(WidgetRef ref, Future<void> Function() setter) async {
    await setter();
    ref.invalidate(appSettingsRepositoryProvider);
  }
}

class _PlaybackSpeedTile extends StatelessWidget {
  const _PlaybackSpeedTile({required this.speed, required this.onChanged});

  final double speed;
  final ValueChanged<double> onChanged;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveSpeed = _speeds.contains(speed) ? speed : 1.0;
    return ListTile(
      title: Text(l10n.playbackDefaultSpeed),
      trailing: DropdownButton<double>(
        value: effectiveSpeed,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: [
          for (final s in _speeds)
            DropdownMenuItem(value: s, child: Text('${s}x')),
        ],
      ),
    );
  }
}

class _SkipForwardTile extends StatelessWidget {
  const _SkipForwardTile({required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.playbackSkipForward,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10')),
                ButtonSegment(value: 15, label: Text('15')),
                ButtonSegment(value: 30, label: Text('30')),
                ButtonSegment(value: 45, label: Text('45')),
                ButtonSegment(value: 60, label: Text('60')),
              ],
              selected: {seconds},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipBackwardTile extends StatelessWidget {
  const _SkipBackwardTile({required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.playbackSkipBackward,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10')),
                ButtonSegment(value: 15, label: Text('15')),
                ButtonSegment(value: 30, label: Text('30')),
              ],
              selected: {seconds},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoCompleteThresholdTile extends StatelessWidget {
  const _AutoCompleteThresholdTile({
    required this.threshold,
    required this.onChanged,
  });

  final double threshold;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = (threshold * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.playbackAutoCompleteThreshold,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text('$percent%'),
            ],
          ),
          Slider(
            value: threshold.clamp(0.80, 0.99),
            min: 0.80,
            max: 0.99,
            divisions: 19,
            label: '$percent%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AutoPlayOrderTile extends StatelessWidget {
  const _AutoPlayOrderTile({required this.order, required this.onChanged});

  final AutoPlayOrder order;
  final ValueChanged<AutoPlayOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(l10n.playbackAutoPlayOrderTitle),
      subtitle: Text(l10n.playbackAutoPlayOrderSubtitle),
      trailing: DropdownButton<AutoPlayOrder>(
        value: order,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: [
          DropdownMenuItem(
            value: AutoPlayOrder.oldestFirst,
            child: Text(l10n.playbackAutoPlayOrderOldestFirst),
          ),
          DropdownMenuItem(
            value: AutoPlayOrder.asDisplayed,
            child: Text(l10n.playbackAutoPlayOrderAsDisplayed),
          ),
        ],
      ),
    );
  }
}

class _DuckInterruptionBehaviorTile extends StatelessWidget {
  const _DuckInterruptionBehaviorTile({
    required this.behavior,
    required this.onChanged,
  });

  final DuckInterruptionBehavior behavior;
  final ValueChanged<DuckInterruptionBehavior> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(l10n.playbackDuckInterruptionBehaviorTitle),
      subtitle: Text(l10n.playbackDuckInterruptionBehaviorSubtitle),
      trailing: DropdownButton<DuckInterruptionBehavior>(
        value: behavior,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: [
          DropdownMenuItem(
            value: DuckInterruptionBehavior.duck,
            child: Text(l10n.playbackDuckInterruptionBehaviorDuck),
          ),
          DropdownMenuItem(
            value: DuckInterruptionBehavior.pause,
            child: Text(l10n.playbackDuckInterruptionBehaviorPause),
          ),
        ],
      ),
    );
  }
}
