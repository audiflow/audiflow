// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the smart playlist local datasource for database
/// operations.

@ProviderFor(smartPlaylistLocalDatasource)
final smartPlaylistLocalDatasourceProvider =
    SmartPlaylistLocalDatasourceProvider._();

/// Provides the smart playlist local datasource for database
/// operations.

final class SmartPlaylistLocalDatasourceProvider
    extends
        $FunctionalProvider<
          SmartPlaylistLocalDatasource,
          SmartPlaylistLocalDatasource,
          SmartPlaylistLocalDatasource
        >
    with $Provider<SmartPlaylistLocalDatasource> {
  /// Provides the smart playlist local datasource for database
  /// operations.
  SmartPlaylistLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartPlaylistLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<SmartPlaylistLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SmartPlaylistLocalDatasource create(Ref ref) {
    return smartPlaylistLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartPlaylistLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartPlaylistLocalDatasource>(value),
    );
  }
}

String _$smartPlaylistLocalDatasourceHash() =>
    r'c117de0a934a4a2311293f89f233c486d9eecfec';

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to
/// year-based grouping. Custom patterns can be added for specific
/// podcasts.

@ProviderFor(smartPlaylistResolverService)
final smartPlaylistResolverServiceProvider =
    SmartPlaylistResolverServiceProvider._();

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to
/// year-based grouping. Custom patterns can be added for specific
/// podcasts.

final class SmartPlaylistResolverServiceProvider
    extends
        $FunctionalProvider<
          SmartPlaylistResolverService,
          SmartPlaylistResolverService,
          SmartPlaylistResolverService
        >
    with $Provider<SmartPlaylistResolverService> {
  /// Provides the smart playlist resolver service with built-in
  /// resolvers.
  ///
  /// The resolver chain tries RSS metadata first, then falls back to
  /// year-based grouping. Custom patterns can be added for specific
  /// podcasts.
  SmartPlaylistResolverServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartPlaylistResolverServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistResolverServiceHash();

  @$internal
  @override
  $ProviderElement<SmartPlaylistResolverService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SmartPlaylistResolverService create(Ref ref) {
    return smartPlaylistResolverService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartPlaylistResolverService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartPlaylistResolverService>(value),
    );
  }
}

String _$smartPlaylistResolverServiceHash() =>
    r'1e7e2ec04bb55fc218386d22f2ef64bdd4df507a';

/// Finds the smart playlist pattern that matches a given feed URL.
///
/// Returns null if no pattern matches.

@ProviderFor(smartPlaylistPatternByFeedUrl)
final smartPlaylistPatternByFeedUrlProvider =
    SmartPlaylistPatternByFeedUrlFamily._();

/// Finds the smart playlist pattern that matches a given feed URL.
///
/// Returns null if no pattern matches.

