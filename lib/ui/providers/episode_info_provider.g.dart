// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeInfoHash() => r'fb3a183efe3015a802b38431bb55c69c6cb07cd7';

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

abstract class _$EpisodeInfo
    extends BuildlessAutoDisposeAsyncNotifier<EpisodeInfoState> {
  late final Episode episode;
  late final EpisodeStats? stats;

  FutureOr<EpisodeInfoState> build(
    Episode episode, {
    EpisodeStats? stats,
  });
}

/// See also [EpisodeInfo].
@ProviderFor(EpisodeInfo)
const episodeInfoProvider = EpisodeInfoFamily();

/// See also [EpisodeInfo].
class EpisodeInfoFamily extends Family<AsyncValue<EpisodeInfoState>> {
  /// See also [EpisodeInfo].
  const EpisodeInfoFamily();

  /// See also [EpisodeInfo].
  EpisodeInfoProvider call(
    Episode episode, {
    EpisodeStats? stats,
  }) {
    return EpisodeInfoProvider(
      episode,
      stats: stats,
    );
  }

  @override
  EpisodeInfoProvider getProviderOverride(
    covariant EpisodeInfoProvider provider,
  ) {
    return call(
      provider.episode,
      stats: provider.stats,
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
  String? get name => r'episodeInfoProvider';
}

/// See also [EpisodeInfo].
class EpisodeInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    EpisodeInfo, EpisodeInfoState> {
  /// See also [EpisodeInfo].
  EpisodeInfoProvider(
    Episode episode, {
    EpisodeStats? stats,
  }) : this._internal(
          () => EpisodeInfo()
            ..episode = episode
            ..stats = stats,
          from: episodeInfoProvider,
          name: r'episodeInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeInfoHash,
          dependencies: EpisodeInfoFamily._dependencies,
          allTransitiveDependencies:
              EpisodeInfoFamily._allTransitiveDependencies,
          episode: episode,
          stats: stats,
        );

  EpisodeInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.episode,
    required this.stats,
  }) : super.internal();

  final Episode episode;
  final EpisodeStats? stats;

  @override
  FutureOr<EpisodeInfoState> runNotifierBuild(
    covariant EpisodeInfo notifier,
  ) {
    return notifier.build(
      episode,
      stats: stats,
    );
  }

  @override
  Override overrideWith(EpisodeInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: EpisodeInfoProvider._internal(
        () => create()
          ..episode = episode
          ..stats = stats,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        episode: episode,
        stats: stats,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<EpisodeInfo, EpisodeInfoState>
      createElement() {
    return _EpisodeInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeInfoProvider &&
        other.episode == episode &&
        other.stats == stats;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, episode.hashCode);
    hash = _SystemHash.combine(hash, stats.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodeInfoRef on AutoDisposeAsyncNotifierProviderRef<EpisodeInfoState> {
  /// The parameter `episode` of this provider.
  Episode get episode;

  /// The parameter `stats` of this provider.
  EpisodeStats? get stats;
}

class _EpisodeInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EpisodeInfo,
        EpisodeInfoState> with EpisodeInfoRef {
  _EpisodeInfoProviderElement(super.provider);

  @override
  Episode get episode => (origin as EpisodeInfoProvider).episode;
  @override
  EpisodeStats? get stats => (origin as EpisodeInfoProvider).stats;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
