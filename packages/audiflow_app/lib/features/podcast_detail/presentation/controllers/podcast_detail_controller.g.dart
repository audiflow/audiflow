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

String _$podcastDetailHash() => r'27aa2a179ea5aaa09be868c73ebcf9b61df79eda';

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

/// Manages the current episode filter selection.

@ProviderFor(EpisodeFilterState)
final episodeFilterStateProvider = EpisodeFilterStateProvider._();

/// Manages the current episode filter selection.
final class EpisodeFilterStateProvider
    extends $NotifierProvider<EpisodeFilterState, EpisodeFilter> {
  /// Manages the current episode filter selection.
  EpisodeFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'episodeFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$episodeFilterStateHash();

  @$internal
  @override
  EpisodeFilterState create() => EpisodeFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EpisodeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EpisodeFilter>(value),
    );
  }
}

String _$episodeFilterStateHash() =>
    r'ab76b1b8835f0fd3f0798663f5520f0dfc3b9c98';

/// Manages the current episode filter selection.

abstract class _$EpisodeFilterState extends $Notifier<EpisodeFilter> {
  EpisodeFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EpisodeFilter, EpisodeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EpisodeFilter, EpisodeFilter>,
              EpisodeFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Filters episodes based on the selected filter.
///
/// Returns filtered list of [PodcastItem] based on playback status.

@ProviderFor(filteredEpisodes)
final filteredEpisodesProvider = FilteredEpisodesFamily._();

/// Filters episodes based on the selected filter.
///
/// Returns filtered list of [PodcastItem] based on playback status.

final class FilteredEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PodcastItem>>,
          List<PodcastItem>,
          FutureOr<List<PodcastItem>>
        >
    with
        $FutureModifier<List<PodcastItem>>,
        $FutureProvider<List<PodcastItem>> {
  /// Filters episodes based on the selected filter.
  ///
  /// Returns filtered list of [PodcastItem] based on playback status.
  FilteredEpisodesProvider._({
    required FilteredEpisodesFamily super.from,
    required (String, EpisodeFilter) super.argument,
  }) : super(
         retry: null,
         name: r'filteredEpisodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredEpisodesHash();

  @override
  String toString() {
    return r'filteredEpisodesProvider'
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
    final argument = this.argument as (String, EpisodeFilter);
    return filteredEpisodes(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredEpisodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredEpisodesHash() => r'b994b18281ac38af788477bcedc96f1e2a951d3b';

/// Filters episodes based on the selected filter.
///
/// Returns filtered list of [PodcastItem] based on playback status.

final class FilteredEpisodesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PodcastItem>>,
          (String, EpisodeFilter)
        > {
  FilteredEpisodesFamily._()
    : super(
        retry: null,
        name: r'filteredEpisodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filters episodes based on the selected filter.
  ///
  /// Returns filtered list of [PodcastItem] based on playback status.

  FilteredEpisodesProvider call(String feedUrl, EpisodeFilter filter) =>
      FilteredEpisodesProvider._(argument: (feedUrl, filter), from: this);

  @override
  String toString() => r'filteredEpisodesProvider';
}
