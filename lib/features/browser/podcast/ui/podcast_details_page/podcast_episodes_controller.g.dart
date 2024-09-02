// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_episodes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastEpisodesControllerHash() =>
    r'cad7dfc418b56461a4ec3e022b93bd4efa4997fc';

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

abstract class _$PodcastEpisodesController
    extends BuildlessAutoDisposeAsyncNotifier<EpisodeListState> {
  late final int pid;
  late final EpisodeFilterMode filterMode;
  late final bool ascending;
  late final int episodesPerPage;

  FutureOr<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 30,
  });
}

/// See also [PodcastEpisodesController].
@ProviderFor(PodcastEpisodesController)
const podcastEpisodesControllerProvider = PodcastEpisodesControllerFamily();

/// See also [PodcastEpisodesController].
class PodcastEpisodesControllerFamily
    extends Family<AsyncValue<EpisodeListState>> {
  /// See also [PodcastEpisodesController].
  const PodcastEpisodesControllerFamily();

  /// See also [PodcastEpisodesController].
  PodcastEpisodesControllerProvider call({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 30,
  }) {
    return PodcastEpisodesControllerProvider(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      episodesPerPage: episodesPerPage,
    );
  }

  @override
  PodcastEpisodesControllerProvider getProviderOverride(
    covariant PodcastEpisodesControllerProvider provider,
  ) {
    return call(
      pid: provider.pid,
      filterMode: provider.filterMode,
      ascending: provider.ascending,
      episodesPerPage: provider.episodesPerPage,
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
  String? get name => r'podcastEpisodesControllerProvider';
}

/// See also [PodcastEpisodesController].
class PodcastEpisodesControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastEpisodesController,
        EpisodeListState> {
  /// See also [PodcastEpisodesController].
  PodcastEpisodesControllerProvider({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 30,
  }) : this._internal(
          () => PodcastEpisodesController()
            ..pid = pid
            ..filterMode = filterMode
            ..ascending = ascending
            ..episodesPerPage = episodesPerPage,
          from: podcastEpisodesControllerProvider,
          name: r'podcastEpisodesControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastEpisodesControllerHash,
          dependencies: PodcastEpisodesControllerFamily._dependencies,
          allTransitiveDependencies:
              PodcastEpisodesControllerFamily._allTransitiveDependencies,
          pid: pid,
          filterMode: filterMode,
          ascending: ascending,
          episodesPerPage: episodesPerPage,
        );

  PodcastEpisodesControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pid,
    required this.filterMode,
    required this.ascending,
    required this.episodesPerPage,
  }) : super.internal();

  final int pid;
  final EpisodeFilterMode filterMode;
  final bool ascending;
  final int episodesPerPage;

  @override
  FutureOr<EpisodeListState> runNotifierBuild(
    covariant PodcastEpisodesController notifier,
  ) {
    return notifier.build(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      episodesPerPage: episodesPerPage,
    );
  }

  @override
  Override overrideWith(PodcastEpisodesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastEpisodesControllerProvider._internal(
        () => create()
          ..pid = pid
          ..filterMode = filterMode
          ..ascending = ascending
          ..episodesPerPage = episodesPerPage,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pid: pid,
        filterMode: filterMode,
        ascending: ascending,
        episodesPerPage: episodesPerPage,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastEpisodesController,
      EpisodeListState> createElement() {
    return _PodcastEpisodesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastEpisodesControllerProvider &&
        other.pid == pid &&
        other.filterMode == filterMode &&
        other.ascending == ascending &&
        other.episodesPerPage == episodesPerPage;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);
    hash = _SystemHash.combine(hash, filterMode.hashCode);
    hash = _SystemHash.combine(hash, ascending.hashCode);
    hash = _SystemHash.combine(hash, episodesPerPage.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastEpisodesControllerRef
    on AutoDisposeAsyncNotifierProviderRef<EpisodeListState> {
  /// The parameter `pid` of this provider.
  int get pid;

  /// The parameter `filterMode` of this provider.
  EpisodeFilterMode get filterMode;

  /// The parameter `ascending` of this provider.
  bool get ascending;

  /// The parameter `episodesPerPage` of this provider.
  int get episodesPerPage;
}

class _PodcastEpisodesControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastEpisodesController,
        EpisodeListState> with PodcastEpisodesControllerRef {
  _PodcastEpisodesControllerProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastEpisodesControllerProvider).pid;
  @override
  EpisodeFilterMode get filterMode =>
      (origin as PodcastEpisodesControllerProvider).filterMode;
  @override
  bool get ascending => (origin as PodcastEpisodesControllerProvider).ascending;
  @override
  int get episodesPerPage =>
      (origin as PodcastEpisodesControllerProvider).episodesPerPage;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
