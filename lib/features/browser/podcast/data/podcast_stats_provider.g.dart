// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastStatsHash() => r'08c7f6ed18457b33cf8fb5b39b0f912981a933d0';

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

/// See also [podcastStats].
@ProviderFor(podcastStats)
const podcastStatsProvider = PodcastStatsFamily();

/// See also [podcastStats].
class PodcastStatsFamily extends Family<AsyncValue<PodcastStats?>> {
  /// See also [podcastStats].
  const PodcastStatsFamily();

  /// See also [podcastStats].
  PodcastStatsProvider call(
    int pid,
  ) {
    return PodcastStatsProvider(
      pid,
    );
  }

  @override
  PodcastStatsProvider getProviderOverride(
    covariant PodcastStatsProvider provider,
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
  String? get name => r'podcastStatsProvider';
}

/// See also [podcastStats].
class PodcastStatsProvider extends AutoDisposeFutureProvider<PodcastStats?> {
  /// See also [podcastStats].
  PodcastStatsProvider(
    int pid,
  ) : this._internal(
          (ref) => podcastStats(
            ref as PodcastStatsRef,
            pid,
          ),
          from: podcastStatsProvider,
          name: r'podcastStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastStatsHash,
          dependencies: PodcastStatsFamily._dependencies,
          allTransitiveDependencies:
              PodcastStatsFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastStatsProvider._internal(
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
  Override overrideWith(
    FutureOr<PodcastStats?> Function(PodcastStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PodcastStatsProvider._internal(
        (ref) => create(ref as PodcastStatsRef),
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
  AutoDisposeFutureProviderElement<PodcastStats?> createElement() {
    return _PodcastStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastStatsProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastStatsRef on AutoDisposeFutureProviderRef<PodcastStats?> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastStatsProviderElement
    extends AutoDisposeFutureProviderElement<PodcastStats?>
    with PodcastStatsRef {
  _PodcastStatsProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastStatsProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
