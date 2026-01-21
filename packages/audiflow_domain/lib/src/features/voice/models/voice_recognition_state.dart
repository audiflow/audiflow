import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_recognition_state.freezed.dart';

/// State machine for voice command recognition flow.
///
/// Represents the lifecycle of a voice command interaction:
/// idle -> listening -> processing -> executing -> success/error -> idle
@freezed
sealed class VoiceRecognitionState with _$VoiceRecognitionState {
  /// No voice recognition activity.
  const factory VoiceRecognitionState.idle() = VoiceIdle;

  /// Actively listening for voice input.
  const factory VoiceRecognitionState.listening({
    /// Partial transcription as user speaks.
    String? partialTranscript,
  }) = VoiceListening;

  /// Processing the completed transcription through NLU.
  const factory VoiceRecognitionState.processing({
    /// The finalized transcription text.
    required String transcription,
  }) = VoiceProcessing;

  /// Executing the parsed voice command.
  const factory VoiceRecognitionState.executing({
    /// The parsed command being executed.
    required VoiceCommand command,
  }) = VoiceExecuting;

  /// Command executed successfully.
  const factory VoiceRecognitionState.success({
    /// Human-readable success message.
    required String message,
  }) = VoiceSuccess;

  /// An error occurred during the voice command flow.
  const factory VoiceRecognitionState.error({
    /// Human-readable error message.
    required String message,
  }) = VoiceError;
}
