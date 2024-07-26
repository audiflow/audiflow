// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_info_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewInfoControllerHash() =>
    r'9e5a958e244bb2f5dd1da797f334b4ddd87d676c';

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

abstract class _$PodcastViewInfoController
    extends BuildlessAutoDisposeAsyncNotifier<PodcastViewStats> {
  late final int pid;

  FutureOr<PodcastViewStats> build(
    int pid,
  );
}

/// See also [PodcastViewInfoController].
@ProviderFor(PodcastViewInfoController)
const podcastViewInfoControllerProvider = PodcastViewInfoControllerFamily();

/// See also [PodcastViewInfoController].
class PodcastViewInfoControllerFamily
    extends Family<AsyncValue<PodcastViewStats>> {
  /// See also [PodcastViewInfoController].
  const PodcastViewInfoControllerFamily();

  /// See also [PodcastViewInfoController].
  PodcastViewInfoControllerProvider call(
    int pid,
  ) {
    return PodcastViewInfoControllerProvider(
      pid,
    );
  }

  @override
  PodcastViewInfoControllerProvider getProviderOverride(
    covariant PodcastViewInfoControllerProvider provider,
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
  String? get name => r'podcastViewInfoControllerProvider';
}

/// See also [PodcastViewInfoController].
class PodcastViewInfoControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastViewInfoController,
        PodcastViewStats> {
  /// See also [PodcastViewInfoController].
  PodcastViewInfoControllerProvider(
    int pid,
  ) : this._internal(
          () => PodcastViewInfoController()..pid = pid,
          from: podcastViewInfoControllerProvider,
          name: r'podcastViewInfoControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewInfoControllerHash,
          dependencies: PodcastViewInfoControllerFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewInfoControllerFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastViewInfoControllerProvider._internal(
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
  FutureOr<PodcastViewStats> runNotifierBuild(
    covariant PodcastViewInfoController notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(PodcastViewInfoController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewInfoControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastViewInfoController,
      PodcastViewStats> createElement() {
    return _PodcastViewInfoControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewInfoControllerProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewInfoControllerRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastViewStats> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastViewInfoControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewInfoController,
        PodcastViewStats> with PodcastViewInfoControllerRef {
  _PodcastViewInfoControllerProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastViewInfoControllerProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
