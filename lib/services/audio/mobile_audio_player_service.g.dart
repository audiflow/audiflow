// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mobileAudioPlayerServiceHash() =>
    r'b8b7456358e84e4010907837504580ead588b40f';

/// This is the default implementation of [AudioPlayerService].
///
/// This implementation uses the [audio_service](https://pub.dev/packages/audio_service)
/// package to run the audio layer as a service to allow background play, and
/// playback is handled by the [just_audio](https://pub.dev/packages/just_audio)
/// package.
///
/// Copied from [MobileAudioPlayerService].
@ProviderFor(MobileAudioPlayerService)
final mobileAudioPlayerServiceProvider =
    NotifierProvider<MobileAudioPlayerService, AudioPlayerState?>.internal(
  MobileAudioPlayerService.new,
  name: r'mobileAudioPlayerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mobileAudioPlayerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MobileAudioPlayerService = Notifier<AudioPlayerState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
