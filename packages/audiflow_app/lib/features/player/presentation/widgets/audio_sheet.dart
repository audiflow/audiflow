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
///
/// [alignment] places the sheet on wide screens; see [showCompactSheet].
Future<void> showAudioSheet(
  BuildContext context, {
  int? podcastId,
  AlignmentDirectional alignment = AlignmentDirectional.bottomCenter,
}) {
  // Pin the podcast for the life of the sheet: following the now-playing
  // podcast would retarget a drag in progress when the queue advances,
  // sending the rest of it to another podcast's (or the global) settings.
  final targetId =
      podcastId ??
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(nowPlayingPodcastIdProvider);
  return showCompactSheet<void>(
    context: context,
    alignment: alignment,
    maxWidth: CompactSheet.narrowWidth,
    builder: (_) => _AudioSheetHost(podcastId: targetId),
  );
}

class _AudioSheetHost extends ConsumerWidget {
  const _AudioSheetHost({required this.podcastId});

  final int? podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetId = podcastId;
    final effective = ref.watch(effectiveAudioSettingsProvider(targetId));
    final chipSpeeds = ref
        .watch(playbackSpeedSettingsControllerProvider)
        .chipSpeeds;
    final effectsSupported = ref.watch(audioEffectsSupportedProvider);
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
          : (enabled) =>
                setPodcastAudioOverride(ref, targetId, enabled: enabled),
      speed: effective.settings.speed,
      chipSpeeds: chipSpeeds,
      onSpeedPreview: (speed) =>
          player.setSpeed(speed, scope: scope, transient: true),
      onSpeedCommit: (speed) => player.setSpeed(speed, scope: scope),
      effects: effectsSupported ? effective.settings.effects : null,
      onEffectChanged: (effect, enabled) =>
          setAudioEffect(ref, effect, enabled: enabled, scope: scope),
    );
  }
}

/// Audio settings sheet for the full player and the podcast detail menu.
///
/// Laid out as a column of sections: the speed, then the effects where
/// the platform supports them.
class AudioSheet extends StatelessWidget {
  const AudioSheet({
    super.key,
    required this.speed,
    required this.chipSpeeds,
    required this.onSpeedPreview,
    required this.onSpeedCommit,
    this.podcastOverride,
    this.onPodcastOverrideChanged,
    this.effects,
    this.onEffectChanged,
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

  /// Effects of the scope being edited. Null hides the effects section:
  /// the platform does not apply them.
  final PlaybackEffects? effects;

  /// Switches one effect on or off.
  final void Function(PlaybackEffect effect, bool enabled)? onEffectChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final override = podcastOverride;
    // Scrollable so a short landscape window or a large text size cannot
    // push the slider out of the sheet.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
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
                onChanged: HapticsScope.of(
                  context,
                ).toggleHaptic(onPodcastOverrideChanged),
              ),
            const SizedBox(height: 8),
            _SpeedSection(
              speed: speed,
              chipSpeeds: chipSpeeds,
              onSpeedPreview: onSpeedPreview,
              onSpeedCommit: onSpeedCommit,
            ),
            if (effects case final effects?) ...[
              const SizedBox(height: 16),
              _EffectsSection(effects: effects, onChanged: onEffectChanged),
            ],
          ],
        ),
      ),
    );
  }
}

class _EffectsSection extends StatelessWidget {
  const _EffectsSection({required this.effects, required this.onChanged});

  final PlaybackEffects effects;
  final void Function(PlaybackEffect effect, bool enabled)? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.audioSheetEffectsSection, style: theme.textTheme.labelLarge),
        for (final effect in PlaybackEffect.values)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_title(l10n, effect)),
            subtitle: Text(_caption(l10n, effect)),
            value: effects.isEnabled(effect),
            onChanged: HapticsScope.of(context).toggleHaptic(
              onChanged == null
                  ? null
                  : (enabled) => onChanged!(effect, enabled),
            ),
          ),
      ],
    );
  }

  static String _title(AppLocalizations l10n, PlaybackEffect effect) =>
      switch (effect) {
        PlaybackEffect.skipSilence => l10n.audioSheetSkipSilence,
        PlaybackEffect.voiceBoost => l10n.audioSheetVoiceBoost,
      };

  static String _caption(AppLocalizations l10n, PlaybackEffect effect) =>
      switch (effect) {
        PlaybackEffect.skipSilence => l10n.audioSheetSkipSilenceCaption,
        PlaybackEffect.voiceBoost => l10n.audioSheetVoiceBoostCaption,
      };
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
              HapticsScope.of(context).play(HapticToken.selection);
              onSelected(chipSpeed);
            },
          ),
      ],
    );
  }
}

/// Switches [effect] for [scope], logging a failed write (the settings
/// controller has already rolled the toggle back).
Future<void> setAudioEffect(
  WidgetRef ref,
  PlaybackEffect effect, {
  required bool enabled,
  required AudioSettingsScope scope,
}) async {
  final player = ref.read(audioPlayerControllerProvider.notifier);
  try {
    await player.setEffect(effect, enabled: enabled, scope: scope);
  } catch (error, stackTrace) {
    // The settings controller has already rolled the toggle back; log
    // rather than leave an unhandled error from a switch callback.
    ref
        .read(namedLoggerProvider('AudioSheet'))
        .e('Failed to set $effect', error: error, stackTrace: stackTrace);
  }
}

/// Turns [podcastId]'s audio override on or off, logging a failed write
/// (the controller has already rolled the switch back).
Future<void> setPodcastAudioOverride(
  WidgetRef ref,
  int podcastId, {
  required bool enabled,
}) async {
  final controller = ref.read(
    podcastAudioOverrideControllerProvider(podcastId).notifier,
  );
  try {
    await (enabled ? controller.enable() : controller.disable());
  } catch (error, stackTrace) {
    // The controller has already rolled the switch back; log rather
    // than leave an unhandled error from a switch callback.
    ref
        .read(namedLoggerProvider('AudioSheet'))
        .e(
          'Failed to toggle podcast override',
          error: error,
          stackTrace: stackTrace,
        );
  }
}
