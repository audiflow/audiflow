// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_voice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition seam for the on-device Gemma 4 inference session.
///
/// The default implementation throws because the session is backed by the
/// `flutter_gemma` plugin, which lives in `audiflow_app` to keep the
/// platform-channel dependency out of the domain layer. The host app
/// overrides this provider at the root [ProviderScope] /
/// [ProviderContainer] with a real session.

@ProviderFor(gemmaInferenceSession)
final gemmaInferenceSessionProvider = GemmaInferenceSessionProvider._();

/// Composition seam for the on-device Gemma 4 inference session.
///
/// The default implementation throws because the session is backed by the
/// `flutter_gemma` plugin, which lives in `audiflow_app` to keep the
/// platform-channel dependency out of the domain layer. The host app
/// overrides this provider at the root [ProviderScope] /
/// [ProviderContainer] with a real session.

final class GemmaInferenceSessionProvider
    extends
        $FunctionalProvider<
          GemmaInferenceSession,
          GemmaInferenceSession,
          GemmaInferenceSession
        >
    with $Provider<GemmaInferenceSession> {
  /// Composition seam for the on-device Gemma 4 inference session.
  ///
  /// The default implementation throws because the session is backed by the
  /// `flutter_gemma` plugin, which lives in `audiflow_app` to keep the
  /// platform-channel dependency out of the domain layer. The host app
  /// overrides this provider at the root [ProviderScope] /
  /// [ProviderContainer] with a real session.
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
    r'043d54d84baa845486d28d80c2b3bdec32948676';

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
