// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_seasons_and_stats.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSeasonsAndStatsHash() =>
    r'8a9616419b2d08b11fd7dc33999bfa5805c98b3e';

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

/// See also [podcastSeasonsAndStats].
@ProviderFor(podcastSeasonsAndStats)
const podcastSeasonsAndStatsProvider = PodcastSeasonsAndStatsFamily();

/// See also [podcastSeasonsAndStats].
class PodcastSeasonsAndStatsFamily
    extends Family<AsyncValue<List<SeasonPair>>> {
  /// See also [podcastSeasonsAndStats].
  const PodcastSeasonsAndStatsFamily();

  /// See also [podcastSeasonsAndStats].
  PodcastSeasonsAndStatsProvider call(
    int pid,
  ) {
    return PodcastSeasonsAndStatsProvider(
      pid,
    );
  }

  @override
  PodcastSeasonsAndStatsProvider getProviderOverride(
    covariant PodcastSeasonsAndStatsProvider provider,
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
  String? get name => r'podcastSeasonsAndStatsProvider';
}

/// See also [podcastSeasonsAndStats].
class PodcastSeasonsAndStatsProvider
    extends AutoDisposeFutureProvider<List<SeasonPair>> {
  /// See also [podcastSeasonsAndStats].
  PodcastSeasonsAndStatsProvider(
    int pid,
  ) : this._internal(
          (ref) => podcastSeasonsAndStats(
            ref as PodcastSeasonsAndStatsRef,
            pid,
          ),
          from: podcastSeasonsAndStatsProvider,
          name: r'podcastSeasonsAndStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastSeasonsAndStatsHash,
          dependencies: PodcastSeasonsAndStatsFamily._dependencies,
          allTransitiveDependencies:
              PodcastSeasonsAndStatsFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastSeasonsAndStatsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<SeasonPair>> Function(PodcastSeasonsAndStatsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PodcastSeasonsAndStatsProvider._internal(
        (ref) => create(ref as PodcastSeasonsAndStatsRef),
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
  AutoDisposeFutureProviderElement<List<SeasonPair>> createElement() {
    return _PodcastSeasonsAndStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSeasonsAndStatsProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastSeasonsAndStatsRef
    on AutoDisposeFutureProviderRef<List<SeasonPair>> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastSeasonsAndStatsProviderElement
    extends AutoDisposeFutureProviderElement<List<SeasonPair>>
    with PodcastSeasonsAndStatsRef {
  _PodcastSeasonsAndStatsProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastSeasonsAndStatsProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
