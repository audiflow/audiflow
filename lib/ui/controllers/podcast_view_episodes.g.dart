// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_episodes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewEpisodesHash() =>
    r'daeb3f5926faf108e9ad8cc137291119e98572fd';

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
  late final int pid;

  FutureOr<List<Episode>> build(
    int pid,
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
    int pid,
  ) {
    return PodcastViewEpisodesProvider(
      pid,
    );
  }

  @override
  PodcastViewEpisodesProvider getProviderOverride(
    covariant PodcastViewEpisodesProvider provider,
  ) {
    return call(
      provider.pid,
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
    int pid,
  ) : this._internal(
          () => PodcastViewEpisodes()..pid = pid,
          from: podcastViewEpisodesProvider,
          name: r'podcastViewEpisodesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewEpisodesHash,
          dependencies: PodcastViewEpisodesFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewEpisodesFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastViewEpisodesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pid,
  }) : super.internal();

  final int pid;

  @override
  FutureOr<List<Episode>> runNotifierBuild(
    covariant PodcastViewEpisodes notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(PodcastViewEpisodes Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewEpisodesProvider._internal(
        () => create()..pid = pid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pid: pid,
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
    return other is PodcastViewEpisodesProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewEpisodesRef
    on AutoDisposeAsyncNotifierProviderRef<List<Episode>> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastViewEpisodesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewEpisodes,
        List<Episode>> with PodcastViewEpisodesRef {
  _PodcastViewEpisodesProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastViewEpisodesProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
