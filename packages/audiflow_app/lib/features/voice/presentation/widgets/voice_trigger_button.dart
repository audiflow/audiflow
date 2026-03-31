import 'dart:async';

import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'voice_trigger_style.dart';

/// Inline app bar button that shows current voice state and triggers commands.
///
/// Designed for placement in [AppBar.actions]. The widget wraps itself in a
/// [Padding] with 4pt right inset for proper app bar spacing.
///
/// Uses a 48x48 hit area (Material minimum) around a 36x36 visual container.
class VoiceTriggerButton extends ConsumerStatefulWidget {
  const VoiceTriggerButton({super.key});

  @override
  ConsumerState<VoiceTriggerButton> createState() => _VoiceTriggerButtonState();
}

class _VoiceTriggerButtonState extends ConsumerState<VoiceTriggerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(VoiceRecognitionState state) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    switch (state) {
      case VoiceIdle():
        unawaited(orchestrator.startVoiceCommand());
      case VoiceListening():
        unawaited(orchestrator.cancelVoiceCommand());
      case VoiceSuccess():
        orchestrator.resetToIdle();
      case VoiceError():
        orchestrator.resetToIdle();
      // Processing, executing and settings states: tap is disabled (no-op).
      case VoiceProcessing():
      case VoiceExecuting():
      case VoiceSettingsAutoApplied():
      case VoiceSettingsDisambiguation():
      case VoiceSettingsLowConfidence():
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final cs = Theme.of(context).colorScheme;

    final pulsing = VoiceTriggerStyle.isPulsing(voiceState);
    if (pulsing) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController
          ..stop()
          ..reset();
      }
    }

    final bgColor = AppBarTriggerStyle.backgroundColor(cs, voiceState);
    final iconColor = AppBarTriggerStyle.iconColor(cs, voiceState);
    final fill = VoiceTriggerStyle.iconFill(voiceState);
    final shadows = AppBarTriggerStyle.boxShadows(cs, voiceState);
    final disabled = VoiceTriggerStyle.isTapDisabled(voiceState);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Semantics(
        button: true,
        enabled: !disabled,
        label: AppLocalizations.of(context).voiceCommandButton,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final opacity = pulsing ? _pulseAnimation.value : 1.0;
            return Opacity(opacity: opacity, child: child);
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: disabled ? null : () => _handleTap(voiceState),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: shadows,
                    ),
                    child: Icon(
                      Symbols.mic,
                      fill: fill,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
