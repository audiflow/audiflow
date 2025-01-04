// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadable_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeDownloadableHash() =>
    r'8ec5b13bb17484fc284603768c79f6dda4605e2b';

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

/// See also [episodeDownloadable].
@ProviderFor(episodeDownloadable)
const episodeDownloadableProvider = EpisodeDownloadableFamily();

/// See also [episodeDownloadable].
class EpisodeDownloadableFamily extends Family<AsyncValue<Downloadable?>> {
  /// See also [episodeDownloadable].
  const EpisodeDownloadableFamily();

  /// See also [episodeDownloadable].
  EpisodeDownloadableProvider call(
    int eid,
  ) {
    return EpisodeDownloadableProvider(
      eid,
    );
  }

  @override
  EpisodeDownloadableProvider getProviderOverride(
    covariant EpisodeDownloadableProvider provider,
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
  String? get name => r'episodeDownloadableProvider';
}

/// See also [episodeDownloadable].
class EpisodeDownloadableProvider
    extends AutoDisposeFutureProvider<Downloadable?> {
  /// See also [episodeDownloadable].
  EpisodeDownloadableProvider(
    int eid,
  ) : this._internal(
          (ref) => episodeDownloadable(
            ref as EpisodeDownloadableRef,
            eid,
          ),
          from: episodeDownloadableProvider,
          name: r'episodeDownloadableProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeDownloadableHash,
          dependencies: EpisodeDownloadableFamily._dependencies,
          allTransitiveDependencies:
              EpisodeDownloadableFamily._allTransitiveDependencies,
          eid: eid,
        );

  EpisodeDownloadableProvider._internal(
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
    FutureOr<Downloadable?> Function(EpisodeDownloadableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EpisodeDownloadableProvider._internal(
        (ref) => create(ref as EpisodeDownloadableRef),
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
  AutoDisposeFutureProviderElement<Downloadable?> createElement() {
    return _EpisodeDownloadableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeDownloadableProvider && other.eid == eid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EpisodeDownloadableRef on AutoDisposeFutureProviderRef<Downloadable?> {
  /// The parameter `eid` of this provider.
  int get eid;
}

class _EpisodeDownloadableProviderElement
    extends AutoDisposeFutureProviderElement<Downloadable?>
    with EpisodeDownloadableRef {
  _EpisodeDownloadableProviderElement(super.provider);

  @override
  int get eid => (origin as EpisodeDownloadableProvider).eid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
