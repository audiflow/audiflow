// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_voice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the download URL for [variant].
///
/// The host overrides this provider per flavor (Hugging Face URLs in prod,
/// a CDN mirror in staging, etc.). The default points at the public
/// `litert-community` Hugging Face repo for E2B / E4B; gated repos require
/// the host to also override [gemmaModelAuthTokenProvider].

@ProviderFor(gemmaModelUrlResolver)
final gemmaModelUrlResolverProvider = GemmaModelUrlResolverProvider._();

/// Resolves the download URL for [variant].
///
/// The host overrides this provider per flavor (Hugging Face URLs in prod,
/// a CDN mirror in staging, etc.). The default points at the public
/// `litert-community` Hugging Face repo for E2B / E4B; gated repos require
/// the host to also override [gemmaModelAuthTokenProvider].

final class GemmaModelUrlResolverProvider
    extends
        $FunctionalProvider<
          GemmaModelUrlResolver,
          GemmaModelUrlResolver,
          GemmaModelUrlResolver
        >
    with $Provider<GemmaModelUrlResolver> {
  /// Resolves the download URL for [variant].
  ///
  /// The host overrides this provider per flavor (Hugging Face URLs in prod,
  /// a CDN mirror in staging, etc.). The default points at the public
  /// `litert-community` Hugging Face repo for E2B / E4B; gated repos require
  /// the host to also override [gemmaModelAuthTokenProvider].
  GemmaModelUrlResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaModelUrlResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaModelUrlResolverHash();

  @$internal
  @override
  $ProviderElement<GemmaModelUrlResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaModelUrlResolver create(Ref ref) {
    return gemmaModelUrlResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaModelUrlResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaModelUrlResolver>(value),
    );
  }
}

String _$gemmaModelUrlResolverHash() =>
    r'53fd4dcbf8696a1d390465a0d4c6ed23e5c142fa';

/// Optional Hugging Face auth token. Returns null by default; override at
/// composition root when targeting gated repos.

@ProviderFor(gemmaModelAuthTokenResolver)
final gemmaModelAuthTokenResolverProvider =
    GemmaModelAuthTokenResolverProvider._();

/// Optional Hugging Face auth token. Returns null by default; override at
/// composition root when targeting gated repos.

final class GemmaModelAuthTokenResolverProvider
    extends
        $FunctionalProvider<
          GemmaModelAuthTokenResolver,
          GemmaModelAuthTokenResolver,
          GemmaModelAuthTokenResolver
        >
    with $Provider<GemmaModelAuthTokenResolver> {
  /// Optional Hugging Face auth token. Returns null by default; override at
  /// composition root when targeting gated repos.
  GemmaModelAuthTokenResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaModelAuthTokenResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaModelAuthTokenResolverHash();

  @$internal
  @override
  $ProviderElement<GemmaModelAuthTokenResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaModelAuthTokenResolver create(Ref ref) {
    return gemmaModelAuthTokenResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaModelAuthTokenResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaModelAuthTokenResolver>(value),
    );
  }
}

String _$gemmaModelAuthTokenResolverHash() =>
    r'1899d5e7245b3eff7be6f45af81536dc24fb27e9';

@ProviderFor(gemmaModelManager)
final gemmaModelManagerProvider = GemmaModelManagerProvider._();

final class GemmaModelManagerProvider
    extends
        $FunctionalProvider<
          GemmaModelManager,
          GemmaModelManager,
          GemmaModelManager
        >
    with $Provider<GemmaModelManager> {
  GemmaModelManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaModelManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaModelManagerHash();

  @$internal
  @override
  $ProviderElement<GemmaModelManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaModelManager create(Ref ref) {
    return gemmaModelManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaModelManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaModelManager>(value),
    );
  }
}

String _$gemmaModelManagerHash() => r'c1abbe7023a87d3d870921791aa8fc4a0f8117ac';

/// The inference session is keepAlive + cached because it owns a loaded
/// `InferenceModel`; recreating per-call would re-pay the model load cost
/// every voice command.

@ProviderFor(gemmaInferenceSession)
final gemmaInferenceSessionProvider = GemmaInferenceSessionProvider._();

/// The inference session is keepAlive + cached because it owns a loaded
/// `InferenceModel`; recreating per-call would re-pay the model load cost
/// every voice command.

final class GemmaInferenceSessionProvider
    extends
        $FunctionalProvider<
          GemmaInferenceSession,
          GemmaInferenceSession,
          GemmaInferenceSession
        >
    with $Provider<GemmaInferenceSession> {
  /// The inference session is keepAlive + cached because it owns a loaded
  /// `InferenceModel`; recreating per-call would re-pay the model load cost
  /// every voice command.
  GemmaInferenceSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaInferenceSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaInferenceSessionHash();

  @$internal
  @override
  $ProviderElement<GemmaInferenceSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaInferenceSession create(Ref ref) {
    return gemmaInferenceSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaInferenceSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaInferenceSession>(value),
    );
  }
}

String _$gemmaInferenceSessionHash() =>
    r'cd5422b569c2c76e3ba4f5fbb95aae2e6168bf03';

@ProviderFor(gemmaVoiceCommandService)
final gemmaVoiceCommandServiceProvider = GemmaVoiceCommandServiceProvider._();

final class GemmaVoiceCommandServiceProvider
    extends
        $FunctionalProvider<
          GemmaVoiceCommandService,
          GemmaVoiceCommandService,
          GemmaVoiceCommandService
        >
    with $Provider<GemmaVoiceCommandService> {
  GemmaVoiceCommandServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaVoiceCommandServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaVoiceCommandServiceHash();

  @$internal
  @override
  $ProviderElement<GemmaVoiceCommandService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaVoiceCommandService create(Ref ref) {
    return gemmaVoiceCommandService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaVoiceCommandService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaVoiceCommandService>(value),
    );
  }
}

String _$gemmaVoiceCommandServiceHash() =>
    r'4be00d6a3b6f2bfc00b4f921e20494fb2e4fde8f';

@ProviderFor(gemmaVoiceCommandRoute)
final gemmaVoiceCommandRouteProvider = GemmaVoiceCommandRouteProvider._();

final class GemmaVoiceCommandRouteProvider
    extends
        $FunctionalProvider<
          GemmaVoiceCommandRoute,
          GemmaVoiceCommandRoute,
          GemmaVoiceCommandRoute
        >
    with $Provider<GemmaVoiceCommandRoute> {
  GemmaVoiceCommandRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaVoiceCommandRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaVoiceCommandRouteHash();

  @$internal
  @override
  $ProviderElement<GemmaVoiceCommandRoute> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GemmaVoiceCommandRoute create(Ref ref) {
    return gemmaVoiceCommandRoute(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaVoiceCommandRoute value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaVoiceCommandRoute>(value),
    );
  }
}

String _$gemmaVoiceCommandRouteHash() =>
    r'c5864b19c5e3eea967f6c080e900c9a8a132ef12';
