// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episodes_group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodesGroupHash() => r'd7c6b9e45be26874a77ffc8e17ec447cfb1d1733';

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

abstract class _$EpisodesGroup
    extends BuildlessAutoDisposeAsyncNotifier<EpisodesGroupState> {
  late final Key key;

  FutureOr<EpisodesGroupState> build(
    Key key,
  );
}

/// See also [EpisodesGroup].
@ProviderFor(EpisodesGroup)
const episodesGroupProvider = EpisodesGroupFamily();

/// See also [EpisodesGroup].
class EpisodesGroupFamily extends Family<AsyncValue<EpisodesGroupState>> {
  /// See also [EpisodesGroup].
  const EpisodesGroupFamily();

  /// See also [EpisodesGroup].
  EpisodesGroupProvider call(
    Key key,
  ) {
    return EpisodesGroupProvider(
      key,
    );
  }

  @override
  EpisodesGroupProvider getProviderOverride(
    covariant EpisodesGroupProvider provider,
  ) {
    return call(
      provider.key,
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
  String? get name => r'episodesGroupProvider';
}

/// See also [EpisodesGroup].
class EpisodesGroupProvider extends AutoDisposeAsyncNotifierProviderImpl<
    EpisodesGroup, EpisodesGroupState> {
  /// See also [EpisodesGroup].
  EpisodesGroupProvider(
    Key key,
  ) : this._internal(
          () => EpisodesGroup()..key = key,
          from: episodesGroupProvider,
          name: r'episodesGroupProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodesGroupHash,
          dependencies: EpisodesGroupFamily._dependencies,
          allTransitiveDependencies:
              EpisodesGroupFamily._allTransitiveDependencies,
          key: key,
        );

  EpisodesGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final Key key;

  @override
  FutureOr<EpisodesGroupState> runNotifierBuild(
    covariant EpisodesGroup notifier,
  ) {
    return notifier.build(
      key,
    );
  }

  @override
  Override overrideWith(EpisodesGroup Function() create) {
    return ProviderOverride(
      origin: this,
      override: EpisodesGroupProvider._internal(
        () => create()..key = key,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<EpisodesGroup, EpisodesGroupState>
      createElement() {
    return _EpisodesGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodesGroupProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodesGroupRef
    on AutoDisposeAsyncNotifierProviderRef<EpisodesGroupState> {
  /// The parameter `key` of this provider.
  Key get key;
}

class _EpisodesGroupProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EpisodesGroup,
        EpisodesGroupState> with EpisodesGroupRef {
  _EpisodesGroupProviderElement(super.provider);

  @override
  Key get key => (origin as EpisodesGroupProvider).key;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
