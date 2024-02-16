// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastDetailHash() => r'2e207ba457ba2a18b6120c1d157e1815602e79cb';

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

abstract class _$PodcastDetail
    extends BuildlessAutoDisposeAsyncNotifier<PodcastDetailsState> {
  late final String guid;

  FutureOr<PodcastDetailsState> build(
    String guid,
  );
}

/// See also [PodcastDetail].
@ProviderFor(PodcastDetail)
const podcastDetailProvider = PodcastDetailFamily();

/// See also [PodcastDetail].
class PodcastDetailFamily extends Family<AsyncValue<PodcastDetailsState>> {
  /// See also [PodcastDetail].
  const PodcastDetailFamily();

  /// See also [PodcastDetail].
  PodcastDetailProvider call(
    String guid,
  ) {
    return PodcastDetailProvider(
      guid,
    );
  }

  @override
  PodcastDetailProvider getProviderOverride(
    covariant PodcastDetailProvider provider,
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
  String? get name => r'podcastDetailProvider';
}

/// See also [PodcastDetail].
class PodcastDetailProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastDetail, PodcastDetailsState> {
  /// See also [PodcastDetail].
  PodcastDetailProvider(
    String guid,
  ) : this._internal(
          () => PodcastDetail()..guid = guid,
          from: podcastDetailProvider,
          name: r'podcastDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastDetailHash,
          dependencies: PodcastDetailFamily._dependencies,
          allTransitiveDependencies:
              PodcastDetailFamily._allTransitiveDependencies,
          guid: guid,
        );

  PodcastDetailProvider._internal(
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
  FutureOr<PodcastDetailsState> runNotifierBuild(
    covariant PodcastDetail notifier,
  ) {
    return notifier.build(
      guid,
    );
  }

  @override
  Override overrideWith(PodcastDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastDetailProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastDetail, PodcastDetailsState>
      createElement() {
    return _PodcastDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailProvider && other.guid == guid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastDetailRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastDetailsState> {
  /// The parameter `guid` of this provider.
  String get guid;
}

class _PodcastDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastDetail,
        PodcastDetailsState> with PodcastDetailRef {
  _PodcastDetailProviderElement(super.provider);

  @override
  String get guid => (origin as PodcastDetailProvider).guid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
