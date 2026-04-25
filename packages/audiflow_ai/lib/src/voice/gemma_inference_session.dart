import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'voice_tool_schema.dart';

/// One function call emitted by Gemma 4 in response to an audio query.
@immutable
final class GemmaFunctionCall {
  GemmaFunctionCall({required this.name, required Map<String, Object?> args})
    : args = UnmodifiableMapView(args);

  /// Const constructor for compile-time literals (test fixtures); the
  /// supplied [args] map must already be `const`/immutable.
  const GemmaFunctionCall.constUnsafe({required this.name, required this.args});

  /// The tool name Gemma 4 chose. Maps to [VoiceToolDefinition.name].
  final String name;

  /// Arguments parsed from the function call payload. Unmodifiable.
  final Map<String, Object?> args;

  @override
  String toString() => 'GemmaFunctionCall($name, $args)';
}

/// Port over a Gemma 4 inference session that takes raw audio and returns
/// a single function call.
///
/// Defined as an interface so the audiflow_ai layer stays unit-testable
/// without `flutter_gemma` resolved in the test runner. The concrete
/// flutter_gemma adapter is wired at composition root in audiflow_app.
// ignore: one_member_abstracts
abstract interface class GemmaInferenceSession {
  /// Run inference for one voice command turn.
  ///
  /// [audio] is raw mic capture in whatever encoding the underlying plugin
  /// expects (the adapter normalizes). [systemPrompt] is the constraint
  /// prompt; [tools] is the per-turn tool list including a settings
  /// snapshot. Returns the single function call Gemma 4 emits.
  ///
  /// Throws when inference fails or returns no function call.
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  });
}
