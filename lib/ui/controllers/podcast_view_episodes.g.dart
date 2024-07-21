// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_episodes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewEpisodesHash() =>
    r'44ddc0206f98c957a24118a03f98eebe6cc95c1c';

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
  late final String guid;

  FutureOr<List<Episode>> build(
    String guid,
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
    String guid,
  ) {
    return PodcastViewEpisodesProvider(
      guid,
    );
  }

  @override
  PodcastViewEpisodesProvider getProviderOverride(
    covariant PodcastViewEpisodesProvider provider,
  ) {
    return call(
      provider.guid,
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
    String guid,
  ) : this._internal(
          () => PodcastViewEpisodes()..guid = guid,
          from: podcastViewEpisodesProvider,
          name: r'podcastViewEpisodesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewEpisodesHash,
          dependencies: PodcastViewEpisodesFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewEpisodesFamily._allTransitiveDependencies,
          guid: guid,
        );

  PodcastViewEpisodesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guid,
  }) : super.internal();

  final String guid;

  @override
  FutureOr<List<Episode>> runNotifierBuild(
    covariant PodcastViewEpisodes notifier,
  ) {
    return notifier.build(
      guid,
    );
  }

  @override
  Override overrideWith(PodcastViewEpisodes Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewEpisodesProvider._internal(
        () => create()..guid = guid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guid: guid,
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
    return other is PodcastViewEpisodesProvider && other.guid == guid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewEpisodesRef
    on AutoDisposeAsyncNotifierProviderRef<List<Episode>> {
  /// The parameter `guid` of this provider.
  String get guid;
}

class _PodcastViewEpisodesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewEpisodes,
        List<Episode>> with PodcastViewEpisodesRef {
  _PodcastViewEpisodesProviderElement(super.provider);

  @override
  String get guid => (origin as PodcastViewEpisodesProvider).guid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
