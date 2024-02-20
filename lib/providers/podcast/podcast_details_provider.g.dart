// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastDetailsHash() => r'793bd2480dcb01f9c58b79a28f49c3ca98164fc3';

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
    extends BuildlessAutoDisposeAsyncNotifier<PodcastDetailsState> {
  late final PodcastSummary baseInfo;

  FutureOr<PodcastDetailsState> build(
    PodcastSummary baseInfo,
  );
}

/// See also [PodcastDetails].
@ProviderFor(PodcastDetails)
const podcastDetailsProvider = PodcastDetailsFamily();

/// See also [PodcastDetails].
class PodcastDetailsFamily extends Family<AsyncValue<PodcastDetailsState>> {
  /// See also [PodcastDetails].
  const PodcastDetailsFamily();

  /// See also [PodcastDetails].
  PodcastDetailsProvider call(
    PodcastSummary baseInfo,
  ) {
    return PodcastDetailsProvider(
      baseInfo,
    );
  }

  @override
  PodcastDetailsProvider getProviderOverride(
    covariant PodcastDetailsProvider provider,
  ) {
    return call(
      provider.baseInfo,
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
class PodcastDetailsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastDetails, PodcastDetailsState> {
  /// See also [PodcastDetails].
  PodcastDetailsProvider(
    PodcastSummary baseInfo,
  ) : this._internal(
          () => PodcastDetails()..baseInfo = baseInfo,
          from: podcastDetailsProvider,
          name: r'podcastDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastDetailsHash,
          dependencies: PodcastDetailsFamily._dependencies,
          allTransitiveDependencies:
              PodcastDetailsFamily._allTransitiveDependencies,
          baseInfo: baseInfo,
        );

  PodcastDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.baseInfo,
  }) : super.internal();

  final PodcastSummary baseInfo;

  @override
  FutureOr<PodcastDetailsState> runNotifierBuild(
    covariant PodcastDetails notifier,
  ) {
    return notifier.build(
      baseInfo,
    );
  }

  @override
  Override overrideWith(PodcastDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastDetailsProvider._internal(
        () => create()..baseInfo = baseInfo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        baseInfo: baseInfo,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastDetails, PodcastDetailsState>
      createElement() {
    return _PodcastDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailsProvider && other.baseInfo == baseInfo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, baseInfo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastDetailsRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastDetailsState> {
  /// The parameter `baseInfo` of this provider.
  PodcastSummary get baseInfo;
}

class _PodcastDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastDetails,
        PodcastDetailsState> with PodcastDetailsRef {
  _PodcastDetailsProviderElement(super.provider);

  @override
  PodcastSummary get baseInfo => (origin as PodcastDetailsProvider).baseInfo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
