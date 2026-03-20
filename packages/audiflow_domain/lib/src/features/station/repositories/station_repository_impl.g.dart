// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [StationRepository] instance.

@ProviderFor(stationRepository)
final stationRepositoryProvider = StationRepositoryProvider._();

/// Provides a singleton [StationRepository] instance.

final class StationRepositoryProvider
    extends
        $FunctionalProvider<
          StationRepository,
          StationRepository,
          StationRepository
        >
    with $Provider<StationRepository> {
  /// Provides a singleton [StationRepository] instance.
  StationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationRepositoryHash();

  @$internal
  @override
  $ProviderElement<StationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StationRepository create(Ref ref) {
    return stationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationRepository>(value),
    );
  }
}

String _$stationRepositoryHash() => r'6327a9897abe1580a4c624a5e88db8ecce548116';
