// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_episode_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [StationEpisodeRepository] instance.

@ProviderFor(stationEpisodeRepository)
final stationEpisodeRepositoryProvider = StationEpisodeRepositoryProvider._();

/// Provides a singleton [StationEpisodeRepository] instance.

final class StationEpisodeRepositoryProvider
    extends
        $FunctionalProvider<
          StationEpisodeRepository,
          StationEpisodeRepository,
          StationEpisodeRepository
        >
    with $Provider<StationEpisodeRepository> {
  /// Provides a singleton [StationEpisodeRepository] instance.
  StationEpisodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationEpisodeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationEpisodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<StationEpisodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StationEpisodeRepository create(Ref ref) {
    return stationEpisodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationEpisodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationEpisodeRepository>(value),
    );
  }
}

String _$stationEpisodeRepositoryHash() =>
    r'f86c57fac19a63143c0141acec04166d21a69a39';
