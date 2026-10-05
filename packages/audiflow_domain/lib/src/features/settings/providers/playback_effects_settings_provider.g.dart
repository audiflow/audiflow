// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_effects_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the global [PlaybackEffects] and persists changes.
///
/// UI must not call [save] directly: effect changes go through
/// `AudioPlayerController.setEffect`, which also applies them to the
/// player. Unlike the speed there is no drag preview, so the state is
/// always the committed value.

@ProviderFor(PlaybackEffectsSettingsController)
final playbackEffectsSettingsControllerProvider =
    PlaybackEffectsSettingsControllerProvider._();

/// Holds the global [PlaybackEffects] and persists changes.
///
/// UI must not call [save] directly: effect changes go through
/// `AudioPlayerController.setEffect`, which also applies them to the
/// player. Unlike the speed there is no drag preview, so the state is
/// always the committed value.
final class PlaybackEffectsSettingsControllerProvider
    extends
        $NotifierProvider<PlaybackEffectsSettingsController, PlaybackEffects> {
  /// Holds the global [PlaybackEffects] and persists changes.
  ///
  /// UI must not call [save] directly: effect changes go through
  /// `AudioPlayerController.setEffect`, which also applies them to the
  /// player. Unlike the speed there is no drag preview, so the state is
  /// always the committed value.
  PlaybackEffectsSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackEffectsSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$playbackEffectsSettingsControllerHash();

  @$internal
  @override
  PlaybackEffectsSettingsController create() =>
      PlaybackEffectsSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackEffects value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackEffects>(value),
    );
  }
}

String _$playbackEffectsSettingsControllerHash() =>
    r'5f2fb711733674ba2114a2f59f83ce9206f56c03';

/// Holds the global [PlaybackEffects] and persists changes.
///
/// UI must not call [save] directly: effect changes go through
/// `AudioPlayerController.setEffect`, which also applies them to the
/// player. Unlike the speed there is no drag preview, so the state is
/// always the committed value.

abstract class _$PlaybackEffectsSettingsController
    extends $Notifier<PlaybackEffects> {
  PlaybackEffects build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackEffects, PlaybackEffects>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackEffects, PlaybackEffects>,
              PlaybackEffects,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
