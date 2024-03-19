// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewInfoHash() => r'0e0bdd049b4ca8fdac8e6041f6e26c501a321d16';

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
  late final String guid;

  FutureOr<PodcastViewStats> build(
    String guid,
  );
}

/// See also [PodcastViewInfo].
@ProviderFor(PodcastViewInfo)
const podcastViewInfoProvider = PodcastViewInfoFamily();

/// See also [PodcastViewInfo].
class PodcastViewInfoFamily extends Family<AsyncValue<PodcastViewStats>> {
  /// See also [PodcastViewInfo].
  const PodcastViewInfoFamily();

  /// See also [PodcastViewInfo].
  PodcastViewInfoProvider call(
    String guid,
  ) {
    return PodcastViewInfoProvider(
      guid,
    );
  }

  @override
  PodcastViewInfoProvider getProviderOverride(
    covariant PodcastViewInfoProvider provider,
  ) {
    return call(
      provider.guid,
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
  PodcastViewInfoProvider(
    String guid,
  ) : this._internal(
          () => PodcastViewInfo()..guid = guid,
          from: podcastViewInfoProvider,
          name: r'podcastViewInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewInfoHash,
          dependencies: PodcastViewInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewInfoFamily._allTransitiveDependencies,
          guid: guid,
        );

  PodcastViewInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guid,
  }) : super.internal();

  final String guid;

  @override
  FutureOr<PodcastViewStats> runNotifierBuild(
    covariant PodcastViewInfo notifier,
  ) {
    return notifier.build(
      guid,
    );
  }

  @override
  Override overrideWith(PodcastViewInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewInfoProvider._internal(
        () => create()..guid = guid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guid: guid,
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
    return other is PodcastViewInfoProvider && other.guid == guid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastViewStats> {
  /// The parameter `guid` of this provider.
  String get guid;
}

class _PodcastViewInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo,
        PodcastViewStats> with PodcastViewInfoRef {
  _PodcastViewInfoProviderElement(super.provider);

  @override
  String get guid => (origin as PodcastViewInfoProvider).guid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
