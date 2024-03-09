// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastInfoHash() => r'884b0bee1bb525bdf1f1a730b1570bf8157d6659';

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

abstract class _$PodcastInfo
    extends BuildlessAutoDisposeAsyncNotifier<PodcastDetailsState> {
  late final PodcastMetadata metadata;

  FutureOr<PodcastDetailsState> build(
    PodcastMetadata metadata,
  );
}

/// See also [PodcastInfo].
@ProviderFor(PodcastInfo)
const podcastInfoProvider = PodcastInfoFamily();

/// See also [PodcastInfo].
class PodcastInfoFamily extends Family<AsyncValue<PodcastDetailsState>> {
  /// See also [PodcastInfo].
  const PodcastInfoFamily();

  /// See also [PodcastInfo].
  PodcastInfoProvider call(
    PodcastMetadata metadata,
  ) {
    return PodcastInfoProvider(
      metadata,
    );
  }

  @override
  PodcastInfoProvider getProviderOverride(
    covariant PodcastInfoProvider provider,
  ) {
    return call(
      provider.metadata,
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
  String? get name => r'podcastInfoProvider';
}

/// See also [PodcastInfo].
class PodcastInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastInfo, PodcastDetailsState> {
  /// See also [PodcastInfo].
  PodcastInfoProvider(
    PodcastMetadata metadata,
  ) : this._internal(
          () => PodcastInfo()..metadata = metadata,
          from: podcastInfoProvider,
          name: r'podcastInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastInfoHash,
          dependencies: PodcastInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastInfoFamily._allTransitiveDependencies,
          metadata: metadata,
        );

  PodcastInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.metadata,
  }) : super.internal();

  final PodcastMetadata metadata;

  @override
  FutureOr<PodcastDetailsState> runNotifierBuild(
    covariant PodcastInfo notifier,
  ) {
    return notifier.build(
      metadata,
    );
  }

  @override
  Override overrideWith(PodcastInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastInfoProvider._internal(
        () => create()..metadata = metadata,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        metadata: metadata,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastInfo, PodcastDetailsState>
      createElement() {
    return _PodcastInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastInfoProvider && other.metadata == metadata;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, metadata.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastDetailsState> {
  /// The parameter `metadata` of this provider.
  PodcastMetadata get metadata;
}

class _PodcastInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastInfo,
        PodcastDetailsState> with PodcastInfoRef {
  _PodcastInfoProviderElement(super.provider);

  @override
  PodcastMetadata get metadata => (origin as PodcastInfoProvider).metadata;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
