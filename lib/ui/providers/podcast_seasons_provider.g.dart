// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'podcast_seasons_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSeasonsHash() => r'1d2a102efb232b8de1544abbec85ac39181d74e5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [podcastSeasons].
@ProviderFor(podcastSeasons)
const podcastSeasonsProvider = PodcastSeasonsFamily();

/// See also [podcastSeasons].
class PodcastSeasonsFamily extends Family<AsyncValue<List<Season>>> {
  /// See also [podcastSeasons].
  const PodcastSeasonsFamily();

  /// See also [podcastSeasons].
  PodcastSeasonsProvider call(
    Podcast podcast,
  ) {
    return PodcastSeasonsProvider(
      podcast,
    );
  }

  @override
  PodcastSeasonsProvider getProviderOverride(
    covariant PodcastSeasonsProvider provider,
  ) {
    return call(
      provider.podcast,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'podcastSeasonsProvider';
}

/// See also [podcastSeasons].
class PodcastSeasonsProvider extends AutoDisposeFutureProvider<List<Season>> {
  /// See also [podcastSeasons].
  PodcastSeasonsProvider(
    Podcast podcast,
  ) : this._internal(
          (ref) => podcastSeasons(
            ref as PodcastSeasonsRef,
            podcast,
          ),
          from: podcastSeasonsProvider,
          name: r'podcastSeasonsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastSeasonsHash,
          dependencies: PodcastSeasonsFamily._dependencies,
          allTransitiveDependencies:
              PodcastSeasonsFamily._allTransitiveDependencies,
          podcast: podcast,
        );

  PodcastSeasonsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.podcast,
  }) : super.internal();

  final Podcast podcast;

  @override
  Override overrideWith(
    FutureOr<List<Season>> Function(PodcastSeasonsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PodcastSeasonsProvider._internal(
        (ref) => create(ref as PodcastSeasonsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        podcast: podcast,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Season>> createElement() {
    return _PodcastSeasonsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSeasonsProvider && other.podcast == podcast;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, podcast.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastSeasonsRef on AutoDisposeFutureProviderRef<List<Season>> {
  /// The parameter `podcast` of this provider.
  Podcast get podcast;
}

class _PodcastSeasonsProviderElement
    extends AutoDisposeFutureProviderElement<List<Season>>
    with PodcastSeasonsRef {
  _PodcastSeasonsProviderElement(super.provider);

  @override
  Podcast get podcast => (origin as PodcastSeasonsProvider).podcast;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
