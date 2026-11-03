// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(carCatalog)
final carCatalogProvider = CarCatalogProvider._();

final class CarCatalogProvider
    extends $FunctionalProvider<CarCatalog, CarCatalog, CarCatalog>
    with $Provider<CarCatalog> {
  CarCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carCatalogHash();

  @$internal
  @override
  $ProviderElement<CarCatalog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CarCatalog create(Ref ref) {
    return carCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarCatalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarCatalog>(value),
    );
  }
}

String _$carCatalogHash() => r'fb431994b15b30021fe420d484510686e2f29d71';

/// The artwork resolver shared by browse rows and the session queue, so they
/// share one cache and one limit on concurrent downloads.

@ProviderFor(carArtworkResolver)
final carArtworkResolverProvider = CarArtworkResolverProvider._();

/// The artwork resolver shared by browse rows and the session queue, so they
/// share one cache and one limit on concurrent downloads.

final class CarArtworkResolverProvider
    extends
        $FunctionalProvider<
          AsyncValue<CarArtworkResolver>,
          CarArtworkResolver,
          FutureOr<CarArtworkResolver>
        >
    with
        $FutureModifier<CarArtworkResolver>,
        $FutureProvider<CarArtworkResolver> {
  /// The artwork resolver shared by browse rows and the session queue, so they
  /// share one cache and one limit on concurrent downloads.
  CarArtworkResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carArtworkResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carArtworkResolverHash();

  @$internal
  @override
  $FutureProviderElement<CarArtworkResolver> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CarArtworkResolver> create(Ref ref) {
    return carArtworkResolver(ref);
  }
}

String _$carArtworkResolverHash() =>
    r'ace3c7e69450f545eb31ca06ba1758d2874bdef8';

/// Whether a head unit has browsed since the process started.
///
/// Android has no signal for a head unit connecting. Phones that never browse
/// must not download images nothing shows, so this gates session queue
/// artwork.

@ProviderFor(CarBrowsed)
final carBrowsedProvider = CarBrowsedProvider._();

/// Whether a head unit has browsed since the process started.
///
/// Android has no signal for a head unit connecting. Phones that never browse
/// must not download images nothing shows, so this gates session queue
/// artwork.
final class CarBrowsedProvider extends $NotifierProvider<CarBrowsed, bool> {
  /// Whether a head unit has browsed since the process started.
  ///
  /// Android has no signal for a head unit connecting. Phones that never browse
  /// must not download images nothing shows, so this gates session queue
  /// artwork.
  CarBrowsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carBrowsedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carBrowsedHash();

  @$internal
  @override
  CarBrowsed create() => CarBrowsed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$carBrowsedHash() => r'1de7be6b2c4cd6493b93670e0250d171348ee881';

/// Whether a head unit has browsed since the process started.
///
/// Android has no signal for a head unit connecting. Phones that never browse
/// must not download images nothing shows, so this gates session queue
/// artwork.

abstract class _$CarBrowsed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Android Auto's media browser. Created on the first browse request.

@ProviderFor(carMediaBrowser)
final carMediaBrowserProvider = CarMediaBrowserProvider._();

/// Android Auto's media browser. Created on the first browse request.

final class CarMediaBrowserProvider
    extends
        $FunctionalProvider<
          AsyncValue<CarMediaBrowser>,
          CarMediaBrowser,
          FutureOr<CarMediaBrowser>
        >
    with $FutureModifier<CarMediaBrowser>, $FutureProvider<CarMediaBrowser> {
  /// Android Auto's media browser. Created on the first browse request.
  CarMediaBrowserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carMediaBrowserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carMediaBrowserHash();

  @$internal
  @override
  $FutureProviderElement<CarMediaBrowser> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CarMediaBrowser> create(Ref ref) {
    return carMediaBrowser(ref);
  }
}

String _$carMediaBrowserHash() => r'4245e1b2b3ae526f519b257419c79454ced393c0';
