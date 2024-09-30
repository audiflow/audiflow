// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$defaultAudioPlayerServiceHash() =>
    r'b9b87b5915a39302e80c695516810ae80c427765';

/// This is the default implementation of [AudioPlayerService].
///
/// This implementation uses the [audio_service](https://pub.dev/packages/audio_service)
/// package to run the audio layer as a service to allow background play, and
/// playback is handled by the [just_audio](https://pub.dev/packages/just_audio)
/// package.
///
/// Copied from [DefaultAudioPlayerService].
@ProviderFor(DefaultAudioPlayerService)
final defaultAudioPlayerServiceProvider =
    NotifierProvider<DefaultAudioPlayerService, AudioPlayerState?>.internal(
  DefaultAudioPlayerService.new,
  name: r'defaultAudioPlayerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultAudioPlayerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DefaultAudioPlayerService = Notifier<AudioPlayerState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
