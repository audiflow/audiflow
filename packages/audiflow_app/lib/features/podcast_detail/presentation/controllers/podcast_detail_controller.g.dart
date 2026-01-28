// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for subscription repository access.
///
/// Re-exported from audiflow_domain for convenience.

@ProviderFor(subscriptionRepositoryAccess)
final subscriptionRepositoryAccessProvider =
    SubscriptionRepositoryAccessProvider._();

/// Provider for subscription repository access.
///
/// Re-exported from audiflow_domain for convenience.

final class SubscriptionRepositoryAccessProvider
    extends
        $FunctionalProvider<
          SubscriptionRepository,
          SubscriptionRepository,
          SubscriptionRepository
        >
    with $Provider<SubscriptionRepository> {
  /// Provider for subscription repository access.
  ///
  /// Re-exported from audiflow_domain for convenience.
  SubscriptionRepositoryAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionRepositoryAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionRepositoryAccessHash();

  @$internal
  @override
  $ProviderElement<SubscriptionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscriptionRepository create(Ref ref) {
    return subscriptionRepositoryAccess(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionRepository>(value),
    );
  }
}

String _$subscriptionRepositoryAccessHash() =>
    r'0323f4a4c4efb56babc23b13a320fa01eda9894b';

/// Provides a Dio client for RSS feed fetching.

@ProviderFor(feedHttpClient)
final feedHttpClientProvider = FeedHttpClientProvider._();

/// Provides a Dio client for RSS feed fetching.

final class FeedHttpClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides a Dio client for RSS feed fetching.
  FeedHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHttpClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return feedHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$feedHttpClientHash() => r'1f78c2cb06966ea95e535a2df41522826f3e0f46';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

@ProviderFor(podcastDetail)
final podcastDetailProvider = PodcastDetailFamily._();

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

