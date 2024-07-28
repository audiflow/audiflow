// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_chart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastChartControllerHash() =>
    r'4d4354b54094d469b2b46ad544c14d0c8a11feb1';

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

abstract class _$PodcastChartController
    extends BuildlessAsyncNotifier<PodcastChartState> {
  late final String? genre;
  late final Country? country;
  late final int size;

  FutureOr<PodcastChartState> build({
    String? genre,
    Country? country,
    int size = 20,
  });
}

/// See also [PodcastChartController].
@ProviderFor(PodcastChartController)
const podcastChartControllerProvider = PodcastChartControllerFamily();

/// See also [PodcastChartController].
class PodcastChartControllerFamily
    extends Family<AsyncValue<PodcastChartState>> {
  /// See also [PodcastChartController].
  const PodcastChartControllerFamily();

  /// See also [PodcastChartController].
  PodcastChartControllerProvider call({
    String? genre,
    Country? country,
    int size = 20,
  }) {
    return PodcastChartControllerProvider(
      genre: genre,
      country: country,
      size: size,
    );
  }

  @override
  PodcastChartControllerProvider getProviderOverride(
    covariant PodcastChartControllerProvider provider,
  ) {
    return call(
      genre: provider.genre,
      country: provider.country,
      size: provider.size,
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
  String? get name => r'podcastChartControllerProvider';
}

/// See also [PodcastChartController].
class PodcastChartControllerProvider extends AsyncNotifierProviderImpl<
    PodcastChartController, PodcastChartState> {
  /// See also [PodcastChartController].
  PodcastChartControllerProvider({
    String? genre,
    Country? country,
    int size = 20,
  }) : this._internal(
          () => PodcastChartController()
            ..genre = genre
            ..country = country
            ..size = size,
          from: podcastChartControllerProvider,
          name: r'podcastChartControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$podcastChartControllerHash,
          dependencies: PodcastChartControllerFamily._dependencies,
          allTransitiveDependencies:
              PodcastChartControllerFamily._allTransitiveDependencies,
          genre: genre,
          country: country,
          size: size,
        );

  PodcastChartControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.genre,
    required this.country,
    required this.size,
  }) : super.internal();

  final String? genre;
  final Country? country;
  final int size;

  @override
  FutureOr<PodcastChartState> runNotifierBuild(
    covariant PodcastChartController notifier,
  ) {
    return notifier.build(
      genre: genre,
      country: country,
      size: size,
    );
  }

  @override
  Override overrideWith(PodcastChartController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PodcastChartControllerProvider._internal(
        () => create()
          ..genre = genre
          ..country = country
          ..size = size,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        genre: genre,
        country: country,
        size: size,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<PodcastChartController, PodcastChartState>
      createElement() {
    return _PodcastChartControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastChartControllerProvider &&
        other.genre == genre &&
        other.country == country &&
        other.size == size;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, genre.hashCode);
    hash = _SystemHash.combine(hash, country.hashCode);
    hash = _SystemHash.combine(hash, size.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PodcastChartControllerRef on AsyncNotifierProviderRef<PodcastChartState> {
  /// The parameter `genre` of this provider.
  String? get genre;

  /// The parameter `country` of this provider.
  Country? get country;

  /// The parameter `size` of this provider.
  int get size;
}

class _PodcastChartControllerProviderElement
    extends AsyncNotifierProviderElement<PodcastChartController,
        PodcastChartState> with PodcastChartControllerRef {
  _PodcastChartControllerProviderElement(super.provider);

  @override
  String? get genre => (origin as PodcastChartControllerProvider).genre;
  @override
  Country? get country => (origin as PodcastChartControllerProvider).country;
  @override
  int get size => (origin as PodcastChartControllerProvider).size;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
