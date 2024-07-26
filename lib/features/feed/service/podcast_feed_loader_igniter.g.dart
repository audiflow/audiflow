// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_feed_loader_igniter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastFeedLoaderIgniterHash() =>
    r'c7b196fc790f79e8d4e3ed3fa91891daf7f4a12c';

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

abstract class _$PodcastFeedLoaderIgniter
    extends BuildlessAutoDisposeAsyncNotifier<PodcastFeedLoaderState> {
  late final String? feedUrl;
  late final int? collectionId;

  FutureOr<PodcastFeedLoaderState> build({
    String? feedUrl,
    int? collectionId,
  });
}

/// See also [PodcastFeedLoaderIgniter].
@ProviderFor(PodcastFeedLoaderIgniter)
const podcastFeedLoaderIgniterProvider = PodcastFeedLoaderIgniterFamily();

/// See also [PodcastFeedLoaderIgniter].
class PodcastFeedLoaderIgniterFamily
    extends Family<AsyncValue<PodcastFeedLoaderState>> {
  /// See also [PodcastFeedLoaderIgniter].
  const PodcastFeedLoaderIgniterFamily();

  /// See also [PodcastFeedLoaderIgniter].
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

/// See also [PodcastFeedLoaderIgniter].
class PodcastFeedLoaderIgniterProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastFeedLoaderIgniter,
        PodcastFeedLoaderState> {
  /// See also [PodcastFeedLoaderIgniter].
  PodcastFeedLoaderIgniterProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          () => PodcastFeedLoaderIgniter()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
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
  FutureOr<PodcastFeedLoaderState> runNotifierBuild(
    covariant PodcastFeedLoaderIgniter notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastFeedLoaderIgniter Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastFeedLoaderIgniterProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastFeedLoaderIgniter,
      PodcastFeedLoaderState> createElement() {
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
    on AutoDisposeAsyncNotifierProviderRef<PodcastFeedLoaderState> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastFeedLoaderIgniterProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastFeedLoaderIgniter,
        PodcastFeedLoaderState> with PodcastFeedLoaderIgniterRef {
  _PodcastFeedLoaderIgniterProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastFeedLoaderIgniterProvider).feedUrl;
  @override
  int? get collectionId =>
      (origin as PodcastFeedLoaderIgniterProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
