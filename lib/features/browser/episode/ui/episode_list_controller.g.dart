// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodeListControllerHash() =>
    r'e39607f66718eb3845b2f295edebcddd6dff9d54';

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

abstract class _$EpisodeListController
    extends BuildlessAutoDisposeAsyncNotifier<EpisodeListState> {
  late final int pid;
  late final EpisodeFilterMode filterMode;
  late final bool ascending;
  late final int episodesPerPage;

  FutureOr<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
  });
}

/// See also [EpisodeListController].
@ProviderFor(EpisodeListController)
const episodeListControllerProvider = EpisodeListControllerFamily();

/// See also [EpisodeListController].
class EpisodeListControllerFamily extends Family<AsyncValue<EpisodeListState>> {
  /// See also [EpisodeListController].
  const EpisodeListControllerFamily();

  /// See also [EpisodeListController].
  EpisodeListControllerProvider call({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
  }) {
    return EpisodeListControllerProvider(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      episodesPerPage: episodesPerPage,
    );
  }

  @override
  EpisodeListControllerProvider getProviderOverride(
    covariant EpisodeListControllerProvider provider,
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
  String? get name => r'episodeListControllerProvider';
}

/// See also [EpisodeListController].
class EpisodeListControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<EpisodeListController,
        EpisodeListState> {
  /// See also [EpisodeListController].
  EpisodeListControllerProvider({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
  }) : this._internal(
          () => EpisodeListController()
            ..pid = pid
            ..filterMode = filterMode
            ..ascending = ascending
            ..episodesPerPage = episodesPerPage,
          from: episodeListControllerProvider,
          name: r'episodeListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeListControllerHash,
          dependencies: EpisodeListControllerFamily._dependencies,
          allTransitiveDependencies:
              EpisodeListControllerFamily._allTransitiveDependencies,
          pid: pid,
          filterMode: filterMode,
          ascending: ascending,
          episodesPerPage: episodesPerPage,
        );

  EpisodeListControllerProvider._internal(
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
    covariant EpisodeListController notifier,
  ) {
    return notifier.build(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      episodesPerPage: episodesPerPage,
    );
  }

  @override
  Override overrideWith(EpisodeListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: EpisodeListControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<EpisodeListController,
      EpisodeListState> createElement() {
    return _EpisodeListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeListControllerProvider &&
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

mixin EpisodeListControllerRef
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

class _EpisodeListControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EpisodeListController,
        EpisodeListState> with EpisodeListControllerRef {
  _EpisodeListControllerProviderElement(super.provider);

  @override
  int get pid => (origin as EpisodeListControllerProvider).pid;
  @override
  EpisodeFilterMode get filterMode =>
      (origin as EpisodeListControllerProvider).filterMode;
  @override
  bool get ascending => (origin as EpisodeListControllerProvider).ascending;
  @override
  int get episodesPerPage =>
      (origin as EpisodeListControllerProvider).episodesPerPage;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
