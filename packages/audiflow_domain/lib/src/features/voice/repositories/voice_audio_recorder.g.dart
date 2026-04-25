// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_audio_recorder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost.

@ProviderFor(voiceAudioRecorder)
final voiceAudioRecorderProvider = VoiceAudioRecorderProvider._();

/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost.

final class VoiceAudioRecorderProvider
    extends
        $FunctionalProvider<
          VoiceAudioRecorder,
          VoiceAudioRecorder,
          VoiceAudioRecorder
        >
    with $Provider<VoiceAudioRecorder> {
  /// keepAlive because the underlying `record` plugin holds a native
  /// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
  /// turn would re-pay the platform-channel initialization cost.
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
    r'9d25e2ac141f6b67663624a060f6c9954df09ffb';
