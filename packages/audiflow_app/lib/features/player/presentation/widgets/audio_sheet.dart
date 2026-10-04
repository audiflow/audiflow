import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Opens the Audio sheet for [podcastId], or for the now-playing podcast
/// when [podcastId] is null.
///
/// The sheet edits the podcast's override while it has one and the
/// global settings otherwise. Without a podcast (an episode that is not
/// in the database) it only edits the global settings.
Future<void> showAudioSheet(BuildContext context, {int? podcastId}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AudioSheetHost(podcastId: podcastId),
  );
}

class _AudioSheetHost extends ConsumerWidget {
  const _AudioSheetHost({required this.podcastId});

  final int? podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetId = podcastId ?? ref.watch(nowPlayingPodcastIdProvider);
    final effective = ref.watch(effectiveAudioSettingsProvider(targetId));
    final chipSpeeds = ref
        .watch(playbackSpeedSettingsControllerProvider)
        .chipSpeeds;
    // Only while the override loads; short enough that a spinner would
    // just flicker.
    if (effective == null) return const SizedBox(height: 160);
    final scope = effective.scope;
    final player = ref.read(audioPlayerControllerProvider.notifier);
    return AudioSheet(
      podcastOverride: targetId == null
          ? null
          : scope is PodcastAudioSettingsScope,
      onPodcastOverrideChanged: targetId == null
          ? null
          : (enabled) => _setOverride(ref, targetId, enabled: enabled),
      speed: effective.settings.speed,
      chipSpeeds: chipSpeeds,
      onSpeedPreview: (speed) =>
          player.setSpeed(speed, scope: scope, transient: true),
      onSpeedCommit: (speed) => player.setSpeed(speed, scope: scope),
    );
  }

  Future<void> _setOverride(
    WidgetRef ref,
    int podcastId, {
    required bool enabled,
  }) {
    final controller = ref.read(
      podcastAudioOverrideControllerProvider(podcastId).notifier,
    );
    return enabled ? controller.enable() : controller.disable();
  }
}

/// Audio settings sheet for the full player and the podcast detail menu.
///
/// Laid out as a column of sections so later audio options (output
/// routing, skip silence) can be appended below the speed section
/// without restructuring it.
class AudioSheet extends StatelessWidget {
  const AudioSheet({
    super.key,
    required this.speed,
    required this.chipSpeeds,
    required this.onSpeedPreview,
    required this.onSpeedCommit,
    this.podcastOverride,
    this.onPodcastOverrideChanged,
  });

  /// Current playback speed of the scope being edited.
  final double speed;

  /// Quick-pick speeds in ascending order (normal plus recents).
  final List<double> chipSpeeds;

  /// Applies an intermediate slider step without recording it.
  final ValueChanged<double> onSpeedPreview;

  /// Applies and records a final speed choice (chip tap, slider release).
  final ValueChanged<double> onSpeedCommit;

  /// Whether the controls edit a podcast override (true) or the global
  /// settings (false). Null hides the switch: there is no podcast to
  /// scope to.
  final bool? podcastOverride;

  /// Turns the podcast override on or off.
  final ValueChanged<bool>? onPodcastOverrideChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final override = podcastOverride;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.audioSheetTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (override != null)
              // Controls below stay enabled either way; the caption says
              // which settings they edit.
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.audioSheetPodcastOverride),
                subtitle: Text(
                  override
                      ? l10n.audioSheetScopePodcast
                      : l10n.audioSheetScopeGlobal,
                ),
                value: override,
                onChanged: onPodcastOverrideChanged,
              ),
            const SizedBox(height: 8),
            _SpeedSection(
              speed: speed,
              chipSpeeds: chipSpeeds,
              onSpeedPreview: onSpeedPreview,
              onSpeedCommit: onSpeedCommit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedSection extends StatelessWidget {
  const _SpeedSection({
    required this.speed,
    required this.chipSpeeds,
    required this.onSpeedPreview,
    required this.onSpeedCommit,
  });

  final double speed;
  final List<double> chipSpeeds;
  final ValueChanged<double> onSpeedPreview;
  final ValueChanged<double> onSpeedCommit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // No big speed readout: the selected chip and the slider's value
        // indicator already show the current speed.
        Text(l10n.audioSheetSpeedSection, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _SpeedChips(
          speed: speed,
          chipSpeeds: chipSpeeds,
          onSelected: onSpeedCommit,
        ),
        const SizedBox(height: 8),
        PlaybackSpeedSlider(
          speed: speed,
          onChanged: onSpeedPreview,
          onChangeEnd: onSpeedCommit,
        ),
      ],
    );
  }
}

class _SpeedChips extends StatelessWidget {
  const _SpeedChips({
    required this.speed,
    required this.chipSpeeds,
    required this.onSelected,
  });

  final double speed;
  final List<double> chipSpeeds;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (final chipSpeed in chipSpeeds)
          ChoiceChip(
            label: Text(
              chipSpeed == PlaybackSpeedScale.normal
                  ? l10n.playbackSpeedNormal
                  : PlaybackSpeedScale.label(chipSpeed),
            ),
            selected: chipSpeed == speed,
            onSelected: (_) {
              // Re-tapping the current speed is not a new choice. The chip
              // stays enabled so the highlight keeps its selected styling.
              if (chipSpeed == speed) return;
              onSelected(chipSpeed);
            },
          ),
      ],
    );
  }
}
