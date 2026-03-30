import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_debug_info.freezed.dart';

/// Which parser resolved the voice transcription.
enum VoiceParserSource {
  /// No parser has matched yet.
  none,

  /// Deterministic keyword/regex matching.
  simplePattern,

  /// Platform-native NLU (Apple/Google).
  platformNlu,

  /// On-device AI model.
  onDeviceAi,
}

/// Debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] alongside the main
/// [VoiceRecognitionState]. Consumed only by the debug overlay
/// on non-production builds.
@freezed
sealed class VoiceDebugInfo with _$VoiceDebugInfo {
  const factory VoiceDebugInfo({
    @Default(VoiceParserSource.none) VoiceParserSource parserSource,
    VoiceCommand? lastCommand,
  }) = _VoiceDebugInfo;
}
