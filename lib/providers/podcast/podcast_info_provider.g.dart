// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastInfoHash() => r'03b0992ce8c6caebcef35fc3fad187b6670c97b6';

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
  late final PodcastSummary baseInfo;

  FutureOr<PodcastInfoState> build(
    PodcastSummary baseInfo,
  );
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
    PodcastSummary baseInfo,
  ) {
    return PodcastInfoProvider(
      baseInfo,
    );
  }

  @override
  PodcastInfoProvider getProviderOverride(
    covariant PodcastInfoProvider provider,
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
  String? get name => r'podcastInfoProvider';
}

/// See also [PodcastInfo].
class PodcastInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastInfo, PodcastInfoState> {
  /// See also [PodcastInfo].
  PodcastInfoProvider(
    PodcastSummary baseInfo,
  ) : this._internal(
          () => PodcastInfo()..baseInfo = baseInfo,
          from: podcastInfoProvider,
          name: r'podcastInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastInfoHash,
          dependencies: PodcastInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastInfoFamily._allTransitiveDependencies,
          baseInfo: baseInfo,
        );

  PodcastInfoProvider._internal(
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
  FutureOr<PodcastInfoState> runNotifierBuild(
    covariant PodcastInfo notifier,
  ) {
    return notifier.build(
      baseInfo,
    );
  }

  @override
  Override overrideWith(PodcastInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastInfoProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastInfo, PodcastInfoState>
      createElement() {
    return _PodcastInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastInfoProvider && other.baseInfo == baseInfo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, baseInfo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastInfoRef on AutoDisposeAsyncNotifierProviderRef<PodcastInfoState> {
  /// The parameter `baseInfo` of this provider.
  PodcastSummary get baseInfo;
}

class _PodcastInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastInfo,
        PodcastInfoState> with PodcastInfoRef {
  _PodcastInfoProviderElement(super.provider);

  @override
  PodcastSummary get baseInfo => (origin as PodcastInfoProvider).baseInfo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
