// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_playing_artwork_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Prepares local, downscaled artwork for the system media controls.
///
/// On Android the files are handed out as `content:` URIs, which media
/// hosts outside the app (Android Auto, Android Automotive, System UI) can
/// open; iOS reads the `file:` URI inside the app.

@ProviderFor(nowPlayingArtworkPreparer)
final nowPlayingArtworkPreparerProvider = NowPlayingArtworkPreparerProvider._();

/// Prepares local, downscaled artwork for the system media controls.
///
/// On Android the files are handed out as `content:` URIs, which media
/// hosts outside the app (Android Auto, Android Automotive, System UI) can
/// open; iOS reads the `file:` URI inside the app.

final class NowPlayingArtworkPreparerProvider
    extends
        $FunctionalProvider<
          NowPlayingArtworkPreparer,
          NowPlayingArtworkPreparer,
          NowPlayingArtworkPreparer
        >
    with $Provider<NowPlayingArtworkPreparer> {
  /// Prepares local, downscaled artwork for the system media controls.
  ///
  /// On Android the files are handed out as `content:` URIs, which media
  /// hosts outside the app (Android Auto, Android Automotive, System UI) can
  /// open; iOS reads the `file:` URI inside the app.
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
    r'45061351961e55a2525c59b86c9a1b45fe1e01ef';
