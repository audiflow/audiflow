// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_favorite_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(episodeFavoriteRepository)
final episodeFavoriteRepositoryProvider = EpisodeFavoriteRepositoryProvider._();

final class EpisodeFavoriteRepositoryProvider
    extends
        $FunctionalProvider<
          EpisodeFavoriteRepository,
          EpisodeFavoriteRepository,
          EpisodeFavoriteRepository
        >
    with $Provider<EpisodeFavoriteRepository> {
  EpisodeFavoriteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'episodeFavoriteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$episodeFavoriteRepositoryHash();

  @$internal
  @override
  $ProviderElement<EpisodeFavoriteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EpisodeFavoriteRepository create(Ref ref) {
    return episodeFavoriteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EpisodeFavoriteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EpisodeFavoriteRepository>(value),
    );
  }
}

String _$episodeFavoriteRepositoryHash() =>
    r'da9963f020839397b1c85cad7b9325268f0d3f1a';
