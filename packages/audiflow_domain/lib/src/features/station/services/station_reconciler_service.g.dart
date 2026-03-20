// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_reconciler_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stationReconcilerService)
final stationReconcilerServiceProvider = StationReconcilerServiceProvider._();

final class StationReconcilerServiceProvider
    extends
        $FunctionalProvider<
          StationReconcilerService,
          StationReconcilerService,
          StationReconcilerService
        >
    with $Provider<StationReconcilerService> {
  StationReconcilerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationReconcilerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationReconcilerServiceHash();

  @$internal
  @override
  $ProviderElement<StationReconcilerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StationReconcilerService create(Ref ref) {
    return stationReconcilerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationReconcilerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationReconcilerService>(value),
    );
  }
}

String _$stationReconcilerServiceHash() =>
    r'2f531a4499887f870a945c2449988a384698ccea';
