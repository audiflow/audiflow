// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_details_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastDetailsPageControllerHash() =>
    r'5a55611c9e1fe07994367abde21871a17bf418a4';

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

abstract class _$PodcastDetailsPageController
    extends BuildlessAutoDisposeAsyncNotifier<PodcastDetailsPageState> {
  late final int pid;

  FutureOr<PodcastDetailsPageState> build(
    int pid,
  );
}

/// See also [PodcastDetailsPageController].
@ProviderFor(PodcastDetailsPageController)
const podcastDetailsPageControllerProvider =
    PodcastDetailsPageControllerFamily();

/// See also [PodcastDetailsPageController].
class PodcastDetailsPageControllerFamily
    extends Family<AsyncValue<PodcastDetailsPageState>> {
  /// See also [PodcastDetailsPageController].
  const PodcastDetailsPageControllerFamily();

  /// See also [PodcastDetailsPageController].
  PodcastDetailsPageControllerProvider call(
    int pid,
  ) {
    return PodcastDetailsPageControllerProvider(
      pid,
    );
  }

  @override
  PodcastDetailsPageControllerProvider getProviderOverride(
    covariant PodcastDetailsPageControllerProvider provider,
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
  String? get name => r'podcastDetailsPageControllerProvider';
}

/// See also [PodcastDetailsPageController].
class PodcastDetailsPageControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PodcastDetailsPageController,
        PodcastDetailsPageState> {
  /// See also [PodcastDetailsPageController].
  PodcastDetailsPageControllerProvider(
    int pid,
  ) : this._internal(
          () => PodcastDetailsPageController()..pid = pid,
          from: podcastDetailsPageControllerProvider,
          name: r'podcastDetailsPageControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastDetailsPageControllerHash,
          dependencies: PodcastDetailsPageControllerFamily._dependencies,
          allTransitiveDependencies:
              PodcastDetailsPageControllerFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastDetailsPageControllerProvider._internal(
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
  FutureOr<PodcastDetailsPageState> runNotifierBuild(
    covariant PodcastDetailsPageController notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(PodcastDetailsPageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastDetailsPageControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastDetailsPageController,
      PodcastDetailsPageState> createElement() {
    return _PodcastDetailsPageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailsPageControllerProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PodcastDetailsPageControllerRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastDetailsPageState> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastDetailsPageControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        PodcastDetailsPageController,
        PodcastDetailsPageState> with PodcastDetailsPageControllerRef {
  _PodcastDetailsPageControllerProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastDetailsPageControllerProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
