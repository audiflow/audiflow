// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastViewInfoHash() => r'5248ee3c204913dd9db6526311c9d10cc1017d56';

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
  late final int pid;

  FutureOr<PodcastViewStats> build(
    int pid,
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
    int pid,
  ) {
    return PodcastViewInfoProvider(
      pid,
    );
  }

  @override
  PodcastViewInfoProvider getProviderOverride(
    covariant PodcastViewInfoProvider provider,
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
  String? get name => r'podcastViewInfoProvider';
}

/// See also [PodcastViewInfo].
class PodcastViewInfoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastViewInfo, PodcastViewStats> {
  /// See also [PodcastViewInfo].
  PodcastViewInfoProvider(
    int pid,
  ) : this._internal(
          () => PodcastViewInfo()..pid = pid,
          from: podcastViewInfoProvider,
          name: r'podcastViewInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastViewInfoHash,
          dependencies: PodcastViewInfoFamily._dependencies,
          allTransitiveDependencies:
              PodcastViewInfoFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastViewInfoProvider._internal(
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
    covariant PodcastViewInfo notifier,
  ) {
    return notifier.build(
      pid,
    );
  }

  @override
  Override overrideWith(PodcastViewInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastViewInfoProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo, PodcastViewStats>
      createElement() {
    return _PodcastViewInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewInfoProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastViewInfoRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastViewStats> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastViewInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastViewInfo,
        PodcastViewStats> with PodcastViewInfoRef {
  _PodcastViewInfoProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastViewInfoProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
