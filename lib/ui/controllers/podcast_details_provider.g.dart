// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastDetailsHash() => r'370f7496ebe3e528bb446914b23c58468cd809cf';

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

abstract class _$PodcastDetails
    extends BuildlessAutoDisposeNotifier<PodcastDetailsState> {
  late final String? feedUrl;
  late final int? collectionId;

  PodcastDetailsState build({
    String? feedUrl,
    int? collectionId,
  });
}

/// See also [PodcastDetails].
@ProviderFor(PodcastDetails)
const podcastDetailsProvider = PodcastDetailsFamily();

/// See also [PodcastDetails].
class PodcastDetailsFamily extends Family<PodcastDetailsState> {
  /// See also [PodcastDetails].
  const PodcastDetailsFamily();

  /// See also [PodcastDetails].
  PodcastDetailsProvider call({
    String? feedUrl,
    int? collectionId,
  }) {
    return PodcastDetailsProvider(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  PodcastDetailsProvider getProviderOverride(
    covariant PodcastDetailsProvider provider,
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
  String? get name => r'podcastDetailsProvider';
}

/// See also [PodcastDetails].
class PodcastDetailsProvider extends AutoDisposeNotifierProviderImpl<
    PodcastDetails, PodcastDetailsState> {
  /// See also [PodcastDetails].
  PodcastDetailsProvider({
    String? feedUrl,
    int? collectionId,
  }) : this._internal(
          () => PodcastDetails()
            ..feedUrl = feedUrl
            ..collectionId = collectionId,
          from: podcastDetailsProvider,
          name: r'podcastDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastDetailsHash,
          dependencies: PodcastDetailsFamily._dependencies,
          allTransitiveDependencies:
              PodcastDetailsFamily._allTransitiveDependencies,
          feedUrl: feedUrl,
          collectionId: collectionId,
        );

  PodcastDetailsProvider._internal(
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
  PodcastDetailsState runNotifierBuild(
    covariant PodcastDetails notifier,
  ) {
    return notifier.build(
      feedUrl: feedUrl,
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastDetailsProvider._internal(
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
  AutoDisposeNotifierProviderElement<PodcastDetails, PodcastDetailsState>
      createElement() {
    return _PodcastDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailsProvider &&
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

mixin PodcastDetailsRef on AutoDisposeNotifierProviderRef<PodcastDetailsState> {
  /// The parameter `feedUrl` of this provider.
  String? get feedUrl;

  /// The parameter `collectionId` of this provider.
  int? get collectionId;
}

class _PodcastDetailsProviderElement extends AutoDisposeNotifierProviderElement<
    PodcastDetails, PodcastDetailsState> with PodcastDetailsRef {
  _PodcastDetailsProviderElement(super.provider);

  @override
  String? get feedUrl => (origin as PodcastDetailsProvider).feedUrl;
  @override
  int? get collectionId => (origin as PodcastDetailsProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
