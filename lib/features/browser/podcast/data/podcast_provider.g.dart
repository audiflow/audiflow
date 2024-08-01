// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastHash() => r'ada4af0ddfe9b005c8c3774fae33c0e43afd80e1';

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

/// See also [podcast].
@ProviderFor(podcast)
const podcastProvider = PodcastFamily();

/// See also [podcast].
class PodcastFamily extends Family<AsyncValue<Podcast?>> {
  /// See also [podcast].
  const PodcastFamily();

  /// See also [podcast].
  PodcastProvider call(
    int pid,
  ) {
    return PodcastProvider(
      pid,
    );
  }

  @override
  PodcastProvider getProviderOverride(
    covariant PodcastProvider provider,
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
  String? get name => r'podcastProvider';
}

/// See also [podcast].
class PodcastProvider extends AutoDisposeFutureProvider<Podcast?> {
  /// See also [podcast].
  PodcastProvider(
    int pid,
  ) : this._internal(
          (ref) => podcast(
            ref as PodcastRef,
            pid,
          ),
          from: podcastProvider,
          name: r'podcastProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastHash,
          dependencies: PodcastFamily._dependencies,
          allTransitiveDependencies: PodcastFamily._allTransitiveDependencies,
          pid: pid,
        );

  PodcastProvider._internal(
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
    FutureOr<Podcast?> Function(PodcastRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PodcastProvider._internal(
        (ref) => create(ref as PodcastRef),
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
  AutoDisposeFutureProviderElement<Podcast?> createElement() {
    return _PodcastProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastProvider && other.pid == pid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastRef on AutoDisposeFutureProviderRef<Podcast?> {
  /// The parameter `pid` of this provider.
  int get pid;
}

class _PodcastProviderElement extends AutoDisposeFutureProviderElement<Podcast?>
    with PodcastRef {
  _PodcastProviderElement(super.provider);

  @override
  int get pid => (origin as PodcastProvider).pid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
