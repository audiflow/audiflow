// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.

@ProviderFor(librarySubscriptions)
final librarySubscriptionsProvider = LibrarySubscriptionsProvider._();

/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.

final class LibrarySubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Subscription>>,
          List<Subscription>,
          Stream<List<Subscription>>
        >
    with
        $FutureModifier<List<Subscription>>,
        $StreamProvider<List<Subscription>> {
  /// Provides a reactive stream of user's podcast subscriptions.
  ///
  /// Updates automatically when subscriptions change in the database.
  LibrarySubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySubscriptionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Subscription>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Subscription>> create(Ref ref) {
    return librarySubscriptions(ref);
  }
}

String _$librarySubscriptionsHash() =>
    r'5a727f721ac3181213f27613227a3e5599da9432';

/// Manages the persisted podcast sort order preference.

@ProviderFor(PodcastSortOrderController)
final podcastSortOrderControllerProvider =
    PodcastSortOrderControllerProvider._();

/// Manages the persisted podcast sort order preference.
final class PodcastSortOrderControllerProvider
    extends
        $AsyncNotifierProvider<PodcastSortOrderController, PodcastSortOrder> {
  /// Manages the persisted podcast sort order preference.
  PodcastSortOrderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastSortOrderControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastSortOrderControllerHash();

  @$internal
  @override
  PodcastSortOrderController create() => PodcastSortOrderController();
}

String _$podcastSortOrderControllerHash() =>
    r'2f79f12e8dadaceac6c5a1b8f59743f1d4578b5c';

/// Manages the persisted podcast sort order preference.

abstract class _$PodcastSortOrderController
    extends $AsyncNotifier<PodcastSortOrder> {
  FutureOr<PodcastSortOrder> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PodcastSortOrder>, PodcastSortOrder>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PodcastSortOrder>, PodcastSortOrder>,
              AsyncValue<PodcastSortOrder>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Watches the newest episode for a given podcast, emitting its
/// [Episode.publishedAt] whenever the episode list changes.
///
/// Used by [sortedSubscriptionsProvider] to keep the latest-episode
/// sort order reactive to background feed refreshes.

@ProviderFor(newestEpisodeDate)
final newestEpisodeDateProvider = NewestEpisodeDateFamily._();

/// Watches the newest episode for a given podcast, emitting its
/// [Episode.publishedAt] whenever the episode list changes.
///
/// Used by [sortedSubscriptionsProvider] to keep the latest-episode
/// sort order reactive to background feed refreshes.

final class NewestEpisodeDateProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  /// Watches the newest episode for a given podcast, emitting its
  /// [Episode.publishedAt] whenever the episode list changes.
  ///
  /// Used by [sortedSubscriptionsProvider] to keep the latest-episode
  /// sort order reactive to background feed refreshes.
  NewestEpisodeDateProvider._({
    required NewestEpisodeDateFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'newestEpisodeDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$newestEpisodeDateHash();

  @override
  String toString() {
    return r'newestEpisodeDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    final argument = this.argument as int;
    return newestEpisodeDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NewestEpisodeDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$newestEpisodeDateHash() => r'c53f3d7431cc9acdef0fb79c2fe741d0bfee6bbb';

/// Watches the newest episode for a given podcast, emitting its
/// [Episode.publishedAt] whenever the episode list changes.
///
/// Used by [sortedSubscriptionsProvider] to keep the latest-episode
/// sort order reactive to background feed refreshes.

final class NewestEpisodeDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DateTime?>, int> {
  NewestEpisodeDateFamily._()
    : super(
        retry: null,
        name: r'newestEpisodeDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches the newest episode for a given podcast, emitting its
  /// [Episode.publishedAt] whenever the episode list changes.
  ///
  /// Used by [sortedSubscriptionsProvider] to keep the latest-episode
  /// sort order reactive to background feed refreshes.

  NewestEpisodeDateProvider call(int podcastId) =>
      NewestEpisodeDateProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'newestEpisodeDateProvider';
}

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with
/// [podcastSortOrderControllerProvider] and episode data
/// (for latestEpisode sort).
///
/// When [PodcastSortOrder.latestEpisode] is active, watches
/// per-podcast episode streams so the sort order updates reactively
/// when new episodes arrive (e.g. after a background feed refresh).

@ProviderFor(sortedSubscriptions)
final sortedSubscriptionsProvider = SortedSubscriptionsProvider._();

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with
/// [podcastSortOrderControllerProvider] and episode data
/// (for latestEpisode sort).
///
/// When [PodcastSortOrder.latestEpisode] is active, watches
/// per-podcast episode streams so the sort order updates reactively
/// when new episodes arrive (e.g. after a background feed refresh).

final class SortedSubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Subscription>>,
          List<Subscription>,
          FutureOr<List<Subscription>>
        >
    with
        $FutureModifier<List<Subscription>>,
        $FutureProvider<List<Subscription>> {
  /// Provides subscriptions sorted by the user's selected sort order.
  ///
  /// Combines [librarySubscriptionsProvider] with
  /// [podcastSortOrderControllerProvider] and episode data
  /// (for latestEpisode sort).
  ///
  /// When [PodcastSortOrder.latestEpisode] is active, watches
  /// per-podcast episode streams so the sort order updates reactively
  /// when new episodes arrive (e.g. after a background feed refresh).
  SortedSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Subscription>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Subscription>> create(Ref ref) {
    return sortedSubscriptions(ref);
  }
}

String _$sortedSubscriptionsHash() =>
    r'dd645b180f732916e87693040722da85097a6c56';
