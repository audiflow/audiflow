// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_playing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the currently playing episode metadata.
///
/// This controller is kept alive to maintain now playing state across
/// navigation and screen changes. The mini player uses this to display
/// episode information.

@ProviderFor(NowPlayingController)
final nowPlayingControllerProvider = NowPlayingControllerProvider._();

/// Manages the currently playing episode metadata.
///
/// This controller is kept alive to maintain now playing state across
/// navigation and screen changes. The mini player uses this to display
/// episode information.
final class NowPlayingControllerProvider
    extends $NotifierProvider<NowPlayingController, NowPlayingInfo?> {
  /// Manages the currently playing episode metadata.
  ///
  /// This controller is kept alive to maintain now playing state across
  /// navigation and screen changes. The mini player uses this to display
  /// episode information.
  NowPlayingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingControllerHash();

  @$internal
  @override
  NowPlayingController create() => NowPlayingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NowPlayingInfo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NowPlayingInfo?>(value),
    );
  }
}

String _$nowPlayingControllerHash() =>
    r'ec04a5c0cc700a46880dc71f3cd4f4384b849e11';

/// Manages the currently playing episode metadata.
///
/// This controller is kept alive to maintain now playing state across
/// navigation and screen changes. The mini player uses this to display
/// episode information.

abstract class _$NowPlayingController extends $Notifier<NowPlayingInfo?> {
  NowPlayingInfo? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NowPlayingInfo?, NowPlayingInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NowPlayingInfo?, NowPlayingInfo?>,
              NowPlayingInfo?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
