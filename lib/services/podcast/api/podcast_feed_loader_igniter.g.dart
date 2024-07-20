// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_feed_loader_igniter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastFeedLoaderIgniterHash() =>
    r'ba75790ad9f181113c9545dca73434214400f6e7';

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

/// See also [podcastFeedLoaderIgniter].
@ProviderFor(podcastFeedLoaderIgniter)
const podcastFeedLoaderIgniterProvider = PodcastFeedLoaderIgniterFamily();

/// See also [podcastFeedLoaderIgniter].
class PodcastFeedLoaderIgniterFamily
    extends Family<AsyncValue<PodcastFeedLoaderState>> {
  /// See also [podcastFeedLoaderIgniter].
  const PodcastFeedLoaderIgniterFamily();

  /// See also [podcastFeedLoaderIgniter].
  PodcastFeedLoaderIgniterProvider call({
    String? feedUrl,
    int? collectionId,
  }) {
    return PodcastFeedLoaderIgniterProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastFeedLoaderIgniterProvider getProviderOverride(
    covariant PodcastFeedLoaderIgniterProvider provider,
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
  String? get name => r'podcastFeedLoaderIgniterProvider';
}

/// See also [podcastFeedLoaderIgniter].
class PodcastFeedLoaderIgniterProvider
    extends AutoDisposeFutureProvider<PodcastFeedLoaderState> {
  /// See also [podcastFeedLoaderIgniter].
  PodcastFeedLoaderIgniterProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          (ref) => podcastFeedLoaderIgniter(
            ref as PodcastFeedLoaderIgniterRef,
            feedUrl: feedUrl,
            collectionId: collectionId,
          ),
          from: podcastFeedLoaderIgniterProvider,
          name: r'podcastFeedLoaderIgniterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastFeedLoaderIgniterHash,
          dependencies: PodcastFeedLoaderIgniterFamily._dependencies,
          allTransitiveDependencies:
              PodcastFeedLoaderIgniterFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastFeedLoaderIgniterProvider._internal(
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
  Override overrideWith(
    FutureOr<PodcastFeedLoaderState> Function(
            PodcastFeedLoaderIgniterRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PodcastFeedLoaderIgniterProvider._internal(
        (ref) => create(ref as PodcastFeedLoaderIgniterRef),
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
  AutoDisposeFutureProviderElement<PodcastFeedLoaderState> createElement() {
    return _PodcastFeedLoaderIgniterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastFeedLoaderIgniterProvider &&
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

mixin PodcastFeedLoaderIgniterRef
    on AutoDisposeFutureProviderRef<PodcastFeedLoaderState> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastFeedLoaderIgniterProviderElement
    extends AutoDisposeFutureProviderElement<PodcastFeedLoaderState>
    with PodcastFeedLoaderIgniterRef {
  _PodcastFeedLoaderIgniterProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastFeedLoaderIgniterProvider).feedUrl;
  @override
  int? get collectionId =>
      (origin as PodcastFeedLoaderIgniterProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
