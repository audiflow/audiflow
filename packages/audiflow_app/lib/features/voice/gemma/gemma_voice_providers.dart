import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'flutter_gemma_inference_session.dart';
import 'flutter_gemma_plugin_adapter.dart';

part 'gemma_voice_providers.g.dart';

/// Resolves the download URL for [variant].
///
/// The host overrides this provider per flavor (Hugging Face URLs in prod,
/// a CDN mirror in staging, etc.). The default points at the public
/// `litert-community` Hugging Face repo for E2B / E4B; gated repos require
/// the host to also override [gemmaModelAuthTokenProvider].
@Riverpod(keepAlive: true)
GemmaModelUrlResolver gemmaModelUrlResolver(Ref ref) {
  return (variant) {
    const base =
        'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/'
        'resolve/main';
    return switch (variant) {
      GemmaModelVariant.e2b => '$base/${variant.fileName}',
      GemmaModelVariant.e4b =>
        'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/'
            'resolve/main/${variant.fileName}',
    };
  };
}

/// Optional Hugging Face auth token. Returns null by default; override at
/// composition root when targeting gated repos.
@Riverpod(keepAlive: true)
GemmaModelAuthTokenResolver gemmaModelAuthTokenResolver(Ref ref) {
  return (_) async => null;
}

@Riverpod(keepAlive: true)
GemmaModelManager gemmaModelManager(Ref ref) {
  return GemmaModelManager(
    plugin: const FlutterGemmaPluginAdapter(),
    urlResolver: ref.watch(gemmaModelUrlResolverProvider),
    authTokenResolver: ref.watch(gemmaModelAuthTokenResolverProvider),
  );
}

/// The inference session is keepAlive + cached because it owns a loaded
/// `InferenceModel`; recreating per-call would re-pay the model load cost
/// every voice command.
@Riverpod(keepAlive: true)
GemmaInferenceSession gemmaInferenceSession(Ref ref) {
  final session = FlutterGemmaInferenceSession();
  // `onDispose` takes `void Function()`; `session.dispose` returns a Future
  // whose errors are already swallowed but whose completion would otherwise
  // be silently dropped. `unawaited` makes the fire-and-forget explicit.
  ref.onDispose(() => unawaited(session.dispose()));
  return session;
}

@Riverpod(keepAlive: true)
GemmaVoiceCommandService gemmaVoiceCommandService(Ref ref) {
  return GemmaVoiceCommandService(
    session: ref.watch(gemmaInferenceSessionProvider),
  );
}

@Riverpod(keepAlive: true)
GemmaVoiceCommandRoute gemmaVoiceCommandRoute(Ref ref) {
  return GemmaVoiceCommandRoute(
    service: ref.watch(gemmaVoiceCommandServiceProvider),
    registry: SettingsMetadataRegistry(),
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
    logger: ref.watch(namedLoggerProvider('GemmaVoiceRoute')),
  );
}
