// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'settings_change_payload.dart';

/// Reason a voice command parser produced an [VoiceIntent.unknown] result.
///
/// Null when [VoiceCommand.intent] is anything other than
/// [VoiceIntent.unknown]. Lets the caller distinguish "user said something
/// we couldn't parse" (the documented contract) from genuine failures
/// like an inference crash or schema drift.
enum VoiceCommandFailureReason {
  /// The underlying inference engine threw an Exception.
  inferenceError,

  /// The model emitted a tool name not in the per-turn schema.
  unrecognizedTool,

  /// The model emitted a recognized tool but the arguments were missing
  /// fields, had wrong types, or referenced unknown enum values.
  malformedPayload,

  /// The model honored the system prompt's "no command recognized" signal
  /// (changeSettings ambiguous with empty candidates).
  noCommandRecognized,
}

/// Intent types for voice commands.
enum VoiceIntent {
  // Playback intents
  play,
  pause,
  stop,
  skipForward,
  skipBackward,
  seek,

  // Search intents
  search,

  // Navigation intents
  goToLibrary,
  goToQueue,
  openSettings,

  // Queue management intents
  addToQueue,
  removeFromQueue,
  clearQueue,

  // Settings intents
  changeSettings,

  // Unknown intent
  unknown,
}

/// Parsed voice command with intent and parameters.
class VoiceCommand {
  /// Creates a [VoiceCommand].
  const VoiceCommand({
    required this.intent,
    required this.parameters,
    required this.confidence,
    required this.rawTranscription,
    this.settingsPayload,
    this.failureReason,
  });

  /// The parsed intent.
  final VoiceIntent intent;

  /// Parameters extracted from the command.
  final Map<String, String> parameters;

  /// Confidence score (0.0 to 1.0).
  final double confidence;

  /// The original transcription text.
  final String rawTranscription;

  /// Structured settings change payload, populated when [intent] is
  /// [VoiceIntent.changeSettings].
  final SettingsChangePayload? settingsPayload;

  /// Why this command was classified as [VoiceIntent.unknown]. Null when
  /// [intent] is anything else, or when the producer did not enrich the
  /// failure with a reason.
  final VoiceCommandFailureReason? failureReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceCommand &&
          runtimeType == other.runtimeType &&
          intent == other.intent &&
          confidence == other.confidence &&
          rawTranscription == other.rawTranscription &&
          settingsPayload == other.settingsPayload &&
          failureReason == other.failureReason;

  @override
  int get hashCode => Object.hash(
    intent,
    confidence,
    rawTranscription,
    settingsPayload,
    failureReason,
  );

  @override
  String toString() =>
      'VoiceCommand(intent: $intent, confidence: $confidence, '
      'params: $parameters'
      '${failureReason == null ? '' : ', reason: $failureReason'})';
}
