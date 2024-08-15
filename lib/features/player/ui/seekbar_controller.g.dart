// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seekbar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioSeekbarControllerHash() =>
    r'ec5200c3bcb55b258962b7f1eb46587bcd6fad04';

/// See also [AudioSeekbarController].
@ProviderFor(AudioSeekbarController)
final audioSeekbarControllerProvider =
    AutoDisposeNotifierProvider<AudioSeekbarController, SeekbarState?>.internal(
  AudioSeekbarController.new,
  name: r'audioSeekbarControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioSeekbarControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AudioSeekbarController = AutoDisposeNotifier<SeekbarState?>;
String _$episodeSeekbarControllerHash() =>
    r'ebba99d5a760aa108350f6ceef16733a39a2d73c';

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

abstract class _$EpisodeSeekbarController
    extends BuildlessAutoDisposeNotifier<SeekbarState?> {
  late final Episode episode;

  SeekbarState? build(
    Episode episode,
  );
}

/// See also [EpisodeSeekbarController].
@ProviderFor(EpisodeSeekbarController)
const episodeSeekbarControllerProvider = EpisodeSeekbarControllerFamily();

/// See also [EpisodeSeekbarController].
class EpisodeSeekbarControllerFamily extends Family<SeekbarState?> {
  /// See also [EpisodeSeekbarController].
  const EpisodeSeekbarControllerFamily();

  /// See also [EpisodeSeekbarController].
  EpisodeSeekbarControllerProvider call(
    Episode episode,
  ) {
    return EpisodeSeekbarControllerProvider(
      episode,
    );
  }

  @override
  EpisodeSeekbarControllerProvider getProviderOverride(
    covariant EpisodeSeekbarControllerProvider provider,
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
  String? get name => r'episodeSeekbarControllerProvider';
}

/// See also [EpisodeSeekbarController].
class EpisodeSeekbarControllerProvider extends AutoDisposeNotifierProviderImpl<
    EpisodeSeekbarController, SeekbarState?> {
  /// See also [EpisodeSeekbarController].
  EpisodeSeekbarControllerProvider(
    Episode episode,
  ) : this._internal(
          () => EpisodeSeekbarController()..episode = episode,
          from: episodeSeekbarControllerProvider,
          name: r'episodeSeekbarControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$episodeSeekbarControllerHash,
          dependencies: EpisodeSeekbarControllerFamily._dependencies,
          allTransitiveDependencies:
              EpisodeSeekbarControllerFamily._allTransitiveDependencies,
          episode: episode,
        );

  EpisodeSeekbarControllerProvider._internal(
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
  SeekbarState? runNotifierBuild(
    covariant EpisodeSeekbarController notifier,
  ) {
    return notifier.build(
      episode,
    );
  }

  @override
  Override overrideWith(EpisodeSeekbarController Function() create) {
    return ProviderOverride(
      origin: this,
      override: EpisodeSeekbarControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<EpisodeSeekbarController, SeekbarState?>
      createElement() {
    return _EpisodeSeekbarControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeSeekbarControllerProvider &&
        other.episode == episode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, episode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EpisodeSeekbarControllerRef
    on AutoDisposeNotifierProviderRef<SeekbarState?> {
  /// The parameter `episode` of this provider.
  Episode get episode;
}

class _EpisodeSeekbarControllerProviderElement
    extends AutoDisposeNotifierProviderElement<EpisodeSeekbarController,
        SeekbarState?> with EpisodeSeekbarControllerRef {
  _EpisodeSeekbarControllerProviderElement(super.provider);

  @override
  Episode get episode => (origin as EpisodeSeekbarControllerProvider).episode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
