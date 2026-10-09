import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/haptics/haptics_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// On / Reduced / Off selector bound to the saved haptic feedback level.
class HapticsLevelSelector extends ConsumerWidget {
  const HapticsLevelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final level = ref.watch(hapticFeedbackLevelControllerProvider);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<HapticFeedbackLevel>(
        segments: [
          ButtonSegment(
            value: HapticFeedbackLevel.on,
            label: Text(l10n.settingsHapticsLevelOn),
          ),
          ButtonSegment(
            value: HapticFeedbackLevel.reduced,
            label: Text(l10n.settingsHapticsLevelReduced),
          ),
          ButtonSegment(
            value: HapticFeedbackLevel.off,
            label: Text(l10n.settingsHapticsLevelOff),
          ),
        ],
        selected: {level},
        onSelectionChanged: (selection) => unawaited(
          ref
              .read(hapticFeedbackLevelControllerProvider.notifier)
              .setLevel(selection.single),
        ),
      ),
    );
  }
}
