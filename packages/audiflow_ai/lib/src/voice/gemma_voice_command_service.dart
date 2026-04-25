import 'dart:typed_data';

import '../models/settings_change_payload.dart';
import '../models/voice_command.dart';
import 'gemma_inference_session.dart';
import 'voice_tool_schema.dart';

/// Voice command parser backed by on-device Gemma 4 audio-in inference.
///
/// Replaces the legacy STT + Gemini text-generation pipeline. Takes raw
/// audio bytes, asks Gemma 4 to emit one function call from the per-turn
/// tool list, and translates the result into a [VoiceCommand].
class GemmaVoiceCommandService {
  GemmaVoiceCommandService({required GemmaInferenceSession session})
    : _session = session;

  final GemmaInferenceSession _session;

  /// Parse [audio] into a [VoiceCommand] using [settingsSnapshot] (from
  /// `SettingsMetadataRegistry.toJson()`) as the per-turn settings context.
  ///
  /// Returns [VoiceCommand] with intent [VoiceIntent.unknown] in four
  /// distinguishable cases (see [VoiceCommand.failureReason]):
  /// - [VoiceCommandFailureReason.inferenceError] — session threw an Exception.
  /// - [VoiceCommandFailureReason.unrecognizedTool] — unknown tool name.
  /// - [VoiceCommandFailureReason.malformedPayload] — missing/invalid args.
  /// - [VoiceCommandFailureReason.noCommandRecognized] — `changeSettings`
  ///   with empty ambiguous candidates, the documented "didn't understand"
  ///   signal from the system prompt.
  Future<VoiceCommand> dispatch({
    required Uint8List audio,
    required List<SettingsSnapshotEntry> settingsSnapshot,
  }) async {
    final tools = buildVoiceTools(settingsSnapshot: settingsSnapshot);

    final GemmaFunctionCall call;
    try {
      call = await _session.runWithAudio(
        audio: audio,
        systemPrompt: voiceSystemPrompt,
        tools: tools,
      );
    } on Exception {
      return _unknown(VoiceCommandFailureReason.inferenceError);
    }

    final intent = _intentFromName(call.name);
    if (intent == null) {
      return _unknown(VoiceCommandFailureReason.unrecognizedTool);
    }
    if (intent == VoiceIntent.changeSettings) {
      return _parseChangeSettings(call.args);
    }
    return VoiceCommand(
      intent: intent,
      parameters: _stringifyArgs(call.args),
      confidence: _fixedToolConfidence,
      rawTranscription: '',
    );
  }

  VoiceCommand _parseChangeSettings(Map<String, Object?> args) {
    final variant = args['variant'];
    if (variant is! String) {
      return _unknown(VoiceCommandFailureReason.malformedPayload);
    }
    final payload = switch (variant) {
      'absolute' => _parseAbsolute(args),
      'relative' => _parseRelative(args),
      'ambiguous' => _parseAmbiguous(args),
      _ => null,
    };
    if (payload == null) {
      return _unknown(VoiceCommandFailureReason.malformedPayload);
    }
    if (payload is SettingsChangePayloadAmbiguous &&
        payload.candidates.isEmpty) {
      return _unknown(VoiceCommandFailureReason.noCommandRecognized);
    }
    final confidence = switch (payload) {
      SettingsChangePayloadAbsolute(:final confidence) => confidence,
      SettingsChangePayloadRelative(:final confidence) => confidence,
      SettingsChangePayloadAmbiguous(:final candidates) =>
        candidates.first.confidence,
    };
    return VoiceCommand(
      intent: VoiceIntent.changeSettings,
      parameters: const {},
      confidence: confidence,
      rawTranscription: '',
      settingsPayload: payload,
    );
  }

  SettingsChangePayload? _parseAbsolute(Map<String, Object?> args) {
    final key = args['key'];
    final value = args['value'];
    final confidence = _readDouble(args['confidence']);
    if (key is! String || value is! String || confidence == null) {
      return null;
    }
    return SettingsChangePayload.absolute(
      key: key,
      value: value,
      confidence: confidence,
    );
  }

  SettingsChangePayload? _parseRelative(Map<String, Object?> args) {
    final key = args['key'];
    final direction = _parseDirection(args['direction']);
    final magnitude = _parseMagnitude(args['magnitude']);
    final confidence = _readDouble(args['confidence']);
    if (key is! String ||
        direction == null ||
        magnitude == null ||
        confidence == null) {
      return null;
    }
    return SettingsChangePayload.relative(
      key: key,
      direction: direction,
      magnitude: magnitude,
      confidence: confidence,
    );
  }

  // Empty candidates list is valid: the system prompt instructs the model
  // to use it as the "no command recognized" signal. The caller turns that
  // into VoiceIntent.unknown.
  SettingsChangePayload? _parseAmbiguous(Map<String, Object?> args) {
    final raw = args['candidates'];
    if (raw is! List) {
      return null;
    }
    final candidates = <SettingsCandidate>[];
    for (final entry in raw) {
      if (entry is! Map) {
        continue;
      }
      final key = entry['key'];
      final value = entry['value'];
      final confidence = _readDouble(entry['confidence']);
      if (key is! String || value is! String || confidence == null) {
        continue;
      }
      candidates.add(
        SettingsCandidate(key: key, value: value, confidence: confidence),
      );
    }
    return SettingsChangePayload.ambiguous(candidates: candidates);
  }

  ChangeDirection? _parseDirection(Object? raw) => switch (raw) {
    'increase' => ChangeDirection.increase,
    'decrease' => ChangeDirection.decrease,
    _ => null,
  };

  ChangeMagnitude? _parseMagnitude(Object? raw) => switch (raw) {
    'small' => ChangeMagnitude.small,
    'medium' => ChangeMagnitude.medium,
    'large' => ChangeMagnitude.large,
    _ => null,
  };

  double? _readDouble(Object? raw) => switch (raw) {
    final num n => n.toDouble(),
    _ => null,
  };

  Map<String, String> _stringifyArgs(Map<String, Object?> args) {
    final result = <String, String>{};
    args.forEach((key, value) {
      if (value == null) {
        return;
      }
      // Whole-valued doubles (e.g. 120.0 from a model that returned a JSON
      // number) collapse to int form; downstream executors parse `seek`'s
      // `seconds` as int and would choke on "120.0".
      result[key] = switch (value) {
        final num n when n == n.truncateToDouble() => n.toInt().toString(),
        _ => value.toString(),
      };
    });
    return result;
  }

  VoiceIntent? _intentFromName(String name) {
    for (final intent in VoiceIntent.values) {
      if (intent.name == name) {
        return intent;
      }
    }
    return null;
  }

  VoiceCommand _unknown(VoiceCommandFailureReason reason) => VoiceCommand(
    intent: VoiceIntent.unknown,
    parameters: const {},
    confidence: 0,
    rawTranscription: '',
    failureReason: reason,
  );

  // Confidence we assign to deterministic tool calls (play / pause / etc.).
  // Settings calls carry the model's own self-reported confidence.
  static const double _fixedToolConfidence = 0.95;
}
