// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reports whether the currently-playing episode has any chapter data.
///
/// Used by [SleepTimerController] to hide the "End of chapter" menu entry
/// and to evaluate chapter-dependent decisions. Returns false when no
/// episode is playing or when the episode has no chapters.

@ProviderFor(currentEpisodeHasChapters)
final currentEpisodeHasChaptersProvider = CurrentEpisodeHasChaptersProvider._();

/// Reports whether the currently-playing episode has any chapter data.
///
/// Used by [SleepTimerController] to hide the "End of chapter" menu entry
/// and to evaluate chapter-dependent decisions. Returns false when no
/// episode is playing or when the episode has no chapters.

final class CurrentEpisodeHasChaptersProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Reports whether the currently-playing episode has any chapter data.
  ///
  /// Used by [SleepTimerController] to hide the "End of chapter" menu entry
  /// and to evaluate chapter-dependent decisions. Returns false when no
  /// episode is playing or when the episode has no chapters.
  CurrentEpisodeHasChaptersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentEpisodeHasChaptersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentEpisodeHasChaptersHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return currentEpisodeHasChapters(ref);
  }
}

String _$currentEpisodeHasChaptersHash() =>
    r'b3b47155f84569dc79d25846009cb74b0003b011';

/// Coordinates the sleep timer: subscribes to player lifecycle events,
/// runs a 1s duration tick, and executes decisions from [SleepTimerService].
///
/// Kept alive so remembered values survive screen navigation.

@ProviderFor(SleepTimerController)
final sleepTimerControllerProvider = SleepTimerControllerProvider._();

/// Coordinates the sleep timer: subscribes to player lifecycle events,
/// runs a 1s duration tick, and executes decisions from [SleepTimerService].
///
/// Kept alive so remembered values survive screen navigation.
final class SleepTimerControllerProvider
    extends $NotifierProvider<SleepTimerController, SleepTimerState> {
  /// Coordinates the sleep timer: subscribes to player lifecycle events,
  /// runs a 1s duration tick, and executes decisions from [SleepTimerService].
  ///
  /// Kept alive so remembered values survive screen navigation.
  SleepTimerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerControllerHash();

  @$internal
  @override
  SleepTimerController create() => SleepTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SleepTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SleepTimerState>(value),
    );
  }
}

String _$sleepTimerControllerHash() =>
    r'725a0fb2e753b208eb87193f8e3f7c71e497e903';

/// Coordinates the sleep timer: subscribes to player lifecycle events,
/// runs a 1s duration tick, and executes decisions from [SleepTimerService].
///
/// Kept alive so remembered values survive screen navigation.

abstract class _$SleepTimerController extends $Notifier<SleepTimerState> {
  SleepTimerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SleepTimerState, SleepTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SleepTimerState, SleepTimerState>,
              SleepTimerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
