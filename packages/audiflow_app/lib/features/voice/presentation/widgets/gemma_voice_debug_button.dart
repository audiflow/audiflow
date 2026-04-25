import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/gemma_voice_capture_controller.dart';

/// Hold-to-talk debug surface for the Gemma 4 voice command path.
///
/// Not wired into production routing; intended for the developer settings
/// screen / a manual on-device test. Production trigger UX will land in
/// the cleanup PR that replaces the legacy STT path.
class GemmaVoiceDebugButton extends ConsumerWidget {
  const GemmaVoiceDebugButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gemmaVoiceCaptureControllerProvider);
    final notifier = ref.read(gemmaVoiceCaptureControllerProvider.notifier);

    final theme = Theme.of(context);
    final isRecording = state is GemmaCaptureRecording;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (_) => notifier.start(),
          onLongPressEnd: (_) => notifier.stop(),
          onLongPressCancel: notifier.cancel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isRecording
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconFor(state)),
                const SizedBox(width: 8),
                Text(_labelFor(state)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _StateLine(state: state),
      ],
    );
  }
}

class _StateLine extends StatelessWidget {
  const _StateLine({required this.state});

  final GemmaCaptureState state;

  @override
  Widget build(BuildContext context) {
    final text = switch (state) {
      GemmaCaptureIdle() => 'Hold to talk to Gemma 4',
      GemmaCaptureRecording() => 'Listening…',
      GemmaCaptureDispatching() => 'Thinking…',
      GemmaCaptureSuccess(:final command) => _formatCommand(command),
      GemmaCaptureFailure(:final reason) => 'Failed: ${reason.name}',
    };
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}

String _formatCommand(VoiceCommand command) {
  final reason = command.failureReason;
  if (reason != null) {
    return 'Unknown (${reason.name})';
  }
  return 'Intent: ${command.intent.name}';
}

IconData _iconFor(GemmaCaptureState state) => switch (state) {
  GemmaCaptureRecording() => Icons.mic,
  GemmaCaptureDispatching() => Icons.hourglass_top,
  _ => Icons.mic_none,
};

String _labelFor(GemmaCaptureState state) => switch (state) {
  GemmaCaptureRecording() => 'Recording',
  GemmaCaptureDispatching() => 'Dispatching',
  _ => 'Talk to Gemma',
};
