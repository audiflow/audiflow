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
