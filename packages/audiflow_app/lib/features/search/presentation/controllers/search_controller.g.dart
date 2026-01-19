// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing podcast search state and operations.
///
/// This controller coordinates search requests and manages the UI state
/// transitions between initial, loading, success, and error states.
///
/// Note: Named `PodcastSearchController` to avoid collision with Flutter's
/// built-in `SearchController` from material library.
///
/// Usage:
/// ```dart
/// final state = ref.watch(podcastSearchControllerProvider);
/// final controller = ref.read(podcastSearchControllerProvider.notifier);
///
/// await controller.search('technology podcasts');
/// ```

@ProviderFor(PodcastSearchController)
final podcastSearchControllerProvider = PodcastSearchControllerProvider._();

/// Controller for managing podcast search state and operations.
///
/// This controller coordinates search requests and manages the UI state
/// transitions between initial, loading, success, and error states.
///
/// Note: Named `PodcastSearchController` to avoid collision with Flutter's
/// built-in `SearchController` from material library.
///
/// Usage:
/// ```dart
/// final state = ref.watch(podcastSearchControllerProvider);
/// final controller = ref.read(podcastSearchControllerProvider.notifier);
///
/// await controller.search('technology podcasts');
/// ```
final class PodcastSearchControllerProvider
    extends $NotifierProvider<PodcastSearchController, SearchState> {
  /// Controller for managing podcast search state and operations.
  ///
  /// This controller coordinates search requests and manages the UI state
  /// transitions between initial, loading, success, and error states.
  ///
  /// Note: Named `PodcastSearchController` to avoid collision with Flutter's
  /// built-in `SearchController` from material library.
  ///
  /// Usage:
  /// ```dart
  /// final state = ref.watch(podcastSearchControllerProvider);
  /// final controller = ref.read(podcastSearchControllerProvider.notifier);
  ///
  /// await controller.search('technology podcasts');
  /// ```
  PodcastSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastSearchControllerHash();

  @$internal
  @override
  PodcastSearchController create() => PodcastSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$podcastSearchControllerHash() =>
    r'91468cf1b4e48756df6e7f09dc8ec4762f8eba52';

/// Controller for managing podcast search state and operations.
///
/// This controller coordinates search requests and manages the UI state
/// transitions between initial, loading, success, and error states.
///
/// Note: Named `PodcastSearchController` to avoid collision with Flutter's
/// built-in `SearchController` from material library.
///
/// Usage:
/// ```dart
/// final state = ref.watch(podcastSearchControllerProvider);
/// final controller = ref.read(podcastSearchControllerProvider.notifier);
///
/// await controller.search('technology podcasts');
/// ```

abstract class _$PodcastSearchController extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