final class SmartPlaylistPatternByFeedUrlProvider
    extends
        $FunctionalProvider<
          SmartPlaylistPattern?,
          SmartPlaylistPattern?,
          SmartPlaylistPattern?
        >
    with $Provider<SmartPlaylistPattern?> {
  /// Finds the smart playlist pattern that matches a given feed URL.
  ///
  /// Returns null if no pattern matches.
  SmartPlaylistPatternByFeedUrlProvider._({
    required SmartPlaylistPatternByFeedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'smartPlaylistPatternByFeedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistPatternByFeedUrlHash();

  @override
  String toString() {
    return r'smartPlaylistPatternByFeedUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SmartPlaylistPattern?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SmartPlaylistPattern? create(Ref ref) {
    final argument = this.argument as String;
    return smartPlaylistPatternByFeedUrl(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartPlaylistPattern? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartPlaylistPattern?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SmartPlaylistPatternByFeedUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$smartPlaylistPatternByFeedUrlHash() =>
    r'a6c9b0e744abed871277026ebb1b1a5f6101c926';

/// Finds the smart playlist pattern that matches a given feed URL.
///
/// Returns null if no pattern matches.

final class SmartPlaylistPatternByFeedUrlFamily extends $Family
    with $FunctionalFamilyOverride<SmartPlaylistPattern?, String> {
  SmartPlaylistPatternByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'smartPlaylistPatternByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Finds the smart playlist pattern that matches a given feed URL.
  ///
  /// Returns null if no pattern matches.

  SmartPlaylistPatternByFeedUrlProvider call(String feedUrl) =>
      SmartPlaylistPatternByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'smartPlaylistPatternByFeedUrlProvider';
}

/// Resolves smart playlists for a podcast by its ID.
///
/// First checks the database for cached smart playlists. Only
/// resolves from episodes if no cached playlists exist. Returns
/// null if no resolver can group episodes.

@ProviderFor(podcastSmartPlaylists)
final podcastSmartPlaylistsProvider = PodcastSmartPlaylistsFamily._();

/// Resolves smart playlists for a podcast by its ID.
///
/// First checks the database for cached smart playlists. Only
/// resolves from episodes if no cached playlists exist. Returns
/// null if no resolver can group episodes.

final class PodcastSmartPlaylistsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SmartPlaylistGrouping?>,
          SmartPlaylistGrouping?,
          FutureOr<SmartPlaylistGrouping?>
        >
    with
        $FutureModifier<SmartPlaylistGrouping?>,
        $FutureProvider<SmartPlaylistGrouping?> {
  /// Resolves smart playlists for a podcast by its ID.
  ///
  /// First checks the database for cached smart playlists. Only
  /// resolves from episodes if no cached playlists exist. Returns
  /// null if no resolver can group episodes.
  PodcastSmartPlaylistsProvider._({
    required PodcastSmartPlaylistsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastSmartPlaylistsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastSmartPlaylistsHash();

  @override
  String toString() {
    return r'podcastSmartPlaylistsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SmartPlaylistGrouping?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SmartPlaylistGrouping?> create(Ref ref) {
    final argument = this.argument as int;
    return podcastSmartPlaylists(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSmartPlaylistsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastSmartPlaylistsHash() =>
    r'b7d528058b3f394ed6145d508a53945cdf4b75e4';

/// Resolves smart playlists for a podcast by its ID.
///
/// First checks the database for cached smart playlists. Only
/// resolves from episodes if no cached playlists exist. Returns
/// null if no resolver can group episodes.

final class PodcastSmartPlaylistsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SmartPlaylistGrouping?>, int> {
  PodcastSmartPlaylistsFamily._()
    : super(
        retry: null,
        name: r'podcastSmartPlaylistsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves smart playlists for a podcast by its ID.
  ///
  /// First checks the database for cached smart playlists. Only
  /// resolves from episodes if no cached playlists exist. Returns
  /// null if no resolver can group episodes.

  PodcastSmartPlaylistsProvider call(int podcastId) =>
      PodcastSmartPlaylistsProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'podcastSmartPlaylistsProvider';
}

/// Whether the smart playlist view toggle should be visible for a
/// podcast.

@ProviderFor(hasSmartPlaylistView)
final hasSmartPlaylistViewProvider = HasSmartPlaylistViewFamily._();

/// Whether the smart playlist view toggle should be visible for a
/// podcast.

final class HasSmartPlaylistViewProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the smart playlist view toggle should be visible for a
  /// podcast.
  HasSmartPlaylistViewProvider._({
    required HasSmartPlaylistViewFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'hasSmartPlaylistViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasSmartPlaylistViewHash();

  @override
  String toString() {
    return r'hasSmartPlaylistViewProvider'
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
    return hasSmartPlaylistView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasSmartPlaylistViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasSmartPlaylistViewHash() =>
    r'3620e859b235439c652fc679cc4d0cd66bf524c7';

/// Whether the smart playlist view toggle should be visible for a
/// podcast.

final class HasSmartPlaylistViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  HasSmartPlaylistViewFamily._()
    : super(
        retry: null,
        name: r'hasSmartPlaylistViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the smart playlist view toggle should be visible for a
  /// podcast.

  HasSmartPlaylistViewProvider call(int podcastId) =>
      HasSmartPlaylistViewProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'hasSmartPlaylistViewProvider';
}

/// Whether the smart playlist view toggle should be visible for a
/// podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. Returns false if the podcast is not
/// subscribed.

@ProviderFor(hasSmartPlaylistViewByFeedUrl)
final hasSmartPlaylistViewByFeedUrlProvider =
    HasSmartPlaylistViewByFeedUrlFamily._();

/// Whether the smart playlist view toggle should be visible for a
/// podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. Returns false if the podcast is not
/// subscribed.

final class HasSmartPlaylistViewByFeedUrlProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the smart playlist view toggle should be visible for a
  /// podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to
  /// [hasSmartPlaylistView]. Returns false if the podcast is not
  /// subscribed.
  HasSmartPlaylistViewByFeedUrlProvider._({
    required HasSmartPlaylistViewByFeedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasSmartPlaylistViewByFeedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasSmartPlaylistViewByFeedUrlHash();

  @override
  String toString() {
    return r'hasSmartPlaylistViewByFeedUrlProvider'
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
    return hasSmartPlaylistViewByFeedUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasSmartPlaylistViewByFeedUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasSmartPlaylistViewByFeedUrlHash() =>
    r'a84d0ff08d905993a40556a5bb9cdb1bc876fabd';

/// Whether the smart playlist view toggle should be visible for a
/// podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. Returns false if the podcast is not
/// subscribed.

final class HasSmartPlaylistViewByFeedUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  HasSmartPlaylistViewByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'hasSmartPlaylistViewByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the smart playlist view toggle should be visible for a
  /// podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to
  /// [hasSmartPlaylistView]. Returns false if the podcast is not
  /// subscribed.

  HasSmartPlaylistViewByFeedUrlProvider call(String feedUrl) =>
      HasSmartPlaylistViewByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'hasSmartPlaylistViewByFeedUrlProvider';
}

/// Provides the smart playlist grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into smart
/// playlists. Returns null if the podcast is not subscribed or if
/// no resolver can group the episodes.

@ProviderFor(podcastSmartPlaylistsByFeedUrl)
final podcastSmartPlaylistsByFeedUrlProvider =
    PodcastSmartPlaylistsByFeedUrlFamily._();

/// Provides the smart playlist grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into smart
/// playlists. Returns null if the podcast is not subscribed or if
/// no resolver can group the episodes.

final class PodcastSmartPlaylistsByFeedUrlProvider
    extends
        $FunctionalProvider<
          AsyncValue<SmartPlaylistGrouping?>,
          SmartPlaylistGrouping?,
          FutureOr<SmartPlaylistGrouping?>
        >
    with
        $FutureModifier<SmartPlaylistGrouping?>,
        $FutureProvider<SmartPlaylistGrouping?> {
  /// Provides the smart playlist grouping for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the
  /// [SmartPlaylistGrouping] if episodes can be grouped into smart
  /// playlists. Returns null if the podcast is not subscribed or if
  /// no resolver can group the episodes.
  PodcastSmartPlaylistsByFeedUrlProvider._({
    required PodcastSmartPlaylistsByFeedUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastSmartPlaylistsByFeedUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastSmartPlaylistsByFeedUrlHash();

  @override
  String toString() {
    return r'podcastSmartPlaylistsByFeedUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SmartPlaylistGrouping?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SmartPlaylistGrouping?> create(Ref ref) {
    final argument = this.argument as String;
    return podcastSmartPlaylistsByFeedUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastSmartPlaylistsByFeedUrlProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastSmartPlaylistsByFeedUrlHash() =>
    r'c9f45da49411fda0af2d3fa4115fa5c8fa0b8d4d';

/// Provides the smart playlist grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into smart
/// playlists. Returns null if the podcast is not subscribed or if
/// no resolver can group the episodes.

final class PodcastSmartPlaylistsByFeedUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SmartPlaylistGrouping?>, String> {
  PodcastSmartPlaylistsByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'podcastSmartPlaylistsByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the smart playlist grouping for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the
  /// [SmartPlaylistGrouping] if episodes can be grouped into smart
  /// playlists. Returns null if the podcast is not subscribed or if
  /// no resolver can group the episodes.

  PodcastSmartPlaylistsByFeedUrlProvider call(String feedUrl) =>
      PodcastSmartPlaylistsByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastSmartPlaylistsByFeedUrlProvider';
}

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback
/// to publish date (newest first).

@ProviderFor(smartPlaylistEpisodes)
final smartPlaylistEpisodesProvider = SmartPlaylistEpisodesFamily._();

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback
/// to publish date (newest first).

final class SmartPlaylistEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SmartPlaylistEpisodeData>>,
          List<SmartPlaylistEpisodeData>,
          FutureOr<List<SmartPlaylistEpisodeData>>
        >
    with
        $FutureModifier<List<SmartPlaylistEpisodeData>>,
        $FutureProvider<List<SmartPlaylistEpisodeData>> {
  /// Fetches episodes for a smart playlist by their IDs with
  /// progress data.
  ///
  /// Episodes are sorted by episode number (ascending) with fallback
  /// to publish date (newest first).
  SmartPlaylistEpisodesProvider._({
    required SmartPlaylistEpisodesFamily super.from,
    required List<int> super.argument,
  }) : super(
         retry: null,
         name: r'smartPlaylistEpisodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistEpisodesHash();

  @override
  String toString() {
    return r'smartPlaylistEpisodesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SmartPlaylistEpisodeData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SmartPlaylistEpisodeData>> create(Ref ref) {
    final argument = this.argument as List<int>;
    return smartPlaylistEpisodes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SmartPlaylistEpisodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$smartPlaylistEpisodesHash() =>
    r'f661b45c1bf737dca9cde6a40c2bf2121f561f1d';

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback
/// to publish date (newest first).

final class SmartPlaylistEpisodesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SmartPlaylistEpisodeData>>,
          List<int>
        > {
  SmartPlaylistEpisodesFamily._()
    : super(
        retry: null,
        name: r'smartPlaylistEpisodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches episodes for a smart playlist by their IDs with
  /// progress data.
  ///
  /// Episodes are sorted by episode number (ascending) with fallback
  /// to publish date (newest first).

  SmartPlaylistEpisodesProvider call(List<int> episodeIds) =>
      SmartPlaylistEpisodesProvider._(argument: episodeIds, from: this);

  @override
  String toString() => r'smartPlaylistEpisodesProvider';
}
