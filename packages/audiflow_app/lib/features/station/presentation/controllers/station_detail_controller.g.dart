// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stationById)
final stationByIdProvider = StationByIdFamily._();

final class StationByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Station?>, Station?, FutureOr<Station?>>
    with $FutureModifier<Station?>, $FutureProvider<Station?> {
  StationByIdProvider._({
    required StationByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'stationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationByIdHash();

  @override
  String toString() {
    return r'stationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Station?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Station?> create(Ref ref) {
    final argument = this.argument as int;
    return stationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationByIdHash() => r'5ba4d7b08a9104b369773fe5332b1b64bbae5a48';

final class StationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Station?>, int> {
  StationByIdFamily._()
    : super(
        retry: null,
        name: r'stationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationByIdProvider call(int stationId) =>
      StationByIdProvider._(argument: stationId, from: this);

  @override
  String toString() => r'stationByIdProvider';
}

@ProviderFor(stationEpisodes)
final stationEpisodesProvider = StationEpisodesFamily._();

final class StationEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StationEpisode>>,
          List<StationEpisode>,
          Stream<List<StationEpisode>>
        >
    with
        $FutureModifier<List<StationEpisode>>,
        $StreamProvider<List<StationEpisode>> {
  StationEpisodesProvider._({
    required StationEpisodesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'stationEpisodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationEpisodesHash();

  @override
  String toString() {
    return r'stationEpisodesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StationEpisode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StationEpisode>> create(Ref ref) {
    final argument = this.argument as int;
    return stationEpisodes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationEpisodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationEpisodesHash() => r'295b052207d617a6a2a6973cf64c62fe6c57b864';

final class StationEpisodesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StationEpisode>>, int> {
  StationEpisodesFamily._()
    : super(
        retry: null,
        name: r'stationEpisodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationEpisodesProvider call(int stationId) =>
      StationEpisodesProvider._(argument: stationId, from: this);

  @override
  String toString() => r'stationEpisodesProvider';
}

@ProviderFor(stationPodcasts)
final stationPodcastsProvider = StationPodcastsFamily._();

final class StationPodcastsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StationPodcast>>,
          List<StationPodcast>,
          Stream<List<StationPodcast>>
        >
    with
        $FutureModifier<List<StationPodcast>>,
        $StreamProvider<List<StationPodcast>> {
  StationPodcastsProvider._({
    required StationPodcastsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'stationPodcastsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationPodcastsHash();

  @override
  String toString() {
    return r'stationPodcastsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StationPodcast>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StationPodcast>> create(Ref ref) {
    final argument = this.argument as int;
    return stationPodcasts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StationPodcastsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationPodcastsHash() => r'c88186594436c94e17169a455858aa88300c783f';

final class StationPodcastsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StationPodcast>>, int> {
  StationPodcastsFamily._()
    : super(
        retry: null,
        name: r'stationPodcastsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationPodcastsProvider call(int stationId) =>
      StationPodcastsProvider._(argument: stationId, from: this);

  @override
  String toString() => r'stationPodcastsProvider';
}

@ProviderFor(episodeById)
final episodeByIdProvider = EpisodeByIdFamily._();

final class EpisodeByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Episode?>, Episode?, FutureOr<Episode?>>
    with $FutureModifier<Episode?>, $FutureProvider<Episode?> {
  EpisodeByIdProvider._({
    required EpisodeByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'episodeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeByIdHash();

  @override
  String toString() {
    return r'episodeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Episode?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Episode?> create(Ref ref) {
    final argument = this.argument as int;
    return episodeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeByIdHash() => r'913f7253ee5a8ff2508f058934d3cd75aa6a8c6c';

final class EpisodeByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Episode?>, int> {
  EpisodeByIdFamily._()
    : super(
        retry: null,
        name: r'episodeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodeByIdProvider call(int episodeId) =>
      EpisodeByIdProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'episodeByIdProvider';
}
