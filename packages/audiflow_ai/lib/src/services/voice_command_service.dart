// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import '../models/generation_config.dart';
import '../models/voice_command.dart';
import '../utils/prompt_templates.dart';
import 'text_generation_service.dart';

/// Service that parses voice command transcriptions into structured commands.
///
/// Uses AI to understand natural language voice commands and extract
/// intent and parameters for podcast player control.
class VoiceCommandService {
  /// Creates a [VoiceCommandService] with the given text generation service.
  VoiceCommandService({
    required TextGenerationService textGenerationService,
  }) : _textGenService = textGenerationService;

  final TextGenerationService _textGenService;

  /// Parses a voice command transcription into a structured [VoiceCommand].
  ///
  /// [transcription] is the raw text from speech-to-text.
  ///
  /// Returns a [VoiceCommand] with:
  /// - [VoiceIntent] indicating the command type
  /// - Parameters extracted from the command
  /// - Confidence score (0.0 to 1.0)
  /// - Original transcription preserved
  ///
  /// On error, returns a [VoiceCommand] with [VoiceIntent.unknown] and
  /// confidence of 0.0.
  Future<VoiceCommand> parseCommand(String transcription) async {
    if (transcription.isEmpty) {
      return VoiceCommand(
        intent: VoiceIntent.unknown,
        parameters: const {},
        confidence: 0,
        rawTranscription: transcription,
      );
    }

    try {
      // Build prompt using template
      final prompt = PromptTemplates.substituteVariables(
        PromptTemplates.voiceCommand,
        {'transcription': transcription},
      );

      final response = await _textGenService.generateText(
        prompt: prompt,
        config: const GenerationConfig(
          temperature: 0.3, // Lower temperature for more consistent parsing
          maxOutputTokens: 100,
        ),
      );

      return _parseResponse(response.text, transcription);
    } on Exception {
      // On any error, return unknown with zero confidence
      return VoiceCommand(
        intent: VoiceIntent.unknown,
        parameters: const {},
        confidence: 0,
        rawTranscription: transcription,
      );
    }
  }

  VoiceCommand _parseResponse(String response, String originalTranscription) {
    // Parse the AI response
    // Expected format:
    // intent: <intent_name>
    // parameters: {key: value, ...}
    // confidence: <0.0-1.0>

    final lines = response.split('\n');
    var intent = VoiceIntent.unknown;
    var parameters = <String, String>{};
    var confidence = 0.5; // Default confidence for parsed responses

    for (final line in lines) {
      final trimmedLine = line.trim().toLowerCase();

      if (trimmedLine.startsWith('intent:')) {
        final intentStr = trimmedLine.substring(7).trim();
        intent = _parseIntent(intentStr);
      } else if (trimmedLine.startsWith('parameters:')) {
        parameters = _parseParameters(line.substring(11).trim());
      } else if (trimmedLine.startsWith('confidence:')) {
        final confStr = trimmedLine.substring(11).trim();
        confidence = _parseConfidence(confStr);
      }
    }

    return VoiceCommand(
      intent: intent,
      parameters: parameters,
      confidence: confidence,
      rawTranscription: originalTranscription,
    );
  }

  VoiceIntent _parseIntent(String intentStr) {
    // Normalize the intent string
    final normalized = intentStr.toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );

    return switch (normalized) {
      'play' => VoiceIntent.play,
      'pause' => VoiceIntent.pause,
      'stop' => VoiceIntent.stop,
      'skipforward' || 'forward' || 'skip' => VoiceIntent.skipForward,
      'skipbackward' ||
      'backward' ||
      'back' ||
      'rewind' => VoiceIntent.skipBackward,
      'seek' || 'goto' || 'jumpto' => VoiceIntent.seek,
      'search' || 'find' || 'lookup' => VoiceIntent.search,
      'gotolibrary' || 'library' || 'mylibrary' => VoiceIntent.goToLibrary,
      'gotoqueue' ||
      'queue' ||
      'myqueue' ||
      'showqueue' => VoiceIntent.goToQueue,
      'opensettings' || 'settings' => VoiceIntent.openSettings,
      'addtoqueue' || 'add' || 'enqueue' => VoiceIntent.addToQueue,
      'removefromqueue' || 'remove' || 'dequeue' => VoiceIntent.removeFromQueue,
      'clearqueue' || 'clear' || 'emptyqueue' => VoiceIntent.clearQueue,
      _ => VoiceIntent.unknown,
    };
  }

  Map<String, String> _parseParameters(String parametersStr) {
    final parameters = <String, String>{};

    // Remove braces if present
    var cleaned = parametersStr.trim();
    if (cleaned.startsWith('{')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.endsWith('}')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    // Parse key-value pairs
    final pairs = cleaned.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (2 <= parts.length) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          parameters[key] = value;
        }
      }
    }

    return parameters;
  }

  double _parseConfidence(String confStr) {
    // Try to parse the confidence value
    final match = RegExp(r'[\d.]+').firstMatch(confStr);
    if (match != null) {
      final value = double.tryParse(match.group(0)!) ?? 0.5;
      // Clamp to valid range
      return value.clamp(0.0, 1.0);
    }
    return 0.5;
  }
}
