// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_feed_loader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastFeedLoaderHash() => r'd73a4a502e89ed0cea2636505e23a1d4e9d0ac2f';

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

abstract class _$PodcastFeedLoader
    extends BuildlessAutoDisposeNotifier<PodcastFeedLoaderState> {
  late final String feedUrl;
  late final int collectionId;

  PodcastFeedLoaderState build({
    required String feedUrl,
    required int collectionId,
  });
}

/// See also [PodcastFeedLoader].
@ProviderFor(PodcastFeedLoader)
const podcastFeedLoaderProvider = PodcastFeedLoaderFamily();

/// See also [PodcastFeedLoader].
class PodcastFeedLoaderFamily extends Family<PodcastFeedLoaderState> {
  /// See also [PodcastFeedLoader].
  const PodcastFeedLoaderFamily();

  /// See also [PodcastFeedLoader].
  PodcastFeedLoaderProvider call({
    required String feedUrl,
    required int collectionId,
  }) {
    return PodcastFeedLoaderProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastFeedLoaderProvider getProviderOverride(
    covariant PodcastFeedLoaderProvider provider,
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
  String? get name => r'podcastFeedLoaderProvider';
}

/// See also [PodcastFeedLoader].
class PodcastFeedLoaderProvider extends AutoDisposeNotifierProviderImpl<
    PodcastFeedLoader, PodcastFeedLoaderState> {
  /// See also [PodcastFeedLoader].
  PodcastFeedLoaderProvider({
    required String feedUrl,
    required int collectionId,
  }) : this._internal(
          () => PodcastFeedLoader()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
          from: podcastFeedLoaderProvider,
          name: r'podcastFeedLoaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastFeedLoaderHash,
          dependencies: PodcastFeedLoaderFamily._dependencies,
          allTransitiveDependencies:
              PodcastFeedLoaderFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastFeedLoaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedUrl,
    required this.collectionId,
  }) : super.internal();

  final String feedUrl;
  final int collectionId;

  @override
  PodcastFeedLoaderState runNotifierBuild(
    covariant PodcastFeedLoader notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastFeedLoader Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastFeedLoaderProvider._internal(
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
  AutoDisposeNotifierProviderElement<PodcastFeedLoader, PodcastFeedLoaderState>
      createElement() {
    return _PodcastFeedLoaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastFeedLoaderProvider &&
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

mixin PodcastFeedLoaderRef
    on AutoDisposeNotifierProviderRef<PodcastFeedLoaderState> {
  /// The parameter `feedUrl` of this provider.
  String get feedUrl;

  /// The parameter `collectionId` of this provider.
  int get collectionId;
}

class _PodcastFeedLoaderProviderElement
    extends AutoDisposeNotifierProviderElement<PodcastFeedLoader,
        PodcastFeedLoaderState> with PodcastFeedLoaderRef {
  _PodcastFeedLoaderProviderElement(super.provider);

  @override
  String get feedUrl => (origin as PodcastFeedLoaderProvider).feedUrl;
  @override
  int get collectionId => (origin as PodcastFeedLoaderProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
