// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'download_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadProgressHash() => r'3b3493bc3224c2646c82543e537088b984a94be5';

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

abstract class _$DownloadProgress
    extends BuildlessAutoDisposeAsyncNotifier<Downloadable?> {
  late final Episode episode;

  FutureOr<Downloadable?> build(
    Episode episode,
  );
}

/// See also [DownloadProgress].
@ProviderFor(DownloadProgress)
const downloadProgressProvider = DownloadProgressFamily();

/// See also [DownloadProgress].
class DownloadProgressFamily extends Family<AsyncValue<Downloadable?>> {
  /// See also [DownloadProgress].
  const DownloadProgressFamily();

  /// See also [DownloadProgress].
  DownloadProgressProvider call(
    Episode episode,
  ) {
    return DownloadProgressProvider(
      episode,
    );
  }

  @override
  DownloadProgressProvider getProviderOverride(
    covariant DownloadProgressProvider provider,
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
  String? get name => r'downloadProgressProvider';
}

/// See also [DownloadProgress].
class DownloadProgressProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DownloadProgress, Downloadable?> {
  /// See also [DownloadProgress].
  DownloadProgressProvider(
    Episode episode,
  ) : this._internal(
          () => DownloadProgress()..episode = episode,
          from: downloadProgressProvider,
          name: r'downloadProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$downloadProgressHash,
          dependencies: DownloadProgressFamily._dependencies,
          allTransitiveDependencies:
              DownloadProgressFamily._allTransitiveDependencies,
          episode: episode,
        );

  DownloadProgressProvider._internal(
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
  FutureOr<Downloadable?> runNotifierBuild(
    covariant DownloadProgress notifier,
  ) {
    return notifier.build(
      episode,
    );
  }

  @override
  Override overrideWith(DownloadProgress Function() create) {
    return ProviderOverride(
      origin: this,
      override: DownloadProgressProvider._internal(
        () => create()..episode = episode,
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
  AutoDisposeAsyncNotifierProviderElement<DownloadProgress, Downloadable?>
      createElement() {
    return _DownloadProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadProgressProvider && other.episode == episode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, episode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DownloadProgressRef
    on AutoDisposeAsyncNotifierProviderRef<Downloadable?> {
  /// The parameter `episode` of this provider.
  Episode get episode;
}

class _DownloadProgressProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DownloadProgress,
        Downloadable?> with DownloadProgressRef {
  _DownloadProgressProviderElement(super.provider);

  @override
  Episode get episode => (origin as DownloadProgressProvider).episode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
