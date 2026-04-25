// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_voice_capability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the device's [GemmaVoiceCapability] from `device_info_plus`.
///
/// Cached for the lifetime of the process: total RAM is immutable at runtime,
/// and the platform-channel hop in `device_info_plus` would otherwise flash
/// a loading state on every settings rebuild.

@ProviderFor(gemmaVoiceCapability)
final gemmaVoiceCapabilityProvider = GemmaVoiceCapabilityProvider._();

/// Resolves the device's [GemmaVoiceCapability] from `device_info_plus`.
///
/// Cached for the lifetime of the process: total RAM is immutable at runtime,
/// and the platform-channel hop in `device_info_plus` would otherwise flash
/// a loading state on every settings rebuild.

final class GemmaVoiceCapabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<GemmaVoiceCapability>,
          GemmaVoiceCapability,
          FutureOr<GemmaVoiceCapability>
        >
    with
        $FutureModifier<GemmaVoiceCapability>,
        $FutureProvider<GemmaVoiceCapability> {
  /// Resolves the device's [GemmaVoiceCapability] from `device_info_plus`.
  ///
  /// Cached for the lifetime of the process: total RAM is immutable at runtime,
  /// and the platform-channel hop in `device_info_plus` would otherwise flash
  /// a loading state on every settings rebuild.
  GemmaVoiceCapabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaVoiceCapabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaVoiceCapabilityHash();

  @$internal
  @override
  $FutureProviderElement<GemmaVoiceCapability> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GemmaVoiceCapability> create(Ref ref) {
    return gemmaVoiceCapability(ref);
  }
}

String _$gemmaVoiceCapabilityHash() =>
    r'f5f8cda9f6f8f5ceb73c35ea83b4a5879d2ae079';
