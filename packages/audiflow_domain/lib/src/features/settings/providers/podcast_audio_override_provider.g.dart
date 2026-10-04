// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_audio_override_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds a podcast's audio settings override; null when it has none.
///
/// UI must not call [saveSpeed] directly: speed changes go through
/// `AudioPlayerController.setSpeed` with a podcast scope, which also
/// applies the speed to the player and records analytics.
///
/// Every mutation updates memory before disk so controls follow input
/// immediately, and restores the previous state when the write fails so
/// memory never disagrees with what `play()` would read after a restart.
/// Mutations are ignored until the stored override has loaded: acting on
/// a loading state could be overwritten by the pending load.

@ProviderFor(PodcastAudioOverrideController)
final podcastAudioOverrideControllerProvider =
    PodcastAudioOverrideControllerFamily._();

/// Holds a podcast's audio settings override; null when it has none.
///
/// UI must not call [saveSpeed] directly: speed changes go through
/// `AudioPlayerController.setSpeed` with a podcast scope, which also
/// applies the speed to the player and records analytics.
///
/// Every mutation updates memory before disk so controls follow input
/// immediately, and restores the previous state when the write fails so
/// memory never disagrees with what `play()` would read after a restart.
/// Mutations are ignored until the stored override has loaded: acting on
/// a loading state could be overwritten by the pending load.
final class PodcastAudioOverrideControllerProvider
    extends
        $AsyncNotifierProvider<PodcastAudioOverrideController, AudioSettings?> {
  /// Holds a podcast's audio settings override; null when it has none.
  ///
  /// UI must not call [saveSpeed] directly: speed changes go through
  /// `AudioPlayerController.setSpeed` with a podcast scope, which also
  /// applies the speed to the player and records analytics.
  ///
  /// Every mutation updates memory before disk so controls follow input
  /// immediately, and restores the previous state when the write fails so
  /// memory never disagrees with what `play()` would read after a restart.
  /// Mutations are ignored until the stored override has loaded: acting on
  /// a loading state could be overwritten by the pending load.
  PodcastAudioOverrideControllerProvider._({
    required PodcastAudioOverrideControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastAudioOverrideControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastAudioOverrideControllerHash();

  @override
  String toString() {
    return r'podcastAudioOverrideControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastAudioOverrideController create() => PodcastAudioOverrideController();

  @override
  bool operator ==(Object other) {
    return other is PodcastAudioOverrideControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastAudioOverrideControllerHash() =>
    r'2432194732420b9dc80e2e9975c0c1b7ef6204bf';

/// Holds a podcast's audio settings override; null when it has none.
///
/// UI must not call [saveSpeed] directly: speed changes go through
/// `AudioPlayerController.setSpeed` with a podcast scope, which also
/// applies the speed to the player and records analytics.
///
/// Every mutation updates memory before disk so controls follow input
/// immediately, and restores the previous state when the write fails so
/// memory never disagrees with what `play()` would read after a restart.
/// Mutations are ignored until the stored override has loaded: acting on
/// a loading state could be overwritten by the pending load.

final class PodcastAudioOverrideControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastAudioOverrideController,
          AsyncValue<AudioSettings?>,
          AudioSettings?,
          FutureOr<AudioSettings?>,
          int
        > {
  PodcastAudioOverrideControllerFamily._()
    : super(
        retry: null,
        name: r'podcastAudioOverrideControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Holds a podcast's audio settings override; null when it has none.
  ///
  /// UI must not call [saveSpeed] directly: speed changes go through
  /// `AudioPlayerController.setSpeed` with a podcast scope, which also
  /// applies the speed to the player and records analytics.
  ///
  /// Every mutation updates memory before disk so controls follow input
  /// immediately, and restores the previous state when the write fails so
  /// memory never disagrees with what `play()` would read after a restart.
  /// Mutations are ignored until the stored override has loaded: acting on
  /// a loading state could be overwritten by the pending load.

  PodcastAudioOverrideControllerProvider call(int podcastId) =>
      PodcastAudioOverrideControllerProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'podcastAudioOverrideControllerProvider';
}

/// Holds a podcast's audio settings override; null when it has none.
///
/// UI must not call [saveSpeed] directly: speed changes go through
/// `AudioPlayerController.setSpeed` with a podcast scope, which also
/// applies the speed to the player and records analytics.
///
/// Every mutation updates memory before disk so controls follow input
/// immediately, and restores the previous state when the write fails so
/// memory never disagrees with what `play()` would read after a restart.
/// Mutations are ignored until the stored override has loaded: acting on
/// a loading state could be overwritten by the pending load.

abstract class _$PodcastAudioOverrideController
    extends $AsyncNotifier<AudioSettings?> {
  late final _$args = ref.$arg as int;
  int get podcastId => _$args;

  FutureOr<AudioSettings?> build(int podcastId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AudioSettings?>, AudioSettings?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AudioSettings?>, AudioSettings?>,
              AsyncValue<AudioSettings?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
