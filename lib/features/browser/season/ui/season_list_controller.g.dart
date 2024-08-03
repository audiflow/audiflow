// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seasonListControllerHash() =>
    r'38bf61b80fdee0f31337a744815e33b2797ac446';

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

abstract class _$SeasonListController
    extends BuildlessAutoDisposeNotifier<SeasonListState> {
  late final int pid;

  SeasonListState build(
    int pid,
  );
}

/// See also [SeasonListController].
@ProviderFor(SeasonListController)
const seasonListControllerProvider = SeasonListControllerFamily();

/// See also [SeasonListController].
class SeasonListControllerFamily extends Family<SeasonListState> {
  /// See also [SeasonListController].
  const SeasonListControllerFamily();

  /// See also [SeasonListController].
  SeasonListControllerProvider call(
    int pid,
  ) {
    return SeasonListControllerProvider(
      pid,
    );
  }

  @override
  SeasonListControllerProvider getProviderOverride(
    covariant SeasonListControllerProvider provider,
  ) {
    return call(
      provider.pid,
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
  String? get name => r'seasonListControllerProvider';
}

/// See also [SeasonListController].
class SeasonListControllerProvider extends AutoDisposeNotifierProviderImpl<
    SeasonListController, SeasonListState> {
  /// See also [SeasonListController].
  SeasonListControllerProvider(
    int pid,
  ) : this._internal(
          () => SeasonListController()..pid = pid,
          from: seasonListControllerProvider,
          name: r'seasonListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seasonListControllerHash,
          dependencies: SeasonListControllerFamily._dependencies,
          allTransitiveDependencies:
              SeasonListControllerFamily._allTransitiveDependencies,
          pid: pid,
        );

  SeasonListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pid,
  }) : super.internal();

  final int pid;

  @override
  SeasonListState runNotifierBuild(
    covariant SeasonListController notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(SeasonListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SeasonListControllerProvider._internal(
        () => create()..pid = pid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pid: pid,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SeasonListController, SeasonListState>
      createElement() {
    return _SeasonListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonListControllerProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SeasonListControllerRef
    on AutoDisposeNotifierProviderRef<SeasonListState> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _SeasonListControllerProviderElement
    extends AutoDisposeNotifierProviderElement<SeasonListController,
        SeasonListState> with SeasonListControllerRef {
  _SeasonListControllerProviderElement(super.provider);

  @override
  int get pid => (origin as SeasonListControllerProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
