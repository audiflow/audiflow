// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carplay_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(carPlayCatalog)
final carPlayCatalogProvider = CarPlayCatalogProvider._();

final class CarPlayCatalogProvider
    extends $FunctionalProvider<CarPlayCatalog, CarPlayCatalog, CarPlayCatalog>
    with $Provider<CarPlayCatalog> {
  CarPlayCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carPlayCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carPlayCatalogHash();

  @$internal
  @override
  $ProviderElement<CarPlayCatalog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CarPlayCatalog create(Ref ref) {
    return carPlayCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarPlayCatalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarPlayCatalog>(value),
    );
  }
}

String _$carPlayCatalogHash() => r'8ea2bd14394d9d27b623fe495bace7831dceb4af';

/// The running CarPlay bridge. Read once at startup on iOS to activate.
///
/// The list data is watched only while a head unit is connected, so a
/// phone that never uses CarPlay pays nothing for it.

@ProviderFor(carPlayBridge)
final carPlayBridgeProvider = CarPlayBridgeProvider._();

/// The running CarPlay bridge. Read once at startup on iOS to activate.
///
/// The list data is watched only while a head unit is connected, so a
/// phone that never uses CarPlay pays nothing for it.

final class CarPlayBridgeProvider
    extends $FunctionalProvider<CarPlayBridge, CarPlayBridge, CarPlayBridge>
    with $Provider<CarPlayBridge> {
  /// The running CarPlay bridge. Read once at startup on iOS to activate.
  ///
  /// The list data is watched only while a head unit is connected, so a
  /// phone that never uses CarPlay pays nothing for it.
  CarPlayBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carPlayBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carPlayBridgeHash();

  @$internal
  @override
  $ProviderElement<CarPlayBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CarPlayBridge create(Ref ref) {
    return carPlayBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarPlayBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarPlayBridge>(value),
    );
  }
}

String _$carPlayBridgeHash() => r'2675f49b288f76207c7c8d31a9c019590c6b3d3f';
