// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'podcast_intro_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastIntroHash() => r'd3360ecd8d97f4dff60095b5f62ee571a27e68d4';

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

abstract class _$PodcastIntro
    extends BuildlessAutoDisposeAsyncNotifier<PodcastIntroState> {
  late final int collectionId;

  FutureOr<PodcastIntroState> build({
    required int collectionId,
  });
}

/// See also [PodcastIntro].
@ProviderFor(PodcastIntro)
const podcastIntroProvider = PodcastIntroFamily();

/// See also [PodcastIntro].
class PodcastIntroFamily extends Family<AsyncValue<PodcastIntroState>> {
  /// See also [PodcastIntro].
  const PodcastIntroFamily();

  /// See also [PodcastIntro].
  PodcastIntroProvider call({
    required int collectionId,
  }) {
    return PodcastIntroProvider(
      collectionId: collectionId,
    );
  }

  @override
  PodcastIntroProvider getProviderOverride(
    covariant PodcastIntroProvider provider,
  ) {
    return call(
      collectionId: provider.collectionId,
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
  String? get name => r'podcastIntroProvider';
}

/// See also [PodcastIntro].
class PodcastIntroProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PodcastIntro, PodcastIntroState> {
  /// See also [PodcastIntro].
  PodcastIntroProvider({
    required int collectionId,
  }) : this._internal(
          () => PodcastIntro()..collectionId = collectionId,
          from: podcastIntroProvider,
          name: r'podcastIntroProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastIntroHash,
          dependencies: PodcastIntroFamily._dependencies,
          allTransitiveDependencies:
              PodcastIntroFamily._allTransitiveDependencies,
          collectionId: collectionId,
        );

  PodcastIntroProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionId,
  }) : super.internal();

  final int collectionId;

  @override
  FutureOr<PodcastIntroState> runNotifierBuild(
    covariant PodcastIntro notifier,
  ) {
    return notifier.build(
      collectionId: collectionId,
    );
  }

  @override
  Override overrideWith(PodcastIntro Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastIntroProvider._internal(
        () => create()..collectionId = collectionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionId: collectionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PodcastIntro, PodcastIntroState>
      createElement() {
    return _PodcastIntroProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastIntroProvider && other.collectionId == collectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastIntroRef
    on AutoDisposeAsyncNotifierProviderRef<PodcastIntroState> {
  /// The parameter `collectionId` of this provider.
  int get collectionId;
}

class _PodcastIntroProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PodcastIntro,
        PodcastIntroState> with PodcastIntroRef {
  _PodcastIntroProviderElement(super.provider);

  @override
  int get collectionId => (origin as PodcastIntroProvider).collectionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
