// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_auto_loader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastAutoLoaderHash() => r'a5ba33e1631ffca40b8a83c353e8e3ea8c50cc85';

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

abstract class _$PodcastAutoLoader
    extends BuildlessAutoDisposeAsyncNotifier<Podcast?> {
  late final String? feedUrl;
  late final int? collectionId;

  FutureOr<Podcast?> build({
    String? feedUrl,
    int? collectionId,
  });
}

/// See also [PodcastAutoLoader].
@ProviderFor(PodcastAutoLoader)
const podcastAutoLoaderProvider = PodcastAutoLoaderFamily();

/// See also [PodcastAutoLoader].
class PodcastAutoLoaderFamily extends Family<AsyncValue<Podcast?>> {
  /// See also [PodcastAutoLoader].
  const PodcastAutoLoaderFamily();

  /// See also [PodcastAutoLoader].
  PodcastAutoLoaderProvider call({
    String? feedUrl,
    int? collectionId,
  }) {
    return PodcastAutoLoaderProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastAutoLoaderProvider getProviderOverride(
    covariant PodcastAutoLoaderProvider provider,
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
  String? get name => r'podcastAutoLoaderProvider';
}

/// See also [PodcastAutoLoader].
class PodcastAutoLoaderProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastAutoLoader, Podcast?> {
  /// See also [PodcastAutoLoader].
  PodcastAutoLoaderProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          () => PodcastAutoLoader()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
          from: podcastAutoLoaderProvider,
          name: r'podcastAutoLoaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastAutoLoaderHash,
          dependencies: PodcastAutoLoaderFamily._dependencies,
          allTransitiveDependencies:
              PodcastAutoLoaderFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastAutoLoaderProvider._internal(
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
  FutureOr<Podcast?> runNotifierBuild(
    covariant PodcastAutoLoader notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastAutoLoader Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastAutoLoaderProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastAutoLoader, Podcast?>
      createElement() {
    return _PodcastAutoLoaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastAutoLoaderProvider &&
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PodcastAutoLoaderRef on AutoDisposeAsyncNotifierProviderRef<Podcast?> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastAutoLoaderProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastAutoLoader, Podcast?>
    with PodcastAutoLoaderRef {
  _PodcastAutoLoaderProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastAutoLoaderProvider).feedUrl;
  @override
  int? get collectionId => (origin as PodcastAutoLoaderProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
