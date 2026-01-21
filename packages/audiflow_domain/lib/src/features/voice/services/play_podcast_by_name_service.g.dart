// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_podcast_by_name_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a [PodcastSearchService] instance for the domain layer.

@ProviderFor(podcastSearchService)
final podcastSearchServiceProvider = PodcastSearchServiceProvider._();

/// Provides a [PodcastSearchService] instance for the domain layer.

final class PodcastSearchServiceProvider
    extends
        $FunctionalProvider<
          PodcastSearchService,
          PodcastSearchService,
          PodcastSearchService
        >
    with $Provider<PodcastSearchService> {
  /// Provides a [PodcastSearchService] instance for the domain layer.
  PodcastSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastSearchServiceHash();

  @$internal
  @override
  $ProviderElement<PodcastSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastSearchService create(Ref ref) {
    return podcastSearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastSearchService>(value),
    );
  }
}

String _$podcastSearchServiceHash() =>
    r'74698dd17202f5494f1626f6db41a793a6a38ca3';

/// Provides a [PlayPodcastByNameService] instance.

@ProviderFor(playPodcastByNameService)
final playPodcastByNameServiceProvider = PlayPodcastByNameServiceProvider._();

/// Provides a [PlayPodcastByNameService] instance.

final class PlayPodcastByNameServiceProvider
    extends
        $FunctionalProvider<
          PlayPodcastByNameService,
          PlayPodcastByNameService,
          PlayPodcastByNameService
        >
    with $Provider<PlayPodcastByNameService> {
  /// Provides a [PlayPodcastByNameService] instance.
  PlayPodcastByNameServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playPodcastByNameServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playPodcastByNameServiceHash();

  @$internal
  @override
  $ProviderElement<PlayPodcastByNameService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayPodcastByNameService create(Ref ref) {
    return playPodcastByNameService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayPodcastByNameService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayPodcastByNameService>(value),
    );
  }
}

String _$playPodcastByNameServiceHash() =>
    r'0616088cc782277a5e89918d0e6fa3d49c8628da';
