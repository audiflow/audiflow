// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastInfoHash() => r'1e62de1b5f904ed2f8f1de0ba6038fdacd4bd07c';

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
    extends BuildlessAutoDisposeAsyncNotifier<PodcastInfoState> {
  late final int id;
  late final bool needsEpisodes;

  FutureOr<PodcastInfoState> build(
    int id, {
    required bool needsEpisodes,
  });
}

/// See also [PodcastInfo].
@ProviderFor(PodcastInfo)
const podcastInfoProvider = PodcastInfoFamily();

/// See also [PodcastInfo].
class PodcastInfoFamily extends Family<AsyncValue<PodcastInfoState>> {
  /// See also [PodcastInfo].
  const PodcastInfoFamily();

  /// See also [PodcastInfo].
  PodcastInfoProvider call(
    int id, {
    required bool needsEpisodes,
  }) {
    return PodcastInfoProvider(
      id,
      needsEpisodes: needsEpisodes,
    );
  }

  @override
  PodcastInfoProvider getProviderOverride(
    covariant PodcastInfoProvider provider,
  ) {
    return call(
      provider.id,
      needsEpisodes: provider.needsEpisodes,
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
    PodcastInfo, PodcastInfoState> {
  /// See also [PodcastInfo].
  PodcastInfoProvider(
    int id, {
    required bool needsEpisodes,
  }) : this._internal(
          () => PodcastInfo()
            ..id = id
            ..needsEpisodes = needsEpisodes,
          from: podcastInfoProvider,
          name: r'podcastInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastInfoHash,
          dependencies: PodcastInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastInfoFamily._allTransitiveDependencies,
          id: id,
          needsEpisodes: needsEpisodes,
        );

  PodcastInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
    required this.needsEpisodes,
  }) : super.internal();

  final int id;
  final bool needsEpisodes;

  @override
  FutureOr<PodcastInfoState> runNotifierBuild(
    covariant PodcastInfo notifier,
  ) {
    return notifier.build(
      id,
      needsEpisodes: needsEpisodes,
    );
  }

  @override
  Override overrideWith(PodcastInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastInfoProvider._internal(
        () => create()
          ..id = id
          ..needsEpisodes = needsEpisodes,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
        needsEpisodes: needsEpisodes,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastInfo, PodcastInfoState>
      createElement() {
    return _PodcastInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastInfoProvider &&
        other.id == id &&
        other.needsEpisodes == needsEpisodes;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, needsEpisodes.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastInfoRef on AutoDisposeAsyncNotifierProviderRef<PodcastInfoState> {
  /// The parameter `id` of this provider.
  int get id;

  /// The parameter `needsEpisodes` of this provider.
  bool get needsEpisodes;
}

class _PodcastInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastInfo,
        PodcastInfoState> with PodcastInfoRef {
  _PodcastInfoProviderElement(super.provider);

  @override
  int get id => (origin as PodcastInfoProvider).id;
  @override
  bool get needsEpisodes => (origin as PodcastInfoProvider).needsEpisodes;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
