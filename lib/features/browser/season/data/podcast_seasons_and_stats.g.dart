// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_seasons_and_stats.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSeasonsAndStatsHash() =>
    r'bd75f47a20093526c32bc8c71ec5cbb0b2438ca1';

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

abstract class _$PodcastSeasonsAndStats
    extends BuildlessAutoDisposeAsyncNotifier<List<SeasonPair>> {
  late final int pid;

  FutureOr<List<SeasonPair>> build(
    int pid,
  );
}

/// See also [PodcastSeasonsAndStats].
@ProviderFor(PodcastSeasonsAndStats)
const podcastSeasonsAndStatsProvider = PodcastSeasonsAndStatsFamily();

/// See also [PodcastSeasonsAndStats].
class PodcastSeasonsAndStatsFamily
    extends Family<AsyncValue<List<SeasonPair>>> {
  /// See also [PodcastSeasonsAndStats].
  const PodcastSeasonsAndStatsFamily();

  /// See also [PodcastSeasonsAndStats].
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

/// See also [PodcastSeasonsAndStats].
class PodcastSeasonsAndStatsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastSeasonsAndStats,
        List<SeasonPair>> {
  /// See also [PodcastSeasonsAndStats].
  PodcastSeasonsAndStatsProvider(
    int pid,
  ) : this._internal(
          () => PodcastSeasonsAndStats()..pid = pid,
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
  FutureOr<List<SeasonPair>> runNotifierBuild(
    covariant PodcastSeasonsAndStats notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(PodcastSeasonsAndStats Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastSeasonsAndStatsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastSeasonsAndStats,
      List<SeasonPair>> createElement() {
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PodcastSeasonsAndStatsRef
    on AutoDisposeAsyncNotifierProviderRef<List<SeasonPair>> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastSeasonsAndStatsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastSeasonsAndStats,
        List<SeasonPair>> with PodcastSeasonsAndStatsRef {
  _PodcastSeasonsAndStatsProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastSeasonsAndStatsProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
