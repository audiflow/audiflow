// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the pattern summaries loaded from remote
/// root meta.json.
///
/// Initially empty; populated on startup after fetching
/// root meta.

@ProviderFor(PatternSummaries)
final patternSummariesProvider = PatternSummariesProvider._();

/// Provides the pattern summaries loaded from remote
/// root meta.json.
///
/// Initially empty; populated on startup after fetching
/// root meta.
final class PatternSummariesProvider
    extends $NotifierProvider<PatternSummaries, List<PatternSummary>> {
  /// Provides the pattern summaries loaded from remote
  /// root meta.json.
  ///
  /// Initially empty; populated on startup after fetching
  /// root meta.
  PatternSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patternSummariesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patternSummariesHash();

  @$internal
  @override
  PatternSummaries create() => PatternSummaries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PatternSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PatternSummary>>(value),
    );
  }
}

String _$patternSummariesHash() => r'ba07a69cefa7eefbb2ba617eb8ba402b8a45f4d0';

/// Provides the pattern summaries loaded from remote
/// root meta.json.
///
/// Initially empty; populated on startup after fetching
/// root meta.

abstract class _$PatternSummaries extends $Notifier<List<PatternSummary>> {
  List<PatternSummary> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PatternSummary>, List<PatternSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PatternSummary>, List<PatternSummary>>,
              List<PatternSummary>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides the smart playlist config repository.
///
/// Uses Dio for HTTP and path_provider for cache directory.

@ProviderFor(smartPlaylistConfigRepository)
final smartPlaylistConfigRepositoryProvider =
    SmartPlaylistConfigRepositoryProvider._();

/// Provides the smart playlist config repository.
///
/// Uses Dio for HTTP and path_provider for cache directory.

final class SmartPlaylistConfigRepositoryProvider
    extends
        $FunctionalProvider<
          SmartPlaylistConfigRepository,
          SmartPlaylistConfigRepository,
          SmartPlaylistConfigRepository
        >
    with $Provider<SmartPlaylistConfigRepository> {
  /// Provides the smart playlist config repository.
  ///
  /// Uses Dio for HTTP and path_provider for cache directory.
  SmartPlaylistConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartPlaylistConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<SmartPlaylistConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SmartPlaylistConfigRepository create(Ref ref) {
    return smartPlaylistConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartPlaylistConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartPlaylistConfigRepository>(
        value,
      ),
    );
  }
}

String _$smartPlaylistConfigRepositoryHash() =>
    r'41d5591c1fe62e328ad5f4b20d1dc4099d7859e4';

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
    r'26566b38297cf48f55a2deb23523031ed19296b6';

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// Patterns are loaded lazily via repository. The resolver
/// operates in auto-detect mode (empty patterns list).

@ProviderFor(smartPlaylistResolverService)
final smartPlaylistResolverServiceProvider =
    SmartPlaylistResolverServiceProvider._();

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// Patterns are loaded lazily via repository. The resolver
/// operates in auto-detect mode (empty patterns list).

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
  /// Patterns are loaded lazily via repository. The resolver
  /// operates in auto-detect mode (empty patterns list).
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
    r'36c8fa9e7ad47a210fef7ce59b61020a779f06da';

/// Finds and loads the smart playlist config for a feed URL.
///
/// Returns null if no pattern matches. Lazily fetches the
/// full config from remote/cache when a match is found.

@ProviderFor(smartPlaylistPatternByFeedUrl)
final smartPlaylistPatternByFeedUrlProvider =
    SmartPlaylistPatternByFeedUrlFamily._();

/// Finds and loads the smart playlist config for a feed URL.
///
/// Returns null if no pattern matches. Lazily fetches the
/// full config from remote/cache when a match is found.

