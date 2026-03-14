// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_preference_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [PodcastViewPreferenceLocalDatasource].

@ProviderFor(podcastViewPreferenceLocalDatasource)
final podcastViewPreferenceLocalDatasourceProvider =
    PodcastViewPreferenceLocalDatasourceProvider._();

/// Provider for [PodcastViewPreferenceLocalDatasource].

final class PodcastViewPreferenceLocalDatasourceProvider
    extends
        $FunctionalProvider<
          PodcastViewPreferenceLocalDatasource,
          PodcastViewPreferenceLocalDatasource,
          PodcastViewPreferenceLocalDatasource
        >
    with $Provider<PodcastViewPreferenceLocalDatasource> {
  /// Provider for [PodcastViewPreferenceLocalDatasource].
  PodcastViewPreferenceLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastViewPreferenceLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$podcastViewPreferenceLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<PodcastViewPreferenceLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastViewPreferenceLocalDatasource create(Ref ref) {
    return podcastViewPreferenceLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastViewPreferenceLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<PodcastViewPreferenceLocalDatasource>(value),
    );
  }
}

String _$podcastViewPreferenceLocalDatasourceHash() =>
    r'21c110d3ea164d015d4c28fa693dc75f52ce08e3';

/// Provider for [PodcastViewPreferenceRepository].

@ProviderFor(podcastViewPreferenceRepository)
final podcastViewPreferenceRepositoryProvider =
    PodcastViewPreferenceRepositoryProvider._();

/// Provider for [PodcastViewPreferenceRepository].

final class PodcastViewPreferenceRepositoryProvider
    extends
        $FunctionalProvider<
          PodcastViewPreferenceRepository,
          PodcastViewPreferenceRepository,
          PodcastViewPreferenceRepository
        >
    with $Provider<PodcastViewPreferenceRepository> {
  /// Provider for [PodcastViewPreferenceRepository].
  PodcastViewPreferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastViewPreferenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastViewPreferenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PodcastViewPreferenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastViewPreferenceRepository create(Ref ref) {
    return podcastViewPreferenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastViewPreferenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastViewPreferenceRepository>(
        value,
      ),
    );
  }
}

String _$podcastViewPreferenceRepositoryHash() =>
    r'0c21bf88e9e54041e7a976086755baf606eae1d3';
