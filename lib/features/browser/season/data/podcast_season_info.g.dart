// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_season_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSeasonInfoHash() => r'5ea230fdeefd13bf2920d931af0a9c33ac334339';

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

abstract class _$PodcastSeasonInfo
    extends BuildlessAutoDisposeAsyncNotifier<PodcastSeasonInfoState> {
  late final Season season;

  FutureOr<PodcastSeasonInfoState> build(
    Season season,
  );
}

/// See also [PodcastSeasonInfo].
@ProviderFor(PodcastSeasonInfo)
const podcastSeasonInfoProvider = PodcastSeasonInfoFamily();

/// See also [PodcastSeasonInfo].
class PodcastSeasonInfoFamily
    extends Family<AsyncValue<PodcastSeasonInfoState>> {
  /// See also [PodcastSeasonInfo].
  const PodcastSeasonInfoFamily();

  /// See also [PodcastSeasonInfo].
  PodcastSeasonInfoProvider call(
    Season season,
  ) {
    return PodcastSeasonInfoProvider(
      season,
    );
  }

  @override
  PodcastSeasonInfoProvider getProviderOverride(
    covariant PodcastSeasonInfoProvider provider,
  ) {
    return call(
      provider.season,
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
  String? get name => r'podcastSeasonInfoProvider';
}

/// See also [PodcastSeasonInfo].
class PodcastSeasonInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastSeasonInfo, PodcastSeasonInfoState> {
  /// See also [PodcastSeasonInfo].
  PodcastSeasonInfoProvider(
    Season season,
  ) : this._internal(
          () => PodcastSeasonInfo()..season = season,
          from: podcastSeasonInfoProvider,
          name: r'podcastSeasonInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastSeasonInfoHash,
          dependencies: PodcastSeasonInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastSeasonInfoFamily._allTransitiveDependencies,
          season: season,
        );

  PodcastSeasonInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.season,
  }) : super.internal();

  final Season season;

  @override
  FutureOr<PodcastSeasonInfoState> runNotifierBuild(
    covariant PodcastSeasonInfo notifier,
  ) {
    return notifier.build(
      season,
    );
  }

  @override
  Override overrideWith(PodcastSeasonInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastSeasonInfoProvider._internal(
        () => create()..season = season,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        season: season,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastSeasonInfo,
      PodcastSeasonInfoState> createElement() {
    return _PodcastSeasonInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSeasonInfoProvider && other.season == season;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, season.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastSeasonInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastSeasonInfoState> {
  /// The parameter `season` of this provider.
  Season get season;
}

class _PodcastSeasonInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastSeasonInfo,
        PodcastSeasonInfoState> with PodcastSeasonInfoRef {
  _PodcastSeasonInfoProviderElement(super.provider);

  @override
  Season get season => (origin as PodcastSeasonInfoProvider).season;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
