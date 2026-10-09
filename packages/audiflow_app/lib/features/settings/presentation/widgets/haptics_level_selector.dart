import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
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
    final supported = ref.watch(hapticsSupportedProvider).value ?? true;
    final level = ref.watch(effectiveHapticFeedbackLevelProvider);
    final selector = SizedBox(
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
        // Locked to Off where nothing could play, rather than offering
        // choices that make no difference.
        onSelectionChanged: supported
            ? (selection) => _select(ref, selection.single)
            : null,
      ),
    );
    if (supported) return selector;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        selector,
        const SizedBox(height: 8),
        Text(
          l10n.settingsHapticsUnsupported,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // The feedback follows the level being chosen, not the one being left:
  // the old level's gate would drop it when leaving Reduced (which skips
  // selection), and choosing Off must stay silent.
  void _select(WidgetRef ref, HapticFeedbackLevel level) {
    if (level != HapticFeedbackLevel.off) {
      ref.read(platformHapticPlayerProvider).play(HapticToken.selection);
    }
    unawaited(
      ref.read(hapticFeedbackLevelControllerProvider.notifier).setLevel(level),
    );
  }
}
