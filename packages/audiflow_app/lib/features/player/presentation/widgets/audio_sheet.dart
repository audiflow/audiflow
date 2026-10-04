import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Opens the player's Audio sheet wired to the playback speed state.
Future<void> showAudioSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(playbackSpeedSettingsControllerProvider);
        final controller = ref.read(audioPlayerControllerProvider.notifier);
        return AudioSheet(
          speed: settings.speed,
          chipSpeeds: settings.chipSpeeds,
          onSpeedPreview: (speed) =>
              controller.setSpeed(speed, transient: true),
          onSpeedCommit: controller.setSpeed,
        );
      },
    ),
  );
}

/// Audio settings sheet for the full player.
///
/// Laid out as a column of sections so later audio options (per-podcast
/// speed override, output routing) can be appended below the speed
/// section without restructuring it.
class AudioSheet extends StatelessWidget {
  const AudioSheet({
    super.key,
    required this.speed,
    required this.chipSpeeds,
    required this.onSpeedPreview,
    required this.onSpeedCommit,
  });

  /// Current playback speed.
  final double speed;

  /// Quick-pick speeds in ascending order (normal plus recents).
  final List<double> chipSpeeds;

  /// Applies an intermediate slider step without recording it.
  final ValueChanged<double> onSpeedPreview;

  /// Applies and records a final speed choice (chip tap, slider release).
  final ValueChanged<double> onSpeedCommit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
            const SizedBox(height: 16),
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
