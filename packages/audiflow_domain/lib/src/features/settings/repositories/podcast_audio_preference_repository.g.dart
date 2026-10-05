// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_audio_preference_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [PodcastAudioPreferenceLocalDatasource].

@ProviderFor(podcastAudioPreferenceLocalDatasource)
final podcastAudioPreferenceLocalDatasourceProvider =
    PodcastAudioPreferenceLocalDatasourceProvider._();

/// Provider for [PodcastAudioPreferenceLocalDatasource].

final class PodcastAudioPreferenceLocalDatasourceProvider
    extends
        $FunctionalProvider<
          PodcastAudioPreferenceLocalDatasource,
          PodcastAudioPreferenceLocalDatasource,
          PodcastAudioPreferenceLocalDatasource
        >
    with $Provider<PodcastAudioPreferenceLocalDatasource> {
  /// Provider for [PodcastAudioPreferenceLocalDatasource].
  PodcastAudioPreferenceLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastAudioPreferenceLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$podcastAudioPreferenceLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<PodcastAudioPreferenceLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastAudioPreferenceLocalDatasource create(Ref ref) {
    return podcastAudioPreferenceLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastAudioPreferenceLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<PodcastAudioPreferenceLocalDatasource>(value),
    );
  }
}

String _$podcastAudioPreferenceLocalDatasourceHash() =>
    r'8c582da7fb65f36443d5127b8bc3a14358d57710';

/// Provider for [PodcastAudioPreferenceRepository].

@ProviderFor(podcastAudioPreferenceRepository)
final podcastAudioPreferenceRepositoryProvider =
    PodcastAudioPreferenceRepositoryProvider._();

/// Provider for [PodcastAudioPreferenceRepository].

final class PodcastAudioPreferenceRepositoryProvider
    extends
        $FunctionalProvider<
          PodcastAudioPreferenceRepository,
          PodcastAudioPreferenceRepository,
          PodcastAudioPreferenceRepository
        >
    with $Provider<PodcastAudioPreferenceRepository> {
  /// Provider for [PodcastAudioPreferenceRepository].
  PodcastAudioPreferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastAudioPreferenceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastAudioPreferenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PodcastAudioPreferenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastAudioPreferenceRepository create(Ref ref) {
    return podcastAudioPreferenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastAudioPreferenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastAudioPreferenceRepository>(
        value,
      ),
    );
  }
}

String _$podcastAudioPreferenceRepositoryHash() =>
    r'32c194bffc943ec1ff276210d6c404baeb42c85d';
