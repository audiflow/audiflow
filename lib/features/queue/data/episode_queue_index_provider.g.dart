// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_queue_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeQueueIndexHash() => r'574a5fdde5c3a26406a68831118e7f3d228caa49';

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

/// See also [episodeQueueIndex].
@ProviderFor(episodeQueueIndex)
const episodeQueueIndexProvider = EpisodeQueueIndexFamily();

/// See also [episodeQueueIndex].
class EpisodeQueueIndexFamily extends Family<int?> {
  /// See also [episodeQueueIndex].
  const EpisodeQueueIndexFamily();

  /// See also [episodeQueueIndex].
  EpisodeQueueIndexProvider call(
    int eid,
  ) {
    return EpisodeQueueIndexProvider(
      eid,
    );
  }

  @override
  EpisodeQueueIndexProvider getProviderOverride(
    covariant EpisodeQueueIndexProvider provider,
  ) {
    return call(
      provider.eid,
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
  String? get name => r'episodeQueueIndexProvider';
}

/// See also [episodeQueueIndex].
class EpisodeQueueIndexProvider extends AutoDisposeProvider<int?> {
  /// See also [episodeQueueIndex].
  EpisodeQueueIndexProvider(
    int eid,
  ) : this._internal(
          (ref) => episodeQueueIndex(
            ref as EpisodeQueueIndexRef,
            eid,
          ),
          from: episodeQueueIndexProvider,
          name: r'episodeQueueIndexProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeQueueIndexHash,
          dependencies: EpisodeQueueIndexFamily._dependencies,
          allTransitiveDependencies:
              EpisodeQueueIndexFamily._allTransitiveDependencies,
          eid: eid,
        );

  EpisodeQueueIndexProvider._internal(
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
    int? Function(EpisodeQueueIndexRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EpisodeQueueIndexProvider._internal(
        (ref) => create(ref as EpisodeQueueIndexRef),
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
  AutoDisposeProviderElement<int?> createElement() {
    return _EpisodeQueueIndexProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeQueueIndexProvider && other.eid == eid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodeQueueIndexRef on AutoDisposeProviderRef<int?> {
  /// The parameter `eid` of this provider.
  int get eid;
}

class _EpisodeQueueIndexProviderElement extends AutoDisposeProviderElement<int?>
    with EpisodeQueueIndexRef {
  _EpisodeQueueIndexProviderElement(super.provider);

  @override
  int get eid => (origin as EpisodeQueueIndexProvider).eid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
