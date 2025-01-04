// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadableHash() => r'7d6a335b38880416f1e42b8fe761516d46f4f916';

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

/// See also [downloadable].
@ProviderFor(downloadable)
const downloadableProvider = DownloadableFamily();

/// See also [downloadable].
class DownloadableFamily extends Family<Downloadable?> {
  /// See also [downloadable].
  const DownloadableFamily();

  /// See also [downloadable].
  DownloadableProvider call(
    Episode episode,
  ) {
    return DownloadableProvider(
      episode,
    );
  }

  @override
  DownloadableProvider getProviderOverride(
    covariant DownloadableProvider provider,
  ) {
    return call(
      provider.episode,
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
  String? get name => r'downloadableProvider';
}

/// See also [downloadable].
class DownloadableProvider extends AutoDisposeProvider<Downloadable?> {
  /// See also [downloadable].
  DownloadableProvider(
    Episode episode,
  ) : this._internal(
          (ref) => downloadable(
            ref as DownloadableRef,
            episode,
          ),
          from: downloadableProvider,
          name: r'downloadableProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$downloadableHash,
          dependencies: DownloadableFamily._dependencies,
          allTransitiveDependencies:
              DownloadableFamily._allTransitiveDependencies,
          episode: episode,
        );

  DownloadableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.episode,
  }) : super.internal();

  final Episode episode;

  @override
  Override overrideWith(
    Downloadable? Function(DownloadableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DownloadableProvider._internal(
        (ref) => create(ref as DownloadableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        episode: episode,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Downloadable?> createElement() {
    return _DownloadableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadableProvider && other.episode == episode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, episode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DownloadableRef on AutoDisposeProviderRef<Downloadable?> {
  /// The parameter `episode` of this provider.
  Episode get episode;
}

class _DownloadableProviderElement
    extends AutoDisposeProviderElement<Downloadable?> with DownloadableRef {
  _DownloadableProviderElement(super.provider);

  @override
  Episode get episode => (origin as DownloadableProvider).episode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
