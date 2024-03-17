// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_episodes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewEpisodesHash() =>
    r'76d4fbeee9bb51f3e47bda22cc26a8e9532e7a12';

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

abstract class _$PodcastViewEpisodes
    extends BuildlessAutoDisposeAsyncNotifier<List<Episode>> {
  late final Podcast podcast;

  FutureOr<List<Episode>> build(
    Podcast podcast,
  );
}

/// See also [PodcastViewEpisodes].
@ProviderFor(PodcastViewEpisodes)
const podcastViewEpisodesProvider = PodcastViewEpisodesFamily();

/// See also [PodcastViewEpisodes].
class PodcastViewEpisodesFamily extends Family<AsyncValue<List<Episode>>> {
  /// See also [PodcastViewEpisodes].
  const PodcastViewEpisodesFamily();

  /// See also [PodcastViewEpisodes].
  PodcastViewEpisodesProvider call(
    Podcast podcast,
  ) {
    return PodcastViewEpisodesProvider(
      podcast,
    );
  }

  @override
  PodcastViewEpisodesProvider getProviderOverride(
    covariant PodcastViewEpisodesProvider provider,
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
  String? get name => r'podcastViewEpisodesProvider';
}

/// See also [PodcastViewEpisodes].
class PodcastViewEpisodesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastViewEpisodes, List<Episode>> {
  /// See also [PodcastViewEpisodes].
  PodcastViewEpisodesProvider(
    Podcast podcast,
  ) : this._internal(
          () => PodcastViewEpisodes()..podcast = podcast,
          from: podcastViewEpisodesProvider,
          name: r'podcastViewEpisodesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewEpisodesHash,
          dependencies: PodcastViewEpisodesFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewEpisodesFamily._allTransitiveDependencies,
          podcast: podcast,
        );

  PodcastViewEpisodesProvider._internal(
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
  FutureOr<List<Episode>> runNotifierBuild(
    covariant PodcastViewEpisodes notifier,
  ) {
    return notifier.build(
      podcast,
    );
  }

  @override
  Override overrideWith(PodcastViewEpisodes Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewEpisodesProvider._internal(
        () => create()..podcast = podcast,
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
  AutoDisposeAsyncNotifierProviderElement<PodcastViewEpisodes, List<Episode>>
      createElement() {
    return _PodcastViewEpisodesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewEpisodesProvider && other.podcast == podcast;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, podcast.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewEpisodesRef
    on AutoDisposeAsyncNotifierProviderRef<List<Episode>> {
  /// The parameter `podcast` of this provider.
  Podcast get podcast;
}

class _PodcastViewEpisodesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewEpisodes,
        List<Episode>> with PodcastViewEpisodesRef {
  _PodcastViewEpisodesProviderElement(super.provider);

  @override
  Podcast get podcast => (origin as PodcastViewEpisodesProvider).podcast;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