final class PodcastDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParsedFeed>,
          ParsedFeed,
          FutureOr<ParsedFeed>
        >
    with $FutureModifier<ParsedFeed>, $FutureProvider<ParsedFeed> {
  /// Fetches and provides parsed podcast feed data for a given feed URL.
  ///
  /// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
  /// Returns [ParsedFeed] containing podcast metadata and episodes.
  /// Throws [PodcastException] if the feed cannot be fetched or parsed.
  PodcastDetailProvider._({
    required PodcastDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastDetailHash();

  @override
  String toString() {
    return r'podcastDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ParsedFeed> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ParsedFeed> create(Ref ref) {
    final argument = this.argument as String;
    return podcastDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastDetailHash() => r'692b4ad7e660d0ecd9d7878f16d6aa3c85388fb7';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

final class PodcastDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ParsedFeed>, String> {
  PodcastDetailFamily._()
    : super(
        retry: null,
        name: r'podcastDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches and provides parsed podcast feed data for a given feed URL.
  ///
  /// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
  /// Returns [ParsedFeed] containing podcast metadata and episodes.
  /// Throws [PodcastException] if the feed cannot be fetched or parsed.

  PodcastDetailProvider call(String feedUrl) =>
      PodcastDetailProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastDetailProvider';
}

/// Fetches episode progress for a given audio URL.
///
/// Returns [EpisodeWithProgress] if the episode exists in the database,
/// otherwise returns null (episode not yet persisted).

@ProviderFor(episodeProgress)
final episodeProgressProvider = EpisodeProgressFamily._();

/// Fetches episode progress for a given audio URL.
///
/// Returns [EpisodeWithProgress] if the episode exists in the database,
/// otherwise returns null (episode not yet persisted).

final class EpisodeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<EpisodeWithProgress?>,
          EpisodeWithProgress?,
          FutureOr<EpisodeWithProgress?>
        >
    with
        $FutureModifier<EpisodeWithProgress?>,
        $FutureProvider<EpisodeWithProgress?> {
  /// Fetches episode progress for a given audio URL.
  ///
  /// Returns [EpisodeWithProgress] if the episode exists in the database,
  /// otherwise returns null (episode not yet persisted).
  EpisodeProgressProvider._({
    required EpisodeProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'episodeProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeProgressHash();

  @override
  String toString() {
    return r'episodeProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EpisodeWithProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EpisodeWithProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return episodeProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeProgressHash() => r'8557c4ce7cfc930b819eb33d78461a3fbffd7ef8';

/// Fetches episode progress for a given audio URL.
///
/// Returns [EpisodeWithProgress] if the episode exists in the database,
/// otherwise returns null (episode not yet persisted).

final class EpisodeProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EpisodeWithProgress?>, String> {
  EpisodeProgressFamily._()
    : super(
        retry: null,
        name: r'episodeProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches episode progress for a given audio URL.
  ///
  /// Returns [EpisodeWithProgress] if the episode exists in the database,
  /// otherwise returns null (episode not yet persisted).

  EpisodeProgressProvider call(String audioUrl) =>
      EpisodeProgressProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'episodeProgressProvider';
}

/// Batch-fetches all episode progress for a podcast in a single query.
///
/// This is much more efficient than N individual episodeProgress queries
/// when displaying a list of episodes.

@ProviderFor(podcastEpisodeProgress)
final podcastEpisodeProgressProvider = PodcastEpisodeProgressFamily._();

/// Batch-fetches all episode progress for a podcast in a single query.
///
/// This is much more efficient than N individual episodeProgress queries
/// when displaying a list of episodes.

final class PodcastEpisodeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<EpisodeProgressMap>,
          EpisodeProgressMap,
          FutureOr<EpisodeProgressMap>
        >
    with
        $FutureModifier<EpisodeProgressMap>,
        $FutureProvider<EpisodeProgressMap> {
  /// Batch-fetches all episode progress for a podcast in a single query.
  ///
  /// This is much more efficient than N individual episodeProgress queries
  /// when displaying a list of episodes.
  PodcastEpisodeProgressProvider._({
    required PodcastEpisodeProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastEpisodeProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastEpisodeProgressHash();

  @override
  String toString() {
    return r'podcastEpisodeProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EpisodeProgressMap> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EpisodeProgressMap> create(Ref ref) {
    final argument = this.argument as String;
    return podcastEpisodeProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastEpisodeProgressProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastEpisodeProgressHash() =>
    r'8bbe628514cfdfc2ce4694ccb564084079f5913b';

/// Batch-fetches all episode progress for a podcast in a single query.
///
/// This is much more efficient than N individual episodeProgress queries
/// when displaying a list of episodes.

final class PodcastEpisodeProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EpisodeProgressMap>, String> {
  PodcastEpisodeProgressFamily._()
    : super(
        retry: null,
        name: r'podcastEpisodeProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Batch-fetches all episode progress for a podcast in a single query.
  ///
  /// This is much more efficient than N individual episodeProgress queries
  /// when displaying a list of episodes.

  PodcastEpisodeProgressProvider call(String feedUrl) =>
      PodcastEpisodeProgressProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastEpisodeProgressProvider';
}

/// Extracts only the current episode URL from playback state.
///
/// This allows tiles to watch ONLY the URL, preventing rebuilds when
/// other playback properties change (e.g., position updates).

@ProviderFor(currentPlayingEpisodeUrl)
final currentPlayingEpisodeUrlProvider = CurrentPlayingEpisodeUrlProvider._();

/// Extracts only the current episode URL from playback state.
///
/// This allows tiles to watch ONLY the URL, preventing rebuilds when
/// other playback properties change (e.g., position updates).

final class CurrentPlayingEpisodeUrlProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Extracts only the current episode URL from playback state.
  ///
  /// This allows tiles to watch ONLY the URL, preventing rebuilds when
  /// other playback properties change (e.g., position updates).
  CurrentPlayingEpisodeUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPlayingEpisodeUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPlayingEpisodeUrlHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentPlayingEpisodeUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentPlayingEpisodeUrlHash() =>
    r'1effa061b31513f97f0176272f294d4df7e7b596';

/// Returns true if the given URL is currently playing (not paused).

@ProviderFor(isEpisodePlaying)
final isEpisodePlayingProvider = IsEpisodePlayingFamily._();

/// Returns true if the given URL is currently playing (not paused).

final class IsEpisodePlayingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Returns true if the given URL is currently playing (not paused).
  IsEpisodePlayingProvider._({
    required IsEpisodePlayingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isEpisodePlayingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isEpisodePlayingHash();

  @override
  String toString() {
    return r'isEpisodePlayingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isEpisodePlaying(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsEpisodePlayingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isEpisodePlayingHash() => r'8368dd9571e306824e409441c7c489c2bc6c0351';

/// Returns true if the given URL is currently playing (not paused).

final class IsEpisodePlayingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsEpisodePlayingFamily._()
    : super(
        retry: null,
        name: r'isEpisodePlayingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns true if the given URL is currently playing (not paused).

  IsEpisodePlayingProvider call(String audioUrl) =>
      IsEpisodePlayingProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'isEpisodePlayingProvider';
}

/// Returns true if the given URL is currently loading.

@ProviderFor(isEpisodeLoading)
final isEpisodeLoadingProvider = IsEpisodeLoadingFamily._();

/// Returns true if the given URL is currently loading.

final class IsEpisodeLoadingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Returns true if the given URL is currently loading.
  IsEpisodeLoadingProvider._({
    required IsEpisodeLoadingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isEpisodeLoadingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isEpisodeLoadingHash();

  @override
  String toString() {
    return r'isEpisodeLoadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isEpisodeLoading(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsEpisodeLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isEpisodeLoadingHash() => r'8c2a8fe9aebb8f66a3b7b55b88b1633b36f174a7';

/// Returns true if the given URL is currently loading.

final class IsEpisodeLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsEpisodeLoadingFamily._()
    : super(
        retry: null,
        name: r'isEpisodeLoadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns true if the given URL is currently loading.

  IsEpisodeLoadingProvider call(String audioUrl) =>
      IsEpisodeLoadingProvider._(argument: audioUrl, from: this);

  @override
  String toString() => r'isEpisodeLoadingProvider';
}

/// Filters and sorts episodes based on preferences.
///
/// Returns filtered and sorted list of [PodcastItem].

@ProviderFor(filteredSortedEpisodes)
final filteredSortedEpisodesProvider = FilteredSortedEpisodesFamily._();

/// Filters and sorts episodes based on preferences.
///
/// Returns filtered and sorted list of [PodcastItem].

final class FilteredSortedEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PodcastItem>>,
          List<PodcastItem>,
          FutureOr<List<PodcastItem>>
        >
    with
        $FutureModifier<List<PodcastItem>>,
        $FutureProvider<List<PodcastItem>> {
  /// Filters and sorts episodes based on preferences.
  ///
  /// Returns filtered and sorted list of [PodcastItem].
  FilteredSortedEpisodesProvider._({
    required FilteredSortedEpisodesFamily super.from,
    required (String, EpisodeFilter, SortOrder) super.argument,
  }) : super(
         retry: null,
         name: r'filteredSortedEpisodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedEpisodesHash();

  @override
  String toString() {
    return r'filteredSortedEpisodesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PodcastItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PodcastItem>> create(Ref ref) {
    final argument = this.argument as (String, EpisodeFilter, SortOrder);
    return filteredSortedEpisodes(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredSortedEpisodesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredSortedEpisodesHash() =>
    r'33019570fab8427214176d76e73053fc5fb7459e';

/// Filters and sorts episodes based on preferences.
///
/// Returns filtered and sorted list of [PodcastItem].

final class FilteredSortedEpisodesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PodcastItem>>,
          (String, EpisodeFilter, SortOrder)
        > {
  FilteredSortedEpisodesFamily._()
    : super(
        retry: null,
        name: r'filteredSortedEpisodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filters and sorts episodes based on preferences.
  ///
  /// Returns filtered and sorted list of [PodcastItem].

  FilteredSortedEpisodesProvider call(
    String feedUrl,
    EpisodeFilter filter,
    SortOrder sortOrder,
  ) => FilteredSortedEpisodesProvider._(
    argument: (feedUrl, filter, sortOrder),
    from: this,
  );

  @override
  String toString() => r'filteredSortedEpisodesProvider';
}

/// Whether season view is available for a podcast.
///
/// Checks the parsed feed data directly for season numbers, so it works
/// for both subscribed and non-subscribed podcasts.

@ProviderFor(hasSeasonViewAfterLoad)
final hasSeasonViewAfterLoadProvider = HasSeasonViewAfterLoadFamily._();

/// Whether season view is available for a podcast.
///
/// Checks the parsed feed data directly for season numbers, so it works
/// for both subscribed and non-subscribed podcasts.

final class HasSeasonViewAfterLoadProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether season view is available for a podcast.
  ///
  /// Checks the parsed feed data directly for season numbers, so it works
  /// for both subscribed and non-subscribed podcasts.
  HasSeasonViewAfterLoadProvider._({
    required HasSeasonViewAfterLoadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasSeasonViewAfterLoadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasSeasonViewAfterLoadHash();

  @override
  String toString() {
    return r'hasSeasonViewAfterLoadProvider'
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
    return hasSeasonViewAfterLoad(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasSeasonViewAfterLoadProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasSeasonViewAfterLoadHash() =>
    r'49afed087d27f0e95f35ec6944584601170d24f4';

/// Whether season view is available for a podcast.
///
/// Checks the parsed feed data directly for season numbers, so it works
/// for both subscribed and non-subscribed podcasts.

final class HasSeasonViewAfterLoadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  HasSeasonViewAfterLoadFamily._()
    : super(
        retry: null,
        name: r'hasSeasonViewAfterLoadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether season view is available for a podcast.
  ///
  /// Checks the parsed feed data directly for season numbers, so it works
  /// for both subscribed and non-subscribed podcasts.

  HasSeasonViewAfterLoadProvider call(String feedUrl) =>
      HasSeasonViewAfterLoadProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'hasSeasonViewAfterLoadProvider';
}

/// Provides sorted seasons for a podcast.
///
/// For subscribed podcasts, uses database-backed season resolution.
/// For non-subscribed podcasts, derives seasons from feed data directly.

@ProviderFor(sortedPodcastSeasons)
final sortedPodcastSeasonsProvider = SortedPodcastSeasonsFamily._();

/// Provides sorted seasons for a podcast.
///
/// For subscribed podcasts, uses database-backed season resolution.
/// For non-subscribed podcasts, derives seasons from feed data directly.

final class SortedPodcastSeasonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeasonGrouping?>,
          SeasonGrouping?,
          FutureOr<SeasonGrouping?>
        >
    with $FutureModifier<SeasonGrouping?>, $FutureProvider<SeasonGrouping?> {
  /// Provides sorted seasons for a podcast.
  ///
  /// For subscribed podcasts, uses database-backed season resolution.
  /// For non-subscribed podcasts, derives seasons from feed data directly.
  SortedPodcastSeasonsProvider._({
    required SortedPodcastSeasonsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'sortedPodcastSeasonsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sortedPodcastSeasonsHash();

  @override
  String toString() {
    return r'sortedPodcastSeasonsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SeasonGrouping?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeasonGrouping?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return sortedPodcastSeasons(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SortedPodcastSeasonsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sortedPodcastSeasonsHash() =>
    r'04bb768c2827478b5d1bff9356a8e62a3c940577';

/// Provides sorted seasons for a podcast.
///
/// For subscribed podcasts, uses database-backed season resolution.
/// For non-subscribed podcasts, derives seasons from feed data directly.

final class SortedPodcastSeasonsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<SeasonGrouping?>, (String, String)> {
  SortedPodcastSeasonsFamily._()
    : super(
        retry: null,
        name: r'sortedPodcastSeasonsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides sorted seasons for a podcast.
  ///
  /// For subscribed podcasts, uses database-backed season resolution.
  /// For non-subscribed podcasts, derives seasons from feed data directly.

  SortedPodcastSeasonsProvider call(String feedUrl, String podcastId) =>
      SortedPodcastSeasonsProvider._(
        argument: (feedUrl, podcastId),
        from: this,
      );

  @override
  String toString() => r'sortedPodcastSeasonsProvider';
}
