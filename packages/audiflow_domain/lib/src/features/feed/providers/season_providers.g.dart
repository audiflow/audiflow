// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the season resolver service with built-in resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to year-based
/// grouping. Custom patterns can be added for specific podcasts.

@ProviderFor(seasonResolverService)
final seasonResolverServiceProvider = SeasonResolverServiceProvider._();

/// Provides the season resolver service with built-in resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to year-based
/// grouping. Custom patterns can be added for specific podcasts.

final class SeasonResolverServiceProvider
    extends
        $FunctionalProvider<
          SeasonResolverService,
          SeasonResolverService,
          SeasonResolverService
        >
    with $Provider<SeasonResolverService> {
  /// Provides the season resolver service with built-in resolvers.
  ///
  /// The resolver chain tries RSS metadata first, then falls back to year-based
  /// grouping. Custom patterns can be added for specific podcasts.
  SeasonResolverServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seasonResolverServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonResolverServiceHash();

  @$internal
  @override
  $ProviderElement<SeasonResolverService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SeasonResolverService create(Ref ref) {
    return seasonResolverService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeasonResolverService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeasonResolverService>(value),
    );
  }
}

String _$seasonResolverServiceHash() =>
    r'10c1a611251c37b47e781b8fc724eab0f47ce812';

/// Resolves seasons for a podcast by its ID.
///
/// Returns null if no resolver can group the episodes.

@ProviderFor(podcastSeasons)
final podcastSeasonsProvider = PodcastSeasonsFamily._();

/// Resolves seasons for a podcast by its ID.
///
/// Returns null if no resolver can group the episodes.