final class SmartPlaylistPatternByFeedUrlProvider
    extends
        $FunctionalProvider<
          AsyncValue<SmartPlaylistPatternConfig?>,
          SmartPlaylistPatternConfig?,
          FutureOr<SmartPlaylistPatternConfig?>
        >
    with
        $FutureModifier<SmartPlaylistPatternConfig?>,
        $FutureProvider<SmartPlaylistPatternConfig?> {
  /// Finds and loads the smart playlist config for a feed URL.
  ///
  /// Returns null if no pattern matches. Lazily fetches the
  /// full config from remote/cache when a match is found.
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
  $FutureProviderElement<SmartPlaylistPatternConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SmartPlaylistPatternConfig?> create(Ref ref) {
    final argument = this.argument as String;
    return smartPlaylistPatternByFeedUrl(ref, argument);
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
    r'dc6c5c4e5a0f69e875de3d3c83e5c4956e6141d7';

/// Finds and loads the smart playlist config for a feed URL.
///
/// Returns null if no pattern matches. Lazily fetches the
/// full config from remote/cache when a match is found.

final class SmartPlaylistPatternByFeedUrlFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SmartPlaylistPatternConfig?>,
          String
        > {
  SmartPlaylistPatternByFeedUrlFamily._()
    : super(
        retry: null,
        name: r'smartPlaylistPatternByFeedUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Finds and loads the smart playlist config for a feed URL.
  ///
  /// Returns null if no pattern matches. Lazily fetches the
  /// full config from remote/cache when a match is found.

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
    r'376a1d548830962b8e47ae1d6b5e4e88f298d4bc';

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

/// Whether the smart playlist view toggle should be visible
/// for a podcast.

@ProviderFor(hasSmartPlaylistView)
final hasSmartPlaylistViewProvider = HasSmartPlaylistViewFamily._();

/// Whether the smart playlist view toggle should be visible
/// for a podcast.

final class HasSmartPlaylistViewProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the smart playlist view toggle should be visible
  /// for a podcast.
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

/// Whether the smart playlist view toggle should be visible
/// for a podcast.

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

  /// Whether the smart playlist view toggle should be visible
  /// for a podcast.

  HasSmartPlaylistViewProvider call(int podcastId) =>
      HasSmartPlaylistViewProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'hasSmartPlaylistViewProvider';
}

/// Whether the smart playlist view toggle should be visible
/// for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. All visited podcasts have a
/// subscription entry (real or cached).

@ProviderFor(hasSmartPlaylistViewByFeedUrl)
final hasSmartPlaylistViewByFeedUrlProvider =
    HasSmartPlaylistViewByFeedUrlFamily._();

/// Whether the smart playlist view toggle should be visible
/// for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. All visited podcasts have a
/// subscription entry (real or cached).

final class HasSmartPlaylistViewByFeedUrlProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the smart playlist view toggle should be visible
  /// for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to
  /// [hasSmartPlaylistView]. All visited podcasts have a
  /// subscription entry (real or cached).
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

/// Whether the smart playlist view toggle should be visible
/// for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. All visited podcasts have a
/// subscription entry (real or cached).

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

  /// Whether the smart playlist view toggle should be visible
  /// for a podcast by feed URL.
  ///
  /// Looks up the subscription by feedUrl and delegates to
  /// [hasSmartPlaylistView]. All visited podcasts have a
  /// subscription entry (real or cached).

  HasSmartPlaylistViewByFeedUrlProvider call(String feedUrl) =>
      HasSmartPlaylistViewByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'hasSmartPlaylistViewByFeedUrlProvider';
}

/// Provides the smart playlist grouping for a podcast by
/// feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into
/// smart playlists. All visited podcasts have a subscription
/// entry (real or cached).

@ProviderFor(podcastSmartPlaylistsByFeedUrl)
final podcastSmartPlaylistsByFeedUrlProvider =
    PodcastSmartPlaylistsByFeedUrlFamily._();

/// Provides the smart playlist grouping for a podcast by
/// feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into
/// smart playlists. All visited podcasts have a subscription
/// entry (real or cached).

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
  /// Provides the smart playlist grouping for a podcast by
  /// feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the
  /// [SmartPlaylistGrouping] if episodes can be grouped into
  /// smart playlists. All visited podcasts have a subscription
  /// entry (real or cached).
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

/// Provides the smart playlist grouping for a podcast by
/// feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into
/// smart playlists. All visited podcasts have a subscription
/// entry (real or cached).

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

  /// Provides the smart playlist grouping for a podcast by
  /// feed URL.
  ///
  /// Looks up the subscription by feedUrl and returns the
  /// [SmartPlaylistGrouping] if episodes can be grouped into
  /// smart playlists. All visited podcasts have a subscription
  /// entry (real or cached).

  PodcastSmartPlaylistsByFeedUrlProvider call(String feedUrl) =>
      PodcastSmartPlaylistsByFeedUrlProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastSmartPlaylistsByFeedUrlProvider';
}

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by publish date (oldest first).
/// Callers reverse the list for "newest first" display.

@ProviderFor(smartPlaylistEpisodes)
final smartPlaylistEpisodesProvider = SmartPlaylistEpisodesFamily._();

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by publish date (oldest first).
/// Callers reverse the list for "newest first" display.

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
  /// Episodes are sorted by publish date (oldest first).
  /// Callers reverse the list for "newest first" display.
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
    r'307b7b5cd474af559b96a7fd443ea755576313f6';

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by publish date (oldest first).
/// Callers reverse the list for "newest first" display.

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
  /// Episodes are sorted by publish date (oldest first).
  /// Callers reverse the list for "newest first" display.

  SmartPlaylistEpisodesProvider call(List<int> episodeIds) =>
      SmartPlaylistEpisodesProvider._(argument: episodeIds, from: this);

  @override
  String toString() => r'smartPlaylistEpisodesProvider';
}
