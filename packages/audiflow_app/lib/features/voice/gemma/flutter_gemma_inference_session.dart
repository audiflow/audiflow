import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart' as ai;
import 'package:flutter_gemma/flutter_gemma.dart';

/// [ai.GemmaInferenceSession] backed by `flutter_gemma`'s `InferenceModel` +
/// `InferenceChat`.
///
/// Loads the active model lazily on first call and reuses it across turns
/// so model-load cost only hits the first voice command. A fresh chat
/// session is created per call so prior audio doesn't leak into the next
/// turn's prompt context.
///
/// **Audio format.** Callers must supply 16 kHz, mono, 16-bit PCM WAV bytes
/// per `flutter_gemma`'s documented requirement. Mismatched formats will
/// cause a runtime error inside the native engine.
///
/// **Gemma 4 audio caveat.** As of `flutter_gemma 0.13.6` the changelog
/// only documents audio support for Gemma 3n explicitly; pub.dev lists
/// Gemma 4 variants as audio-capable. Verify on device before shipping
/// the wired voice command path.
class FlutterGemmaInferenceSession implements ai.GemmaInferenceSession {
  FlutterGemmaInferenceSession({this.maxTokens = 1024});

  /// Token budget for the chat session. Function-call output is small
  /// (well under 100 tokens), so 1024 leaves comfortable headroom for the
  /// audio token cost (25 tokens per second of audio, max 30 seconds).
  final int maxTokens;

  Future<InferenceModel>? _modelLoading;
  InferenceModel? _model;

  @override
  Future<ai.GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<ai.VoiceToolDefinition> tools,
  }) async {
    final model = await _ensureModel();
    final chat = await model.createChat(
      tools: tools.map(_toFlutterGemmaTool).toList(growable: false),
      supportsFunctionCalls: true,
      systemInstruction: systemPrompt,
      // Deterministic settings: voice commands are classification, not
      // generation. Lower temperature improves tool-call consistency.
      temperature: 0,
      topK: 1,
      randomSeed: 1,
    );
    try {
      await chat.addQueryChunk(
        Message.audioOnly(audioBytes: audio, isUser: true),
      );
      final response = await chat.generateChatResponse();
      return _parseResponse(response);
    } finally {
      await chat.session.close();
    }
  }

  Future<InferenceModel> _ensureModel() {
    final cached = _model;
    if (cached != null) {
      return Future.value(cached);
    }
    // Cache the in-flight Future so concurrent runWithAudio calls share a
    // single model load instead of each paying the multi-GB cost.
    return _modelLoading ??= _loadModel();
  }

  Future<InferenceModel> _loadModel() async {
    try {
      final model = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        supportAudio: true,
      );
      _model = model;
      return model;
    } finally {
      _modelLoading = null;
    }
  }

  Tool _toFlutterGemmaTool(ai.VoiceToolDefinition def) =>
      voiceToolToFlutterGemmaTool(def);

  ai.GemmaFunctionCall _parseResponse(ModelResponse response) =>
      parseFlutterGemmaResponse(response);

  /// Release the cached model. Call when the user disables the Gemma path
  /// to free RAM; the next call will re-load. Errors from the native close
  /// are swallowed because dispose runs during provider teardown where
  /// rethrowing turns into an unhandled async error.
  Future<void> dispose() async {
    final model = _model;
    _model = null;
    _modelLoading = null;
    if (model == null) {
      return;
    }
    try {
      await model.close();
    } on Exception {
      // Native close failure during teardown — nothing actionable here.
    }
  }
}

class _NoFunctionCallEmitted implements Exception {
  const _NoFunctionCallEmitted();

  @override
  String toString() =>
      'Gemma 4 returned a non-function-call response for a voice command turn';
}

/// Maps an audiflow_ai voice tool definition to flutter_gemma's [Tool] shape.
///
/// Top-level + visible for testing; the inference session calls this and
/// it doubles as a unit-testable boundary that doesn't require constructing
/// an [InferenceModel].
Tool voiceToolToFlutterGemmaTool(ai.VoiceToolDefinition def) => Tool(
  name: def.name,
  description: def.description,
  parameters: def.parameters,
);

/// Translates a [ModelResponse] from flutter_gemma into a
/// [ai.GemmaFunctionCall], applying the "first call wins" policy when the
/// model emits parallel calls.
///
/// Throws when the response carries no function call (text or thinking
/// only). The caller treats the throw as `VoiceCommandFailureReason.malformedPayload`
/// via the existing port contract.
ai.GemmaFunctionCall parseFlutterGemmaResponse(ModelResponse response) {
  if (response is FunctionCallResponse) {
    return ai.GemmaFunctionCall(
      name: response.name,
      args: Map<String, Object?>.from(response.args),
    );
  }
  if (response is ParallelFunctionCallResponse && response.calls.isNotEmpty) {
    final first = response.calls.first;
    return ai.GemmaFunctionCall(
      name: first.name,
      args: Map<String, Object?>.from(first.args),
    );
  }
  throw const _NoFunctionCallEmitted();
}
