// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the player applies [PlaybackEffect]s on this platform.
///
/// just_audio implements silence skipping and audio effects only on
/// Android. Elsewhere the effects UI is hidden and stored effect values
/// are ignored.

@ProviderFor(audioEffectsSupported)
final audioEffectsSupportedProvider = AudioEffectsSupportedProvider._();

/// Whether the player applies [PlaybackEffect]s on this platform.
///
/// just_audio implements silence skipping and audio effects only on
/// Android. Elsewhere the effects UI is hidden and stored effect values
/// are ignored.

final class AudioEffectsSupportedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the player applies [PlaybackEffect]s on this platform.
  ///
  /// just_audio implements silence skipping and audio effects only on
  /// Android. Elsewhere the effects UI is hidden and stored effect values
  /// are ignored.
  AudioEffectsSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioEffectsSupportedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioEffectsSupportedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return audioEffectsSupported(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$audioEffectsSupportedHash() =>
    r'9aa12a3aa400b011ceef98b60acd534405cebaa3';

/// The loudness effect behind voice boost, or null where effects are not
/// supported.
///
/// Created once for the player: just_audio attaches an effect to a
/// single player, and only when that player is constructed.

@ProviderFor(voiceBoostEffect)
final voiceBoostEffectProvider = VoiceBoostEffectProvider._();

/// The loudness effect behind voice boost, or null where effects are not
/// supported.
///
/// Created once for the player: just_audio attaches an effect to a
/// single player, and only when that player is constructed.

final class VoiceBoostEffectProvider
    extends
        $FunctionalProvider<
          AndroidLoudnessEnhancer?,
          AndroidLoudnessEnhancer?,
          AndroidLoudnessEnhancer?
        >
    with $Provider<AndroidLoudnessEnhancer?> {
  /// The loudness effect behind voice boost, or null where effects are not
  /// supported.
  ///
  /// Created once for the player: just_audio attaches an effect to a
  /// single player, and only when that player is constructed.
  VoiceBoostEffectProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceBoostEffectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceBoostEffectHash();

  @$internal
  @override
  $ProviderElement<AndroidLoudnessEnhancer?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AndroidLoudnessEnhancer? create(Ref ref) {
    return voiceBoostEffect(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AndroidLoudnessEnhancer? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AndroidLoudnessEnhancer?>(value),
    );
  }
}

String _$voiceBoostEffectHash() => r'8816cd5873c6639ab90ba05f19166b6c7431bca9';

/// Provides a singleton [AudioPlayer] instance.
///
/// This provider is kept alive for the app's lifetime to maintain audio state
/// across navigation and screen changes.

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

/// Provides a singleton [AudioPlayer] instance.
///
/// This provider is kept alive for the app's lifetime to maintain audio state
/// across navigation and screen changes.

final class AudioPlayerProvider
    extends $FunctionalProvider<AudioPlayer, AudioPlayer, AudioPlayer>
    with $Provider<AudioPlayer> {
  /// Provides a singleton [AudioPlayer] instance.
  ///
  /// This provider is kept alive for the app's lifetime to maintain audio state
  /// across navigation and screen changes.
  AudioPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayer create(Ref ref) {
    return audioPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer>(value),
    );
  }
}

String _$audioPlayerHash() => r'e06b17f4525089009f510dd175d5ddf623f26d08';

/// Provides a stream of the current playback speed.
///
/// Reactively updates when speed changes via [AudioPlayerController.setSpeed].

@ProviderFor(playbackSpeed)
final playbackSpeedProvider = PlaybackSpeedProvider._();

/// Provides a stream of the current playback speed.
///
/// Reactively updates when speed changes via [AudioPlayerController.setSpeed].

final class PlaybackSpeedProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  /// Provides a stream of the current playback speed.
  ///
  /// Reactively updates when speed changes via [AudioPlayerController.setSpeed].
  PlaybackSpeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackSpeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackSpeedHash();

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    return playbackSpeed(ref);
  }
}

String _$playbackSpeedHash() => r'd28ead49a076eb3b42ac76a446e4be96d63cc798';

/// Provides a stream of playback progress updates.
///
/// Combines position, duration, and buffered position into a single stream.
/// Updates approximately every 200ms while playing.

@ProviderFor(playbackProgressStream)
final playbackProgressStreamProvider = PlaybackProgressStreamProvider._();

/// Provides a stream of playback progress updates.
///
/// Combines position, duration, and buffered position into a single stream.
/// Updates approximately every 200ms while playing.

