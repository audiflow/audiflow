import 'package:audiflow/common/service/app_wide_initializer.dart';
import 'package:audiflow/routing/app_bottom_navigation_bar.dart';
import 'package:audiflow/ui/pages/podcast_home_page.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      initialLocation: '/',
      routes: _routes,
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

  // BuildContext get context =>
  //     router.routerDelegate.navigatorKey.currentContext!;
  //
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
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: const PodcastHomePage(),
                  );
                },
                // routes: [
                  // GoRoute(
                  //   path: 'season',
                  //   name: 'season',
                  //   parentNavigatorKey: homeTabNavigatorKey,
                  //   pageBuilder: (context, state) {
                  //     final (podcast, season, heroPrefix) =
                  //         state.extra! as (Podcast, Season, String);
                  //     return _getPage(
                  //       child: PodcastSeasonPage(
                  //         podcast: podcast,
                  //         season: season,
                  //         heroPrefix: heroPrefix,
                  //       ),
                  //       state: state,
                  //     );
                  //   },
                  // ),
                  // GoRoute(
                  //   path: 'detail',
                  //   name: 'detail',
                  //   parentNavigatorKey: homeTabNavigatorKey,
                  //   pageBuilder: (context, state) {
                  //     final (
                  //     feedUrl,
                  //     collectionId,
                  //     title,
                  //     author,
                  //     thumbnailUrl
                  //     ) = state.extra! as (
                  //     String?,
                  //     int?,
                  //     String?,
                  //     String?,
                  //     String?
                  //     );
                  //     return _getPage(
                  //       child: PodcastDetailsPage(
                  //         collectionId: collectionId,
                  //         feedUrl: feedUrl,
                  //         title: title,
                  //         author: author,
                  //         thumbnailUrl: thumbnailUrl,
                  //       ),
                  //       state: state,
                  //     );
                  //   },
                  // ),
                  // GoRoute(
                  //   path: 'episode',
                  //   name: 'episode',
                  //   parentNavigatorKey: homeTabNavigatorKey,
                  //   pageBuilder: (context, state) {
                  //     final (episode, heroPrefix) =
                  //         state.extra! as (Episode, String);
                  //     return _getPage(
                  //       child: EpisodePage(
                  //         episode: episode,
                  //         heroPrefix: heroPrefix,
                  //       ),
                  //       state: state,
                  //     );
                  //   },
                  // ),
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
                // ],
              ),
            ],
          ),
          // StatefulShellBranch(
          //   navigatorKey: searchTabNavigatorKey,
          //   routes: [
          //     GoRoute(
          //       path: searchPath,
          //       pageBuilder: (context, state) {
          //         return _getPage(
          //           child: const SearchPage(),
          //           state: state,
          //         );
          //       },
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   navigatorKey: libraryTabNavigatorKey,
          //   routes: [
          //     GoRoute(
          //       path: libraryPath,
          //       pageBuilder: (context, state) {
          //         return _getPage(
          //           child: const LibraryPage(),
          //           state: state,
          //         );
          //       },
          //       routes: [
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
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
        builder: (context, state, navigationShell) {
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
}
