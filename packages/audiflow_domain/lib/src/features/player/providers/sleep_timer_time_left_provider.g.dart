// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_timer_time_left_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Time until the active sleep timer stops playback; null when no timer is
/// armed or the stop point is unknown.
///
/// A duration timer refreshes on each whole second of its countdown. The
/// other modes follow the playback position, chapters, queue, and speed.

@ProviderFor(sleepTimerTimeLeft)
final sleepTimerTimeLeftProvider = SleepTimerTimeLeftProvider._();

/// Time until the active sleep timer stops playback; null when no timer is
/// armed or the stop point is unknown.
///
/// A duration timer refreshes on each whole second of its countdown. The
/// other modes follow the playback position, chapters, queue, and speed.

final class SleepTimerTimeLeftProvider
    extends
        $FunctionalProvider<
          SleepTimerTimeLeft?,
          SleepTimerTimeLeft?,
          SleepTimerTimeLeft?
        >
    with $Provider<SleepTimerTimeLeft?> {
  /// Time until the active sleep timer stops playback; null when no timer is
  /// armed or the stop point is unknown.
  ///
  /// A duration timer refreshes on each whole second of its countdown. The
  /// other modes follow the playback position, chapters, queue, and speed.
  SleepTimerTimeLeftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sleepTimerTimeLeftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sleepTimerTimeLeftHash();

  @$internal
  @override
  $ProviderElement<SleepTimerTimeLeft?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SleepTimerTimeLeft? create(Ref ref) {
    return sleepTimerTimeLeft(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SleepTimerTimeLeft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SleepTimerTimeLeft?>(value),
    );
  }
}

String _$sleepTimerTimeLeftHash() =>
    r'd403baf918442311774ee769794f1a90de571def';
