// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_playing_artwork_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Prepares local, downscaled artwork files for the system media controls.

@ProviderFor(nowPlayingArtworkPreparer)
final nowPlayingArtworkPreparerProvider = NowPlayingArtworkPreparerProvider._();

/// Prepares local, downscaled artwork files for the system media controls.

final class NowPlayingArtworkPreparerProvider
    extends
        $FunctionalProvider<
          NowPlayingArtworkPreparer,
          NowPlayingArtworkPreparer,
          NowPlayingArtworkPreparer
        >
    with $Provider<NowPlayingArtworkPreparer> {
  /// Prepares local, downscaled artwork files for the system media controls.
  NowPlayingArtworkPreparerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingArtworkPreparerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingArtworkPreparerHash();

  @$internal
  @override
  $ProviderElement<NowPlayingArtworkPreparer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NowPlayingArtworkPreparer create(Ref ref) {
    return nowPlayingArtworkPreparer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NowPlayingArtworkPreparer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NowPlayingArtworkPreparer>(value),
    );
  }
}

String _$nowPlayingArtworkPreparerHash() =>
    r'e12a8c4baaaa527eb455f844333bb1f3693dfaa9';
