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
    r'podcast_sort_order_controller_hash';

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

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with
/// [podcastSortOrderControllerProvider] and episode data
/// (for latestEpisode sort).

@ProviderFor(sortedSubscriptions)
final sortedSubscriptionsProvider = SortedSubscriptionsProvider._();

/// Provides subscriptions sorted by the user's selected sort order.

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

String _$sortedSubscriptionsHash() => r'sorted_subscriptions_hash';
