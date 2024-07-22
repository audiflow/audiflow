// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastInfoHash() => r'60b218a4b0af32f12804a791c8aa8bf7b3c71b17';

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
  late final String? feedUrl;
  late final int? collectionId;

  FutureOr<PodcastInfoState> build({
    String? feedUrl,
    int? collectionId,
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
  PodcastInfoProvider call({
    String? feedUrl,
    int? collectionId,
  }) {
    return PodcastInfoProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastInfoProvider getProviderOverride(
    covariant PodcastInfoProvider provider,
  ) {
    return call(
      feedUrl: provider.feedUrl,
      collectionId: provider.collectionId,
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
  PodcastInfoProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          () => PodcastInfo()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
          from: podcastInfoProvider,
          name: r'podcastInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastInfoHash,
          dependencies: PodcastInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastInfoFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedUrl,
    required this.collectionId,
  }) : super.internal();

  final String? feedUrl;
  final int? collectionId;

  @override
  FutureOr<PodcastInfoState> runNotifierBuild(
    covariant PodcastInfo notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastInfoProvider._internal(
        () => create()
          ..feedUrl = feedUrl
          ..collectionId = collectionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedUrl: feedUrl,
        collectionId: collectionId,
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
        other.feedUrl == feedUrl &&
        other.collectionId == collectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedUrl.hashCode);
    hash = _SystemHash.combine(hash, collectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastInfoRef on AutoDisposeAsyncNotifierProviderRef<PodcastInfoState> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastInfo,
        PodcastInfoState> with PodcastInfoRef {
  _PodcastInfoProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastInfoProvider).feedUrl;
  @override
  int? get collectionId => (origin as PodcastInfoProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
