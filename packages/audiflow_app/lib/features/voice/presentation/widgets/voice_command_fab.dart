import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Floating action button for initiating voice commands.
///
/// Displays a microphone icon that pulses when listening. Tapping the button
/// starts voice recognition; tapping again while listening cancels it.
class VoiceCommandFab extends ConsumerStatefulWidget {
  const VoiceCommandFab({super.key});

  @override
  ConsumerState<VoiceCommandFab> createState() => _VoiceCommandFabState();
}

class _VoiceCommandFabState extends ConsumerState<VoiceCommandFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final isListening = voiceState is VoiceListening;
    final isProcessing =
        voiceState is VoiceProcessing || voiceState is VoiceExecuting;

    // Control pulse animation based on state
    if (isListening) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isListening ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: FloatingActionButton(
            onPressed: isProcessing ? null : () => _handleTap(isListening),
            backgroundColor: _getBackgroundColor(context, voiceState),
            foregroundColor: _getForegroundColor(context, voiceState),
            tooltip: _getTooltip(voiceState),
            child: _buildIcon(voiceState),
          ),
        );
      },
    );
  }

  void _handleTap(bool isListening) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);

    if (isListening) {
      orchestrator.cancelVoiceCommand();
    } else {
      orchestrator.startVoiceCommand();
    }
  }

  Widget _buildIcon(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => const Icon(Symbols.mic),
      VoiceListening() => const Icon(Symbols.mic, fill: 1),
      VoiceProcessing() => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      VoiceExecuting() => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      VoiceSuccess() => const Icon(Symbols.check_circle),
      VoiceError() => const Icon(Symbols.error),
    };
  }

  Color _getBackgroundColor(BuildContext context, VoiceRecognitionState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (state) {
      VoiceIdle() => colorScheme.primaryContainer,
      VoiceListening() => colorScheme.primary,
      VoiceProcessing() => colorScheme.primaryContainer,
      VoiceExecuting() => colorScheme.primaryContainer,
      VoiceSuccess() => colorScheme.tertiaryContainer,
      VoiceError() => colorScheme.errorContainer,
    };
  }

  Color _getForegroundColor(BuildContext context, VoiceRecognitionState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (state) {
      VoiceIdle() => colorScheme.onPrimaryContainer,
      VoiceListening() => colorScheme.onPrimary,
      VoiceProcessing() => colorScheme.onPrimaryContainer,
      VoiceExecuting() => colorScheme.onPrimaryContainer,
      VoiceSuccess() => colorScheme.onTertiaryContainer,
      VoiceError() => colorScheme.onErrorContainer,
    };
  }

  String _getTooltip(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => 'Voice command',
      VoiceListening() => 'Listening... tap to cancel',
      VoiceProcessing() => 'Processing...',
      VoiceExecuting() => 'Executing...',
      VoiceSuccess() => 'Success',
      VoiceError() => 'Error occurred',
    };
  }
}
