// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_podcast_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [StationPodcastRepository] instance.

@ProviderFor(stationPodcastRepository)
final stationPodcastRepositoryProvider = StationPodcastRepositoryProvider._();

/// Provides a singleton [StationPodcastRepository] instance.

final class StationPodcastRepositoryProvider
    extends
        $FunctionalProvider<
          StationPodcastRepository,
          StationPodcastRepository,
          StationPodcastRepository
        >
    with $Provider<StationPodcastRepository> {
  /// Provides a singleton [StationPodcastRepository] instance.
  StationPodcastRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationPodcastRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationPodcastRepositoryHash();

  @$internal
  @override
  $ProviderElement<StationPodcastRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StationPodcastRepository create(Ref ref) {
    return stationPodcastRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationPodcastRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationPodcastRepository>(value),
    );
  }
}

String _$stationPodcastRepositoryHash() =>
    r'bbe412b58434225d6a4660bc87954e928f605aec';
