// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_debug_info_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier that holds debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] at each parser match point.
/// Read only by the debug overlay widget on non-production builds.

@ProviderFor(VoiceDebugInfoNotifier)
final voiceDebugInfoProvider = VoiceDebugInfoNotifierProvider._();

/// Notifier that holds debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] at each parser match point.
/// Read only by the debug overlay widget on non-production builds.
final class VoiceDebugInfoNotifierProvider
    extends $NotifierProvider<VoiceDebugInfoNotifier, VoiceDebugInfo> {
  /// Notifier that holds debug metadata for the voice command pipeline.
  ///
  /// Populated by [VoiceCommandOrchestrator] at each parser match point.
  /// Read only by the debug overlay widget on non-production builds.
  VoiceDebugInfoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceDebugInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceDebugInfoNotifierHash();

  @$internal
  @override
  VoiceDebugInfoNotifier create() => VoiceDebugInfoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceDebugInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceDebugInfo>(value),
    );
  }
}

String _$voiceDebugInfoNotifierHash() =>
    r'7a981f5bb937dec7a7958a8508fa3b6a4071be32';

/// Notifier that holds debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] at each parser match point.
/// Read only by the debug overlay widget on non-production builds.

abstract class _$VoiceDebugInfoNotifier extends $Notifier<VoiceDebugInfo> {
  VoiceDebugInfo build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VoiceDebugInfo, VoiceDebugInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoiceDebugInfo, VoiceDebugInfo>,
              VoiceDebugInfo,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