final class PodcastSeasonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeasonGrouping?>,
          SeasonGrouping?,
          FutureOr<SeasonGrouping?>
        >
    with $FutureModifier<SeasonGrouping?>, $FutureProvider<SeasonGrouping?> {
  /// Resolves seasons for a podcast by its ID.
  ///
  /// Returns null if no resolver can group the episodes.
  PodcastSeasonsProvider._({
    required PodcastSeasonsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastSeasonsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastSeasonsHash();

  @override
  String toString() {
    return r'podcastSeasonsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SeasonGrouping?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeasonGrouping?> create(Ref ref) {
    final argument = this.argument as int;
    return podcastSeasons(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSeasonsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastSeasonsHash() => r'5a78c6badd109abec18099856910f89c1dcd727a';

/// Resolves seasons for a podcast by its ID.
///
/// Returns null if no resolver can group the episodes.

final class PodcastSeasonsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SeasonGrouping?>, int> {
  PodcastSeasonsFamily._()
    : super(
        retry: null,
        name: r'podcastSeasonsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves seasons for a podcast by its ID.
  ///
  /// Returns null if no resolver can group the episodes.

  PodcastSeasonsProvider call(int podcastId) =>
      PodcastSeasonsProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'podcastSeasonsProvider';
}

/// Whether the season view toggle should be visible for a podcast.

@ProviderFor(hasSeasonView)
final hasSeasonViewProvider = HasSeasonViewFamily._();

/// Whether the season view toggle should be visible for a podcast.

final class HasSeasonViewProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the season view toggle should be visible for a podcast.
  HasSeasonViewProvider._({
    required HasSeasonViewFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'hasSeasonViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasSeasonViewHash();

  @override
  String toString() {
    return r'hasSeasonViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return hasSeasonView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasSeasonViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasSeasonViewHash() => r'ad8f5e501617d0a2803790609d4f06ec1a62f5f0';

/// Whether the season view toggle should be visible for a podcast.

final class HasSeasonViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  HasSeasonViewFamily._()
    : super(
        retry: null,
        name: r'hasSeasonViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the season view toggle should be visible for a podcast.

  HasSeasonViewProvider call(int podcastId) =>
      HasSeasonViewProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'hasSeasonViewProvider';
}

/// Whether the season view toggle should be visible for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
/// Returns false if the podcast is not subscribed.

@ProviderFor(hasSeasonViewByFeedUrl)
final hasSeasonViewByFeedUrlProvider = HasSeasonViewByFeedUrlFamily._();

/// Whether the season view toggle should be visible for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
/// Returns false if the podcast is not subscribed.

final class HasSeasonViewByFeedUrlProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the season view toggle should be visible for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
  /// Returns false if the podcast is not subscribed.
  HasSeasonViewByFeedUrlProvider._({
    required HasSeasonViewByFeedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasSeasonViewByFeedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasSeasonViewByFeedUrlHash();

  @override
  String toString() {
    return r'hasSeasonViewByFeedUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return hasSeasonViewByFeedUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasSeasonViewByFeedUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasSeasonViewByFeedUrlHash() =>
    r'1482ce849bfd0abce89dff0ad2931c0106c1b563';

/// Whether the season view toggle should be visible for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
/// Returns false if the podcast is not subscribed.

final class HasSeasonViewByFeedUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  HasSeasonViewByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'hasSeasonViewByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the season view toggle should be visible for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
  /// Returns false if the podcast is not subscribed.

  HasSeasonViewByFeedUrlProvider call(String feedUrl) =>
      HasSeasonViewByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'hasSeasonViewByFeedUrlProvider';
}

/// Provides the season grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
/// episodes can be grouped into seasons. Returns null if the podcast is not
/// subscribed or if no resolver can group the episodes.

@ProviderFor(podcastSeasonsByFeedUrl)
final podcastSeasonsByFeedUrlProvider = PodcastSeasonsByFeedUrlFamily._();

/// Provides the season grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
/// episodes can be grouped into seasons. Returns null if the podcast is not
/// subscribed or if no resolver can group the episodes.

final class PodcastSeasonsByFeedUrlProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeasonGrouping?>,
          SeasonGrouping?,
          FutureOr<SeasonGrouping?>
        >
    with $FutureModifier<SeasonGrouping?>, $FutureProvider<SeasonGrouping?> {
  /// Provides the season grouping for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
  /// episodes can be grouped into seasons. Returns null if the podcast is not
  /// subscribed or if no resolver can group the episodes.
  PodcastSeasonsByFeedUrlProvider._({
    required PodcastSeasonsByFeedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastSeasonsByFeedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastSeasonsByFeedUrlHash();

  @override
  String toString() {
    return r'podcastSeasonsByFeedUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SeasonGrouping?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeasonGrouping?> create(Ref ref) {
    final argument = this.argument as String;
    return podcastSeasonsByFeedUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSeasonsByFeedUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastSeasonsByFeedUrlHash() =>
    r'923c1024ac254173f8a38c3be3f0d8c0a011b545';

/// Provides the season grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
/// episodes can be grouped into seasons. Returns null if the podcast is not
/// subscribed or if no resolver can group the episodes.

final class PodcastSeasonsByFeedUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SeasonGrouping?>, String> {
  PodcastSeasonsByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'podcastSeasonsByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the season grouping for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
  /// episodes can be grouped into seasons. Returns null if the podcast is not
  /// subscribed or if no resolver can group the episodes.

  PodcastSeasonsByFeedUrlProvider call(String feedUrl) =>
      PodcastSeasonsByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastSeasonsByFeedUrlProvider';
}

/// Fetches episodes for a season by their IDs with progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback to
/// publish date (newest first).

@ProviderFor(seasonEpisodes)
final seasonEpisodesProvider = SeasonEpisodesFamily._();

/// Fetches episodes for a season by their IDs with progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback to
/// publish date (newest first).

final class SeasonEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SeasonEpisodeData>>,
          List<SeasonEpisodeData>,
          FutureOr<List<SeasonEpisodeData>>
        >
    with
        $FutureModifier<List<SeasonEpisodeData>>,
        $FutureProvider<List<SeasonEpisodeData>> {
  /// Fetches episodes for a season by their IDs with progress data.
  ///
  /// Episodes are sorted by episode number (ascending) with fallback to
  /// publish date (newest first).
  SeasonEpisodesProvider._({
    required SeasonEpisodesFamily super.from,
    required List<int> super.argument,
  }) : super(
         retry: null,
         name: r'seasonEpisodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seasonEpisodesHash();

  @override
  String toString() {
    return r'seasonEpisodesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SeasonEpisodeData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SeasonEpisodeData>> create(Ref ref) {
    final argument = this.argument as List<int>;
    return seasonEpisodes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonEpisodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seasonEpisodesHash() => r'547248cf4fbdfe516ec5937947c7a9e77c88648e';

/// Fetches episodes for a season by their IDs with progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback to
/// publish date (newest first).

final class SeasonEpisodesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SeasonEpisodeData>>,
          List<int>
        > {
  SeasonEpisodesFamily._()
    : super(
        retry: null,
        name: r'seasonEpisodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches episodes for a season by their IDs with progress data.
  ///
  /// Episodes are sorted by episode number (ascending) with fallback to
  /// publish date (newest first).

  SeasonEpisodesProvider call(List<int> episodeIds) =>
      SeasonEpisodesProvider._(argument: episodeIds, from: this);

  @override
  String toString() => r'seasonEpisodesProvider';
}
