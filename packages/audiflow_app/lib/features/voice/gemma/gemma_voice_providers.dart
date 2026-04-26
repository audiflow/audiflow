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
    logger: ref.watch(namedLoggerProvider('GemmaModelManager')),
  );
}

/// Builds the flutter_gemma-backed [GemmaInferenceSession] used to override
/// the domain-side stub at the composition root.
///
/// The session owns a loaded `InferenceModel`; recreating it per voice turn
/// would re-pay the model load cost. Lifecycle (dispose) is wired into the
/// passed [Ref] so it's torn down when the provider container shuts down.
///
/// The `ensureModelReady` closure resolves the user's currently-selected
/// variant on every first-load and re-runs install (cheap on cache hit) so
/// the process-scoped active-model pointer is restored after every app
/// launch.
GemmaInferenceSession buildFlutterGemmaInferenceSession(Ref ref) {
  final session = FlutterGemmaInferenceSession(
    logger: ref.watch(namedLoggerProvider('GemmaInference')),
    ensureModelReady: () async {
      final repo = ref.read(appSettingsRepositoryProvider);
      final variantName = repo.getVoiceGemmaVariant();
      final variant = GemmaModelVariant.values.firstWhere(
        (v) => v.name == variantName,
        orElse: () => GemmaModelVariant.e2b,
      );
      await ref.read(gemmaModelManagerProvider).ensureInstalled(variant);
    },
  );
  ref.onDispose(() => unawaited(session.dispose()));
  return session;
}
