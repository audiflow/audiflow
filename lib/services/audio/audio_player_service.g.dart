// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioPlayerServiceHash() =>
    r'263c8f102a69f8131844c1dc5066af4dccaa1c84';

/// This class defines the audio playback options supported by Anytime.
///
/// The implementing classes will then handle the specifics for the platform we
/// are running on.
///
/// Copied from [AudioPlayerService].
@ProviderFor(AudioPlayerService)
final audioPlayerServiceProvider =
    NotifierProvider<AudioPlayerService, AudioPlayerState?>.internal(
  AudioPlayerService.new,
  name: r'audioPlayerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlayerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AudioPlayerService = Notifier<AudioPlayerState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
