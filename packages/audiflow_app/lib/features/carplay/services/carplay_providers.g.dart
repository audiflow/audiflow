// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carplay_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$carPlayBridgeHash() => r'8dfe48116e3d256ac268dc008f49417e94a088cd';
