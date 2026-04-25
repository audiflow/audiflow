// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemma_voice_capture_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mic recorder for the Gemma 4 voice command path.
///
/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost. Disposed
/// when the provider container shuts down.

@ProviderFor(voiceAudioRecorder)
final voiceAudioRecorderProvider = VoiceAudioRecorderProvider._();

/// Mic recorder for the Gemma 4 voice command path.
///
/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost. Disposed
/// when the provider container shuts down.

final class VoiceAudioRecorderProvider
    extends
        $FunctionalProvider<
          VoiceAudioRecorder,
          VoiceAudioRecorder,
          VoiceAudioRecorder
        >
    with $Provider<VoiceAudioRecorder> {
  /// Mic recorder for the Gemma 4 voice command path.
  ///
  /// keepAlive because the underlying `record` plugin holds a native
  /// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
  /// turn would re-pay the platform-channel initialization cost. Disposed
  /// when the provider container shuts down.
  VoiceAudioRecorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceAudioRecorderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceAudioRecorderHash();

  @$internal
  @override
  $ProviderElement<VoiceAudioRecorder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VoiceAudioRecorder create(Ref ref) {
    return voiceAudioRecorder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceAudioRecorder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceAudioRecorder>(value),
    );
  }
}

String _$voiceAudioRecorderHash() =>
    r'f992640c160cb8843d8c55c1c54a20e462adeb8e';
