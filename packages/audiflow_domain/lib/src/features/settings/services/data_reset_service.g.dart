// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_reset_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [DataResetService] backing "Reset All Data".

@ProviderFor(dataResetService)
final dataResetServiceProvider = DataResetServiceProvider._();

/// Provides the [DataResetService] backing "Reset All Data".

final class DataResetServiceProvider
    extends
        $FunctionalProvider<
          DataResetService,
          DataResetService,
          DataResetService
        >
    with $Provider<DataResetService> {
  /// Provides the [DataResetService] backing "Reset All Data".
  DataResetServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataResetServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataResetServiceHash();

  @$internal
  @override
  $ProviderElement<DataResetService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataResetService create(Ref ref) {
    return dataResetService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataResetService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataResetService>(value),
    );
  }
}

String _$dataResetServiceHash() => r'595bd60cee4b2d0fd9bf732c4e434c4c233392d8';
