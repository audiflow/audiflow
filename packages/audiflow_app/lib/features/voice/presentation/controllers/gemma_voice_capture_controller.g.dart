// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_voice_capture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GemmaVoiceCaptureController)
final gemmaVoiceCaptureControllerProvider =
    GemmaVoiceCaptureControllerProvider._();

final class GemmaVoiceCaptureControllerProvider
    extends $NotifierProvider<GemmaVoiceCaptureController, GemmaCaptureState> {
  GemmaVoiceCaptureControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaVoiceCaptureControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaVoiceCaptureControllerHash();

  @$internal
  @override
  GemmaVoiceCaptureController create() => GemmaVoiceCaptureController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemmaCaptureState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemmaCaptureState>(value),
    );
  }
}

String _$gemmaVoiceCaptureControllerHash() =>
    r'a4d33f5c16282167e16126a1f08534de125378a3';

abstract class _$GemmaVoiceCaptureController
    extends $Notifier<GemmaCaptureState> {
  GemmaCaptureState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GemmaCaptureState, GemmaCaptureState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GemmaCaptureState, GemmaCaptureState>,
              GemmaCaptureState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
