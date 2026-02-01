// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$audioPlayerHash() => r'39aa2c7d111a8c4afdcf352654abd1ca07ad0c40';

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
    r'85be5dc0d251b66300127fc122417726deef4d6e';

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
