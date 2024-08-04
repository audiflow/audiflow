// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_episodes_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seasonEpisodesPageControllerHash() =>
    r'45b36e10dfe61867b2ea02686cc6fa1312493045';

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

abstract class _$SeasonEpisodesPageController
    extends BuildlessAutoDisposeAsyncNotifier<SeasonEpisodesState> {
  late final Season season;

  FutureOr<SeasonEpisodesState> build(
    Season season,
  );
}

/// See also [SeasonEpisodesPageController].
@ProviderFor(SeasonEpisodesPageController)
const seasonEpisodesPageControllerProvider =
    SeasonEpisodesPageControllerFamily();

/// See also [SeasonEpisodesPageController].
class SeasonEpisodesPageControllerFamily
    extends Family<AsyncValue<SeasonEpisodesState>> {
  /// See also [SeasonEpisodesPageController].
  const SeasonEpisodesPageControllerFamily();

  /// See also [SeasonEpisodesPageController].
  SeasonEpisodesPageControllerProvider call(
    Season season,
  ) {
    return SeasonEpisodesPageControllerProvider(
      season,
    );
  }

  @override
  SeasonEpisodesPageControllerProvider getProviderOverride(
    covariant SeasonEpisodesPageControllerProvider provider,
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
  String? get name => r'seasonEpisodesPageControllerProvider';
}

/// See also [SeasonEpisodesPageController].
class SeasonEpisodesPageControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SeasonEpisodesPageController,
        SeasonEpisodesState> {
  /// See also [SeasonEpisodesPageController].
  SeasonEpisodesPageControllerProvider(
    Season season,
  ) : this._internal(
          () => SeasonEpisodesPageController()..season = season,
          from: seasonEpisodesPageControllerProvider,
          name: r'seasonEpisodesPageControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seasonEpisodesPageControllerHash,
          dependencies: SeasonEpisodesPageControllerFamily._dependencies,
          allTransitiveDependencies:
              SeasonEpisodesPageControllerFamily._allTransitiveDependencies,
          season: season,
        );

  SeasonEpisodesPageControllerProvider._internal(
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
  FutureOr<SeasonEpisodesState> runNotifierBuild(
    covariant SeasonEpisodesPageController notifier,
  ) {
    return notifier.build(
      season,
    );
  }

  @override
  Override overrideWith(SeasonEpisodesPageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SeasonEpisodesPageControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SeasonEpisodesPageController,
      SeasonEpisodesState> createElement() {
    return _SeasonEpisodesPageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonEpisodesPageControllerProvider &&
        other.season == season;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, season.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SeasonEpisodesPageControllerRef
    on AutoDisposeAsyncNotifierProviderRef<SeasonEpisodesState> {
  /// The parameter `season` of this provider.
  Season get season;
}

class _SeasonEpisodesPageControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        SeasonEpisodesPageController,
        SeasonEpisodesState> with SeasonEpisodesPageControllerRef {
  _SeasonEpisodesPageControllerProviderElement(super.provider);

  @override
  Season get season => (origin as SeasonEpisodesPageControllerProvider).season;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
