import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/features/bootstrap/service/app_wide_initializer.dart';
import 'package:audiflow/features/browser/chart/ui/podcast_chart_page.dart';
import 'package:audiflow/features/browser/common/model/itunes_item.dart';
import 'package:audiflow/features/browser/episode/ui/episode_page.dart';
import 'package:audiflow/features/browser/library/ui/library_page.dart';
import 'package:audiflow/features/browser/library/ui/subscribed_podcasts_page.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_page.dart';
import 'package:audiflow/features/browser/search/ui/search_page.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/ui/season_episodes_page.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/routing/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'app_router.g.dart';

enum AppRoute {
  home,
  product,
  leaveReview,
  cart,
  checkout,
  orders,
  account,
  signIn,
}

@Riverpod(keepAlive: true)
class AppRouter extends _$AppRouter {
  @override
  GoRouter build() {
    return GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: '/library',
      routes: _routes,
      observers: [
        SentryNavigatorObserver(),
      ],
    );
  }

  final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> searchTabNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> libraryTabNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> settingsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  // GoRouterDelegate get routerDelegate => router.routerDelegate;
  //
  // GoRouteInformationParser get routeInformationParser =>
  //     router.routeInformationParser;

  List<RouteBase> get _routes {
    return [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: libraryTabNavigatorKey,
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                pageBuilder: (context, state) {
                  return _getPage(
                    child: const LibraryPage(),
                    state: state,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'subscriptions',
                    name: 'subscribedPodcasts',
                    parentNavigatorKey: libraryTabNavigatorKey,
                    pageBuilder: (context, state) {
                      return _getPage(
                        child: const SubscribedPodcastsPage(),
                        state: state,
                      );
                    },
                  ),
                  //         GoRoute(
                  //           path: 'latest',
                  //           name: 'latestEpisodes',
                  //           parentNavigatorKey: libraryTabNavigatorKey,
                  //           pageBuilder: (context, state) {
                  //             return _getPage(
                  //               child: const LatestEpisodesPage(),
                  //               state: state,
                  //             );
                  //           },
                  //         ),
                  //         GoRoute(
                  //           path: 'recent',
                  //           name: 'recentlyPlayed',
                  //           parentNavigatorKey: libraryTabNavigatorKey,
                  //           pageBuilder: (context, state) {
                  //             return _getPage(
                  //               child: const RecentlyPlayedPage(),
                  //               state: state,
                  //             );
                  //           },
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: '/chart',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: const PodcastChartPage(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'podcasts',
                    name: 'podcast',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final (
                        feedUrl,
                        collectionId,
                        title,
                        author,
                        thumbnailUrl
                      ) = state.extra! as (
                        String?,
                        int?,
                        String?,
                        String?,
                        String?
                      );
                      return _getPage(
                        child: PodcastDetailsPage(
                          collectionId: collectionId,
                          feedUrl: feedUrl,
                          title: title,
                          author: author,
                          thumbnailUrl: thumbnailUrl,
                        ),
                        state: state,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'season',
                    name: 'season',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final (podcast, season) =
                          state.extra! as (Podcast, Season);
                      return _getPage(
                        child: SeasonEpisodesPage(
                          podcast: podcast,
                          season: season,
                        ),
                        state: state,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'episode',
                    name: 'episode',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final episode = state.extra! as Episode;
                      return _getPage(
                        child: EpisodePage(episode: episode),
                        state: state,
                      );
                    },
                  ),
                  // GoRoute(
                  //   path: 'settings',
                  //   name: 'settings',
                  //   parentNavigatorKey: homeTabNavigatorKey,
                  //   pageBuilder: (context, state) {
                  //     return _getPage(
                  //       child: const SettingsPage(),
                  //       state: state,
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: searchTabNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (context, state) {
                  return _getPage(
                    child: const SearchPage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        builder: (context, state, navigationShell) {
          ref.listen(appWideProvider, (_, __) {});
          return AppWideProvidersInitializer(
            child: Stack(
              children: [
                const ErrorNotifier(),
                AppBottomNavigationBar(
                  navigationShell: navigationShell,
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  Page<Widget> _getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }

  Future<void> pushPodcastDetail(Podcast podcast) async {
    await state.pushNamed(
      'podcast',
      extra: (
        podcast.feedUrl,
        podcast.collectionId,
        podcast.title,
        podcast.author,
        podcast.image,
      ),
    );
  }

  Future<void> pushPodcastDetailFromChart(ITunesItem chartItem) async {
    await state.pushNamed(
      'podcast',
      extra: (
        null,
        chartItem.collectionId,
        chartItem.collectionName,
        chartItem.artistName,
        chartItem.thumbnailArtworkUrl,
      ),
    );
  }

  Future<void> pushSeason(Podcast podcast, Season season) async {
    await state.pushNamed(
      'season',
      extra: (podcast, season),
    );
  }

  Future<void> pushEpisodeDetail({
    required Episode episode,
  }) async {
    await state.pushNamed(
      'episode',
      extra: episode,
    );
  }

  Future<void> pushSettings() async {
    await state.pushNamed(
      'settings',
    );
  }

  Future<void> pushLatestEpisodes() async {
    await state.pushNamed(
      'latestEpisodes',
    );
  }

  Future<void> pushRecentlyPlayed() async {
    await state.pushNamed(
      'recentlyPlayed',
    );
  }

  Future<void> pushSubscribedPodcasts() async {
    await state.pushNamed(
      'subscribedPodcasts',
    );
  }
}

@riverpod
BuildContext routerContext(RouterContextRef ref) {
  return ref
      .read(appRouterProvider)
      .routerDelegate
      .navigatorKey
      .currentContext!;
}
