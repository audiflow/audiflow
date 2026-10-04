// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_route_channel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioRouteChannel)
final audioRouteChannelProvider = AudioRouteChannelProvider._();

final class AudioRouteChannelProvider
    extends
        $FunctionalProvider<
          AudioRouteChannel,
          AudioRouteChannel,
          AudioRouteChannel
        >
    with $Provider<AudioRouteChannel> {
  AudioRouteChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioRouteChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioRouteChannelHash();

  @$internal
  @override
  $ProviderElement<AudioRouteChannel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioRouteChannel create(Ref ref) {
    return audioRouteChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioRouteChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioRouteChannel>(value),
    );
  }
}

String _$audioRouteChannelHash() => r'af1c3c8bc7358c04f6a75263fce1a90bb9008645';

/// Whether the player shows the audio output picker button.
///
/// Android 8-10 has no system output switcher, so the button stays hidden
/// there instead of sending the user to a Bluetooth-only settings screen.

@ProviderFor(audioOutputPickerAvailable)
final audioOutputPickerAvailableProvider =
    AudioOutputPickerAvailableProvider._();

/// Whether the player shows the audio output picker button.
///
/// Android 8-10 has no system output switcher, so the button stays hidden
/// there instead of sending the user to a Bluetooth-only settings screen.

final class AudioOutputPickerAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the player shows the audio output picker button.
  ///
  /// Android 8-10 has no system output switcher, so the button stays hidden
  /// there instead of sending the user to a Bluetooth-only settings screen.
  AudioOutputPickerAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioOutputPickerAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioOutputPickerAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return audioOutputPickerAvailable(ref);
  }
}

String _$audioOutputPickerAvailableHash() =>
    r'9af0b84e2e7b05047a7dd3780296626421ad90fe';
