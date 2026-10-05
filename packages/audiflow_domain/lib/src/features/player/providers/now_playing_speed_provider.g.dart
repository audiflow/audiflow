// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_playing_speed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Playback speed in effect for the now-playing podcast: its override, or
/// the global speed.
///
/// Falls back to the global speed while the podcast's override is still
/// loading, so the value is always usable for display.

@ProviderFor(nowPlayingSpeed)
final nowPlayingSpeedProvider = NowPlayingSpeedProvider._();

/// Playback speed in effect for the now-playing podcast: its override, or
/// the global speed.
///
/// Falls back to the global speed while the podcast's override is still
/// loading, so the value is always usable for display.

final class NowPlayingSpeedProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Playback speed in effect for the now-playing podcast: its override, or
  /// the global speed.
  ///
  /// Falls back to the global speed while the podcast's override is still
  /// loading, so the value is always usable for display.
  NowPlayingSpeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingSpeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingSpeedHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return nowPlayingSpeed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$nowPlayingSpeedHash() => r'cfcf536d5842116e52047d7ae75aaeeb2e80c1de';
