// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'settings_change_payload.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceCommand &&
          runtimeType == other.runtimeType &&
          intent == other.intent &&
          confidence == other.confidence &&
          rawTranscription == other.rawTranscription &&
          settingsPayload == other.settingsPayload;

  @override
  int get hashCode =>
      Object.hash(intent, confidence, rawTranscription, settingsPayload);

  @override
  String toString() =>
      'VoiceCommand(intent: $intent, confidence: $confidence, '
      'params: $parameters)';
}
