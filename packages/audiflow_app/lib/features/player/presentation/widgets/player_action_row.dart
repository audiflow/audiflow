import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import 'audio_sheet.dart';
import 'sleep_timer_icon_button.dart';
import 'sleep_timer_status_label.dart';

/// Bottom action row of the full player.
///
/// Three equal slots: Audio (speed), output picker, sleep timer. The
/// output picker slot is omitted while [outputPicker] is null, so the
/// remaining slots spread across the row.
class PlayerActionRow extends StatelessWidget {
  const PlayerActionRow({super.key, this.outputPicker});

  /// Widget for the audio output picker slot; hidden when null.
  final Widget? outputPicker;

  @override
  Widget build(BuildContext context) {
    final picker = outputPicker;
    return Row(
      children: [
        const Expanded(child: Center(child: AudioButton())),
        if (picker != null) Expanded(child: Center(child: picker)),
        const Expanded(child: Center(child: _SleepTimerSlot())),
      ],
    );
  }
}

/// Opens the Audio sheet; its label shows the current speed.
class AudioButton extends ConsumerWidget {
  const AudioButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The speed in effect for the now-playing podcast (override or
    // global); the global speed while the override is still loading.
    final globalSpeed = ref.watch(
      playbackSpeedSettingsControllerProvider.select((s) => s.speed),
    );
    final speed =
        ref.watch(nowPlayingAudioSettingsProvider)?.settings.speed ??
        globalSpeed;
    final label = PlaybackSpeedScale.label(speed);
    return TextButton.icon(
      icon: const Icon(Symbols.speed),
      label: Text(
        label,
        semanticsLabel: l10n.playerAudioButtonLabel(label),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: () => showAudioSheet(context),
    );
  }
}

class _SleepTimerSlot extends ConsumerWidget {
  const _SleepTimerSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      sleepTimerControllerProvider.select(
        (state) => state.config is! SleepTimerConfigOff,
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SleepTimerIconButton(),
        // Only an active timer has a label; an empty tappable box would
        // be an unlabeled button for screen readers.
        if (isActive) const Flexible(child: _SleepTimerLabelButton()),
      ],
    );
  }
}

/// Status label that opens the sleep-timer sheet, giving the icon a
/// larger tap target while a timer runs.
class _SleepTimerLabelButton extends StatelessWidget {
  const _SleepTimerLabelButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => showSleepTimerSheet(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: SleepTimerStatusLabel(),
        ),
      ),
    );
  }
}
