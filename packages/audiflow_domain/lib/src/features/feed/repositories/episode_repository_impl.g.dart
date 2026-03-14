// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [EpisodeRepository] instance.

@ProviderFor(episodeRepository)
final episodeRepositoryProvider = EpisodeRepositoryProvider._();

/// Provides a singleton [EpisodeRepository] instance.

final class EpisodeRepositoryProvider
    extends
        $FunctionalProvider<
          EpisodeRepository,
          EpisodeRepository,
          EpisodeRepository
        >
    with $Provider<EpisodeRepository> {
  /// Provides a singleton [EpisodeRepository] instance.
  EpisodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'episodeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$episodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<EpisodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EpisodeRepository create(Ref ref) {
    return episodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EpisodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EpisodeRepository>(value),
    );
  }
}

String _$episodeRepositoryHash() => r'f46b3874456013e1a7fee6f80aa58b42d6ef576d';
