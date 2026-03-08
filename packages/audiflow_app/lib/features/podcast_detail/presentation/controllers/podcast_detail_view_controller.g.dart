// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_detail_view_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ephemeral view preferences for non-subscribed podcasts.
///
/// Subscribed podcasts persist preferences via
/// [podcastViewPreferenceControllerProvider]. This notifier
/// provides the same interface for non-subscribed podcasts
/// without persistence.

@ProviderFor(LocalViewPreference)
final localViewPreferenceProvider = LocalViewPreferenceProvider._();

/// Ephemeral view preferences for non-subscribed podcasts.
///
/// Subscribed podcasts persist preferences via
/// [podcastViewPreferenceControllerProvider]. This notifier
/// provides the same interface for non-subscribed podcasts
/// without persistence.
final class LocalViewPreferenceProvider
    extends
        $NotifierProvider<
          LocalViewPreference,
          ({
            SmartPlaylist? activePlaylist,
            EpisodeFilter filter,
            PodcastViewMode mode,
            SortOrder sortOrder,
          })
        > {
  /// Ephemeral view preferences for non-subscribed podcasts.
  ///
  /// Subscribed podcasts persist preferences via
  /// [podcastViewPreferenceControllerProvider]. This notifier
  /// provides the same interface for non-subscribed podcasts
  /// without persistence.
  LocalViewPreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localViewPreferenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localViewPreferenceHash();

  @$internal
  @override
  LocalViewPreference create() => LocalViewPreference();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({
      SmartPlaylist? activePlaylist,
      EpisodeFilter filter,
      PodcastViewMode mode,
      SortOrder sortOrder,
    })
    value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({
              SmartPlaylist? activePlaylist,
              EpisodeFilter filter,
              PodcastViewMode mode,
              SortOrder sortOrder,
            })
          >(value),
    );
  }
}

String _$localViewPreferenceHash() =>
    r'2e3ce5d5ab8279d5cda00fbd513d8def2e01f067';

/// Ephemeral view preferences for non-subscribed podcasts.
///
/// Subscribed podcasts persist preferences via
/// [podcastViewPreferenceControllerProvider]. This notifier
/// provides the same interface for non-subscribed podcasts
/// without persistence.

abstract class _$LocalViewPreference
    extends
        $Notifier<
          ({
            SmartPlaylist? activePlaylist,
            EpisodeFilter filter,
            PodcastViewMode mode,
            SortOrder sortOrder,
          })
        > {
  ({
    SmartPlaylist? activePlaylist,
    EpisodeFilter filter,
    PodcastViewMode mode,
    SortOrder sortOrder,
  })
  build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({
                SmartPlaylist? activePlaylist,
                EpisodeFilter filter,
                PodcastViewMode mode,
                SortOrder sortOrder,
              }),
              ({
                SmartPlaylist? activePlaylist,
                EpisodeFilter filter,
                PodcastViewMode mode,
                SortOrder sortOrder,
              })
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({
                  SmartPlaylist? activePlaylist,
                  EpisodeFilter filter,
                  PodcastViewMode mode,
                  SortOrder sortOrder,
                }),
                ({
                  SmartPlaylist? activePlaylist,
                  EpisodeFilter filter,
                  PodcastViewMode mode,
                  SortOrder sortOrder,
                })
              >,
              ({
                SmartPlaylist? activePlaylist,
                EpisodeFilter filter,
                PodcastViewMode mode,
                SortOrder sortOrder,
              }),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Consolidated view controller for the podcast detail screen.
///
/// Merges feed data, subscription state, view preferences,
/// filtered episodes, progress, and smart playlists into a
/// single [PodcastDetailViewState].

@ProviderFor(podcastDetailView)
final podcastDetailViewProvider = PodcastDetailViewFamily._();

/// Consolidated view controller for the podcast detail screen.
///
/// Merges feed data, subscription state, view preferences,
/// filtered episodes, progress, and smart playlists into a
/// single [PodcastDetailViewState].

final class PodcastDetailViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<PodcastDetailViewState>,
          PodcastDetailViewState,
          FutureOr<PodcastDetailViewState>
        >
    with
        $FutureModifier<PodcastDetailViewState>,
        $FutureProvider<PodcastDetailViewState> {
  /// Consolidated view controller for the podcast detail screen.
  ///
  /// Merges feed data, subscription state, view preferences,
  /// filtered episodes, progress, and smart playlists into a
  /// single [PodcastDetailViewState].
  PodcastDetailViewProvider._({
    required PodcastDetailViewFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'podcastDetailViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastDetailViewHash();

  @override
  String toString() {
    return r'podcastDetailViewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PodcastDetailViewState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PodcastDetailViewState> create(Ref ref) {
    final argument = this.argument as (String, String);
    return podcastDetailView(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastDetailViewHash() => r'599ba3b85276e707fdacde20921bdf51235e5a06';

/// Consolidated view controller for the podcast detail screen.
///
/// Merges feed data, subscription state, view preferences,
/// filtered episodes, progress, and smart playlists into a
/// single [PodcastDetailViewState].

final class PodcastDetailViewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PodcastDetailViewState>,
          (String, String)
        > {
  PodcastDetailViewFamily._()
    : super(
        retry: null,
        name: r'podcastDetailViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Consolidated view controller for the podcast detail screen.
  ///
  /// Merges feed data, subscription state, view preferences,
  /// filtered episodes, progress, and smart playlists into a
  /// single [PodcastDetailViewState].

  PodcastDetailViewProvider call(String feedUrl, String podcastId) =>
      PodcastDetailViewProvider._(argument: (feedUrl, podcastId), from: this);

  @override
  String toString() => r'podcastDetailViewProvider';
}