final class PlaybackProgressStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaybackProgress>,
          PlaybackProgress,
          Stream<PlaybackProgress>
        >
    with $FutureModifier<PlaybackProgress>, $StreamProvider<PlaybackProgress> {
  /// Provides a stream of playback progress updates.
  ///
  /// Combines position, duration, and buffered position into a single stream.
  /// Updates approximately every 200ms while playing.
  PlaybackProgressStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackProgressStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackProgressStreamHash();

  @$internal
  @override
  $StreamProviderElement<PlaybackProgress> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlaybackProgress> create(Ref ref) {
    return playbackProgressStream(ref);
  }
}

String _$playbackProgressStreamHash() =>
    r'158e0b1996954fb42b48619527dce62a18db62db';

/// Provides the current playback progress.
///
/// Returns null when no audio is loaded.

@ProviderFor(playbackProgress)
final playbackProgressProvider = PlaybackProgressProvider._();

/// Provides the current playback progress.
///
/// Returns null when no audio is loaded.

final class PlaybackProgressProvider
    extends
        $FunctionalProvider<
          PlaybackProgress?,
          PlaybackProgress?,
          PlaybackProgress?
        >
    with $Provider<PlaybackProgress?> {
  /// Provides the current playback progress.
  ///
  /// Returns null when no audio is loaded.
  PlaybackProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackProgressHash();

  @$internal
  @override
  $ProviderElement<PlaybackProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaybackProgress? create(Ref ref) {
    return playbackProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackProgress? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackProgress?>(value),
    );
  }
}

String _$playbackProgressHash() => r'dd7c9c1003e75d0513c2f075137b3948e3e139af';

/// Controller for managing audio playback.
///
/// Wraps [AudioPlayer] to provide a simplified interface and exposes
/// playback state as a reactive [PlaybackState] stream.
///
/// Integrates with [PlaybackHistoryService] to track playback progress
/// and auto-mark episodes as completed.
///
/// Usage:
/// ```dart
/// final state = ref.watch(audioPlayerControllerProvider);
/// final controller = ref.read(audioPlayerControllerProvider.notifier);
/// await controller.play('https://example.com/episode.mp3');
/// ```

@ProviderFor(AudioPlayerController)
final audioPlayerControllerProvider = AudioPlayerControllerProvider._();

/// Controller for managing audio playback.
///
/// Wraps [AudioPlayer] to provide a simplified interface and exposes
/// playback state as a reactive [PlaybackState] stream.
///
/// Integrates with [PlaybackHistoryService] to track playback progress
/// and auto-mark episodes as completed.
///
/// Usage:
/// ```dart
/// final state = ref.watch(audioPlayerControllerProvider);
/// final controller = ref.read(audioPlayerControllerProvider.notifier);
/// await controller.play('https://example.com/episode.mp3');
/// ```
final class AudioPlayerControllerProvider
    extends $NotifierProvider<AudioPlayerController, PlaybackState> {
  /// Controller for managing audio playback.
  ///
  /// Wraps [AudioPlayer] to provide a simplified interface and exposes
  /// playback state as a reactive [PlaybackState] stream.
  ///
  /// Integrates with [PlaybackHistoryService] to track playback progress
  /// and auto-mark episodes as completed.
  ///
  /// Usage:
  /// ```dart
  /// final state = ref.watch(audioPlayerControllerProvider);
  /// final controller = ref.read(audioPlayerControllerProvider.notifier);
  /// await controller.play('https://example.com/episode.mp3');
  /// ```
  AudioPlayerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerControllerHash();

  @$internal
  @override
  AudioPlayerController create() => AudioPlayerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackState>(value),
    );
  }
}

String _$audioPlayerControllerHash() =>
    r'c13a88b4c724b112698f9e9edba8e4556eccce07';

/// Controller for managing audio playback.
///
/// Wraps [AudioPlayer] to provide a simplified interface and exposes
/// playback state as a reactive [PlaybackState] stream.
///
/// Integrates with [PlaybackHistoryService] to track playback progress
/// and auto-mark episodes as completed.
///
/// Usage:
/// ```dart
/// final state = ref.watch(audioPlayerControllerProvider);
/// final controller = ref.read(audioPlayerControllerProvider.notifier);
/// await controller.play('https://example.com/episode.mp3');
/// ```

abstract class _$AudioPlayerController extends $Notifier<PlaybackState> {
  PlaybackState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackState, PlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackState, PlaybackState>,
              PlaybackState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
