// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_speed_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the global [PlaybackSpeedSettings] and persists changes.
///
/// UI must not call [save] directly: speed changes go through
/// `AudioPlayerController.setSpeed`, which applies the speed to the
/// player, emits analytics, and then calls [save].

@ProviderFor(PlaybackSpeedSettingsController)
final playbackSpeedSettingsControllerProvider =
    PlaybackSpeedSettingsControllerProvider._();

/// Holds the global [PlaybackSpeedSettings] and persists changes.
///
/// UI must not call [save] directly: speed changes go through
/// `AudioPlayerController.setSpeed`, which applies the speed to the
/// player, emits analytics, and then calls [save].
final class PlaybackSpeedSettingsControllerProvider
    extends
        $NotifierProvider<
          PlaybackSpeedSettingsController,
          PlaybackSpeedSettings
        > {
  /// Holds the global [PlaybackSpeedSettings] and persists changes.
  ///
  /// UI must not call [save] directly: speed changes go through
  /// `AudioPlayerController.setSpeed`, which applies the speed to the
  /// player, emits analytics, and then calls [save].
  PlaybackSpeedSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackSpeedSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackSpeedSettingsControllerHash();

  @$internal
  @override
  PlaybackSpeedSettingsController create() => PlaybackSpeedSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackSpeedSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackSpeedSettings>(value),
    );
  }
}

String _$playbackSpeedSettingsControllerHash() =>
    r'36dac16eb8a803813253acc088f0022bccaab814';

/// Holds the global [PlaybackSpeedSettings] and persists changes.
///
/// UI must not call [save] directly: speed changes go through
/// `AudioPlayerController.setSpeed`, which applies the speed to the
/// player, emits analytics, and then calls [save].

abstract class _$PlaybackSpeedSettingsController
    extends $Notifier<PlaybackSpeedSettings> {
  PlaybackSpeedSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackSpeedSettings, PlaybackSpeedSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackSpeedSettings, PlaybackSpeedSettings>,
              PlaybackSpeedSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
