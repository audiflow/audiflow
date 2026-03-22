// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for PodcastSearchService.
///
/// This provider creates a [PodcastSearchService] instance configured with
/// the iTunes provider for podcast search functionality.
///
/// Override this provider in tests to inject mock implementations.

@ProviderFor(podcastSearchService)
final podcastSearchServiceProvider = PodcastSearchServiceProvider._();

/// Provider for PodcastSearchService.
///
/// This provider creates a [PodcastSearchService] instance configured with
/// the iTunes provider for podcast search functionality.
///
/// Override this provider in tests to inject mock implementations.

final class PodcastSearchServiceProvider
    extends
        $FunctionalProvider<
          PodcastSearchService,
          PodcastSearchService,
          PodcastSearchService
        >
    with $Provider<PodcastSearchService> {
  /// Provider for PodcastSearchService.
  ///
  /// This provider creates a [PodcastSearchService] instance configured with
  /// the iTunes provider for podcast search functionality.
  ///
  /// Override this provider in tests to inject mock implementations.
  PodcastSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastSearchServiceHash();

  @$internal
  @override
  $ProviderElement<PodcastSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PodcastSearchService create(Ref ref) {
    return podcastSearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastSearchService>(value),
    );
  }
}

String _$podcastSearchServiceHash() =>
    r'9387293b0edcc4809b64ba2bf74d71856f4a8e9c';

/// Controller for managing podcast search state and operations.
///
/// Supports debounced search-as-you-type with IME composing guards
/// and stale-result display during loading.

@ProviderFor(PodcastSearchController)
final podcastSearchControllerProvider = PodcastSearchControllerProvider._();

/// Controller for managing podcast search state and operations.
///
/// Supports debounced search-as-you-type with IME composing guards
/// and stale-result display during loading.
final class PodcastSearchControllerProvider
    extends $NotifierProvider<PodcastSearchController, SearchState> {
  /// Controller for managing podcast search state and operations.
  ///
  /// Supports debounced search-as-you-type with IME composing guards
  /// and stale-result display during loading.
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
    r'66053c3f348426cff3f05c45a6a93049d8303526';

/// Controller for managing podcast search state and operations.
///
/// Supports debounced search-as-you-type with IME composing guards
/// and stale-result display during loading.

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
