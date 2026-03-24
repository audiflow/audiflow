import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Full-screen overlay displayed during voice command interaction.
///
/// Shows:
/// - Listening indicator with animated microphone
/// - Real-time partial transcription
/// - Processing/executing status
/// - Success/error messages
/// - Cancel button
class VoiceListeningOverlay extends ConsumerWidget {
  const VoiceListeningOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);

    // Only show overlay when not idle
    if (voiceState is VoiceIdle) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildStateIndicator(context, voiceState),
              const SizedBox(height: 32),
              _buildStatusText(context, voiceState),
              const SizedBox(height: 16),
              _buildTranscriptText(context, voiceState),
              const Spacer(),
              if (_showCancelButton(voiceState))
                _buildCancelButton(context, ref),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicator(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (state) {
      VoiceListening() => _PulsingMicIndicator(color: colorScheme.primary),
      VoiceProcessing() => CircularProgressIndicator(
        color: colorScheme.primary,
        strokeWidth: 3,
      ),
      VoiceExecuting() => CircularProgressIndicator(
        color: colorScheme.tertiary,
        strokeWidth: 3,
      ),
      VoiceSuccess() => Icon(
        Symbols.check_circle,
        size: 80,
        color: colorScheme.tertiary,
      ),
      VoiceError() => Icon(Symbols.error, size: 80, color: colorScheme.error),
      VoiceIdle() => const SizedBox.shrink(),
      // Placeholder rendering for settings states — Task 11 will add proper UI.
      VoiceSettingsAutoApplied() => Icon(
        Symbols.check_circle,
        size: 80,
        color: colorScheme.tertiary,
      ),
      VoiceSettingsDisambiguation() => CircularProgressIndicator(
        color: colorScheme.primary,
        strokeWidth: 3,
      ),
      VoiceSettingsLowConfidence() => CircularProgressIndicator(
        color: colorScheme.secondary,
        strokeWidth: 3,
      ),
    };
  }

  Widget _buildStatusText(BuildContext context, VoiceRecognitionState state) {
    final textTheme = Theme.of(context).textTheme;

    final text = switch (state) {
      VoiceListening() => 'Listening...',
      VoiceProcessing() => 'Processing...',
      VoiceExecuting(command: final cmd) =>
        'Executing: ${_formatIntent(cmd.intent)}',
      VoiceSuccess(message: final msg) => msg,
      VoiceError(message: final msg) => msg,
      VoiceIdle() => '',
      // Placeholder text for settings states — Task 11 will add proper UI.
      VoiceSettingsAutoApplied() => 'Setting applied',
      VoiceSettingsDisambiguation() => 'Which setting did you mean?',
      VoiceSettingsLowConfidence() => 'Confirm setting change?',
    };

    final color = switch (state) {
      VoiceError() => Theme.of(context).colorScheme.error,
      _ => Colors.white,
    };

    return Text(
      text,
      style: textTheme.headlineSmall?.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTranscriptText(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    final textTheme = Theme.of(context).textTheme;

    final transcript = switch (state) {
      VoiceListening(partialTranscript: final text) => text ?? '',
      VoiceProcessing(transcription: final text) => '"$text"',
      _ => '',
    };

    if (transcript.isEmpty) {
      return const SizedBox(height: 24);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        transcript,
        style: textTheme.bodyLarge?.copyWith(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  bool _showCancelButton(VoiceRecognitionState state) {
    return state is VoiceListening || state is VoiceProcessing;
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () {
        final orchestrator = ref.read(
          voiceCommandOrchestratorProvider.notifier,
        );
        orchestrator.cancelVoiceCommand();
      },
      icon: const Icon(Symbols.close, color: Colors.white70),
      label: Text(
        'Cancel',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white70),
      ),
    );
  }

  String _formatIntent(VoiceIntent intent) {
    return switch (intent) {
      VoiceIntent.play => 'Play',
      VoiceIntent.pause => 'Pause',
      VoiceIntent.stop => 'Stop',
      VoiceIntent.skipForward => 'Skip forward',
      VoiceIntent.skipBackward => 'Skip backward',
      VoiceIntent.seek => 'Seek',
      VoiceIntent.search => 'Search',
      VoiceIntent.goToLibrary => 'Library',
      VoiceIntent.goToQueue => 'Queue',
      VoiceIntent.openSettings => 'Settings',
      VoiceIntent.addToQueue => 'Add to queue',
      VoiceIntent.removeFromQueue => 'Remove from queue',
      VoiceIntent.clearQueue => 'Clear queue',
      VoiceIntent.changeSettings => 'Change setting',
      VoiceIntent.unknown => 'Unknown',
    };
  }
}

/// Animated pulsing microphone indicator for listening state.
class _PulsingMicIndicator extends StatefulWidget {
  const _PulsingMicIndicator({required this.color});

  final Color color;

  @override
  State<_PulsingMicIndicator> createState() => _PulsingMicIndicatorState();
}

class _PulsingMicIndicatorState extends State<_PulsingMicIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(
                        alpha: _opacityAnimation.value,
                      ),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          // Static microphone icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
            child: const Icon(
              Symbols.mic,
              size: 40,
              color: Colors.white,
              fill: 1,
            ),
          ),
        ],
      ),
    );
  }
}
