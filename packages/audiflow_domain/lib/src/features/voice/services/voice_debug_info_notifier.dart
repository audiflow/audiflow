import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/voice_debug_info.dart';

part 'voice_debug_info_notifier.g.dart';

/// Notifier that holds debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] at each parser match point.
/// Read only by the debug overlay widget on non-production builds.
@Riverpod(keepAlive: true)
class VoiceDebugInfoNotifier extends _$VoiceDebugInfoNotifier {
  @override
  VoiceDebugInfo build() => const VoiceDebugInfo();

  /// Records which parser resolved the current transcription.
  void setParserSource(VoiceParserSource source) {
    state = state.copyWith(parserSource: source);
  }

  /// Stores the last parsed command so debug info survives across
  /// state transitions (e.g., executing -> success).
  void setLastCommand(VoiceCommand command) {
    state = state.copyWith(lastCommand: command);
  }

  /// Resets to default state. Called when voice flow returns to idle.
  void reset() {
    state = const VoiceDebugInfo();
  }
}
