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

String _$carCatalogHash() => r'654b7207a0f3729bdcbbe46e3040ebe04f938ed4';

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

String _$carMediaBrowserHash() => r'b470f80432a11d8d979fb0826672ed8f7e3efe5b';
