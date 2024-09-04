// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeStatsHash() => r'eaa6ac9f2f3f341fcffaa4a0acf2e8f353902442';

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

/// See also [episodeStats].
@ProviderFor(episodeStats)
const episodeStatsProvider = EpisodeStatsFamily();

/// See also [episodeStats].
class EpisodeStatsFamily extends Family<AsyncValue<EpisodeStats?>> {
  /// See also [episodeStats].
  const EpisodeStatsFamily();

  /// See also [episodeStats].
  EpisodeStatsProvider call({
    required int eid,
  }) {
    return EpisodeStatsProvider(
      eid: eid,
    );
  }

  @override
  EpisodeStatsProvider getProviderOverride(
    covariant EpisodeStatsProvider provider,
  ) {
    return call(
      eid: provider.eid,
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
  String? get name => r'episodeStatsProvider';
}

/// See also [episodeStats].
class EpisodeStatsProvider extends AutoDisposeFutureProvider<EpisodeStats?> {
  /// See also [episodeStats].
  EpisodeStatsProvider({
    required int eid,
  }) : this._internal(
          (ref) => episodeStats(
            ref as EpisodeStatsRef,
            eid: eid,
          ),
          from: episodeStatsProvider,
          name: r'episodeStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeStatsHash,
          dependencies: EpisodeStatsFamily._dependencies,
          allTransitiveDependencies:
              EpisodeStatsFamily._allTransitiveDependencies,
          eid: eid,
        );

  EpisodeStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eid,
  }) : super.internal();

  final int eid;

  @override
  Override overrideWith(
    FutureOr<EpisodeStats?> Function(EpisodeStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EpisodeStatsProvider._internal(
        (ref) => create(ref as EpisodeStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eid: eid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EpisodeStats?> createElement() {
    return _EpisodeStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeStatsProvider && other.eid == eid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodeStatsRef on AutoDisposeFutureProviderRef<EpisodeStats?> {
  /// The parameter `eid` of this provider.
  int get eid;
}

class _EpisodeStatsProviderElement
    extends AutoDisposeFutureProviderElement<EpisodeStats?>
    with EpisodeStatsRef {
  _EpisodeStatsProviderElement(super.provider);

  @override
  int get eid => (origin as EpisodeStatsProvider).eid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
