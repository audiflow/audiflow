import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Inline app bar button that shows current voice state and triggers commands.
///
/// Designed for placement in [AppBar.actions]. The widget wraps itself in a
/// [Padding] with 4pt right inset for proper app bar spacing.
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
        orchestrator.startVoiceCommand();
      case VoiceListening():
        orchestrator.cancelVoiceCommand();
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

  bool _isTapDisabled(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => false,
      VoiceListening() => false,
      VoiceSuccess() => false,
      VoiceError() => false,
      VoiceProcessing() => true,
      VoiceExecuting() => true,
      VoiceSettingsAutoApplied() => true,
      VoiceSettingsDisambiguation() => true,
      VoiceSettingsLowConfidence() => true,
    };
  }

  Color _backgroundColor(BuildContext context, VoiceRecognitionState state) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => cs.primary.withValues(alpha: 0.1),
      VoiceListening() => cs.primary.withValues(alpha: 0.25),
      VoiceProcessing() => cs.primary.withValues(alpha: 0.15),
      VoiceExecuting() => cs.primary.withValues(alpha: 0.15),
      VoiceSuccess() => cs.tertiary.withValues(alpha: 0.15),
      VoiceError() => cs.error.withValues(alpha: 0.15),
      VoiceSettingsAutoApplied() => cs.secondary.withValues(alpha: 0.15),
      VoiceSettingsDisambiguation() => cs.secondary.withValues(alpha: 0.15),
      VoiceSettingsLowConfidence() => cs.secondary.withValues(alpha: 0.15),
    };
  }

  Color _iconColor(BuildContext context, VoiceRecognitionState state) {
    final cs = Theme.of(context).colorScheme;
    return switch (state) {
      VoiceIdle() => cs.primary,
      // Accent amber per visual spec.
      VoiceListening() => const Color(0xFFFFC107),
      VoiceProcessing() => cs.primary,
      VoiceExecuting() => cs.primary,
      VoiceSuccess() => cs.tertiary,
      VoiceError() => cs.error,
      VoiceSettingsAutoApplied() => cs.secondary,
      VoiceSettingsDisambiguation() => cs.secondary,
      VoiceSettingsLowConfidence() => cs.secondary,
    };
  }

  double _iconFill(VoiceRecognitionState state) {
    return switch (state) {
      VoiceListening() => 1,
      VoiceIdle() => 0,
      VoiceProcessing() => 0,
      VoiceExecuting() => 0,
      VoiceSuccess() => 0,
      VoiceError() => 0,
      VoiceSettingsAutoApplied() => 0,
      VoiceSettingsDisambiguation() => 0,
      VoiceSettingsLowConfidence() => 0,
    };
  }

  List<BoxShadow> _boxShadows(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    if (state is! VoiceListening) return const [];
    final primary = Theme.of(context).colorScheme.primary;
    return [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 12)];
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);

    final isPulsing =
        voiceState is VoiceProcessing || voiceState is VoiceExecuting;
    if (isPulsing) {
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

    final bgColor = _backgroundColor(context, voiceState);
    final iconColor = _iconColor(context, voiceState);
    final fill = _iconFill(voiceState);
    final shadows = _boxShadows(context, voiceState);
    final disabled = _isTapDisabled(voiceState);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).voiceCommandButton,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final opacity = isPulsing ? _pulseAnimation.value : 1.0;
            return Opacity(opacity: opacity, child: child);
          },
          child: GestureDetector(
            onTap: disabled ? null : () => _handleTap(voiceState),
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
              child: Icon(Symbols.mic, fill: fill, size: 20, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
