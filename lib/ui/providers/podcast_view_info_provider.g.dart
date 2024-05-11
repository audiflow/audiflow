// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'podcast_view_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewInfoHash() => r'aa5efc0da78a28b0f2163dd82e8b9011e9e8023e';

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
  late final int id;

  FutureOr<PodcastViewStats> build(
    int id,
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
    int id,
  ) {
    return PodcastViewInfoProvider(
      id,
    );
  }

  @override
  PodcastViewInfoProvider getProviderOverride(
    covariant PodcastViewInfoProvider provider,
  ) {
    return call(
      provider.id,
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
    int id,
  ) : this._internal(
          () => PodcastViewInfo()..id = id,
          from: podcastViewInfoProvider,
          name: r'podcastViewInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewInfoHash,
          dependencies: PodcastViewInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewInfoFamily._allTransitiveDependencies,
          id: id,
        );

  PodcastViewInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  FutureOr<PodcastViewStats> runNotifierBuild(
    covariant PodcastViewInfo notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(PodcastViewInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewInfoProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
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
    return other is PodcastViewInfoProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastViewStats> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PodcastViewInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo,
        PodcastViewStats> with PodcastViewInfoRef {
  _PodcastViewInfoProviderElement(super.provider);

  @override
  int get id => (origin as PodcastViewInfoProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
