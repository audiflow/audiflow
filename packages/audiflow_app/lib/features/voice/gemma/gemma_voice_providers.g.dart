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
