import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/haptics/haptics_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Non-production screen for feeling each catalog haptic on a device.
///
/// Rows play through the app's real player, so the level selector at the
/// top (which edits the saved setting) gates them exactly as it gates the
/// rest of the app. Token meanings are fixture text copied from
/// `docs/design/haptics.md`, not user-facing copy, so they are not
/// localized.
class HapticsCatalogScreen extends ConsumerWidget {
  const HapticsCatalogScreen({super.key});

  static const _meanings = {
    HapticToken.selection: 'One discrete option became selected',
    HapticToken.toggleOn: 'A switch turned on',
    HapticToken.toggleOff: 'A switch turned off',
    HapticToken.tap: 'A low-key action was accepted',
    HapticToken.longPress: 'A long press reached its activation time',
    HapticToken.thresholdCross: 'A drag passed the action threshold',
    HapticToken.thresholdRelease: 'A drag moved back below the threshold',
    HapticToken.dragPickUp: 'A reorderable item was picked up',
    HapticToken.dragStep: 'A dragged item moved past a neighbor',
    HapticToken.dragDrop: 'A dragged item was put down',
    HapticToken.detent: 'A continuous gesture passed a meaningful mark',
    HapticToken.success: 'A user-initiated task completed',
    HapticToken.warning: 'A confirmation for an irreversible action appeared',
    HapticToken.error: 'A user-initiated task failed',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = HapticsScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.developerHapticsCatalogTitle)),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(Spacing.md),
            child: _LevelSelector(),
          ),
          const Divider(height: 1),
          for (final token in HapticToken.values)
            ListTile(
              title: Text(token.name),
              subtitle: Text(_subtitle(l10n, token)),
              trailing: token.playsInReducedMode
                  ? Text(l10n.developerHapticsPlaysInReduced)
                  : null,
              onTap: () => player.play(token),
            ),
        ],
      ),
    );
  }

  String _subtitle(AppLocalizations l10n, HapticToken token) {
    final meaning = _meanings[token] ?? '';
    // Android has no warning constant; flag it so silence is not
    // mistaken for a bug while testing.
    if (token != HapticToken.warning) return meaning;
    return '$meaning\n${l10n.developerHapticsSilentOnAndroid}';
  }
}

class _LevelSelector extends ConsumerWidget {
  const _LevelSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final level = ref.watch(hapticFeedbackLevelControllerProvider);
    return SegmentedButton<HapticFeedbackLevel>(
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
    );
  }
}
