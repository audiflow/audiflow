// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeHash() => r'd5e0f55b25fc3c9c779321c836b14859b403ec0e';

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

/// See also [episode].
@ProviderFor(episode)
const episodeProvider = EpisodeFamily();

/// See also [episode].
class EpisodeFamily extends Family<AsyncValue<Episode?>> {
  /// See also [episode].
  const EpisodeFamily();

  /// See also [episode].
  EpisodeProvider call({
    required int eid,
  }) {
    return EpisodeProvider(
      eid: eid,
    );
  }

  @override
  EpisodeProvider getProviderOverride(
    covariant EpisodeProvider provider,
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
  String? get name => r'episodeProvider';
}

/// See also [episode].
class EpisodeProvider extends AutoDisposeFutureProvider<Episode?> {
  /// See also [episode].
  EpisodeProvider({
    required int eid,
  }) : this._internal(
          (ref) => episode(
            ref as EpisodeRef,
            eid: eid,
          ),
          from: episodeProvider,
          name: r'episodeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeHash,
          dependencies: EpisodeFamily._dependencies,
          allTransitiveDependencies: EpisodeFamily._allTransitiveDependencies,
          eid: eid,
        );

  EpisodeProvider._internal(
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
    FutureOr<Episode?> Function(EpisodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EpisodeProvider._internal(
        (ref) => create(ref as EpisodeRef),
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
  AutoDisposeFutureProviderElement<Episode?> createElement() {
    return _EpisodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeProvider && other.eid == eid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodeRef on AutoDisposeFutureProviderRef<Episode?> {
  /// The parameter `eid` of this provider.
  int get eid;
}

class _EpisodeProviderElement extends AutoDisposeFutureProviderElement<Episode?>
    with EpisodeRef {
  _EpisodeProviderElement(super.provider);

  @override
  int get eid => (origin as EpisodeProvider).eid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
