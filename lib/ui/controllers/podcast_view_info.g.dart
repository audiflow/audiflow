// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewInfoHash() => r'49cda92d195414c768acdd04a655e945f70f9ebf';

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

abstract class _$PodcastViewInfo
    extends BuildlessAutoDisposeAsyncNotifier<PodcastViewStats> {
  late final String? feedUrl;
  late final int? collectionId;

  FutureOr<PodcastViewStats> build({
    String? feedUrl,
    int? collectionId,
  });
}

/// See also [PodcastViewInfo].
@ProviderFor(PodcastViewInfo)
const podcastViewInfoProvider = PodcastViewInfoFamily();

/// See also [PodcastViewInfo].
class PodcastViewInfoFamily extends Family<AsyncValue<PodcastViewStats>> {
  /// See also [PodcastViewInfo].
  const PodcastViewInfoFamily();

  /// See also [PodcastViewInfo].
  PodcastViewInfoProvider call({
    String? feedUrl,
    int? collectionId,
  }) {
    return PodcastViewInfoProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastViewInfoProvider getProviderOverride(
    covariant PodcastViewInfoProvider provider,
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
  String? get name => r'podcastViewInfoProvider';
}

/// See also [PodcastViewInfo].
class PodcastViewInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastViewInfo, PodcastViewStats> {
  /// See also [PodcastViewInfo].
  PodcastViewInfoProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          () => PodcastViewInfo()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
          from: podcastViewInfoProvider,
          name: r'podcastViewInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewInfoHash,
          dependencies: PodcastViewInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewInfoFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastViewInfoProvider._internal(
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
  FutureOr<PodcastViewStats> runNotifierBuild(
    covariant PodcastViewInfo notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastViewInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewInfoProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo, PodcastViewStats>
      createElement() {
    return _PodcastViewInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewInfoProvider &&
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

mixin PodcastViewInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastViewStats> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastViewInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo,
        PodcastViewStats> with PodcastViewInfoRef {
  _PodcastViewInfoProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastViewInfoProvider).feedUrl;
  @override
  int? get collectionId => (origin as PodcastViewInfoProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
