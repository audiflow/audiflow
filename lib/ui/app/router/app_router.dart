import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/stopwatch.dart';
import 'package:audiflow/ui/app/app_bottom_navigation_bar.dart';
import 'package:audiflow/ui/pages/podcast_home_page.dart';
import 'package:audiflow/ui/pages/podcast_intro_page.dart';
import 'package:audiflow/ui/providers/app_wide_providers.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

class AppRouter {
  AppRouter(this._ref) {
    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: homePath,
      routes: _routes,
    );
  }

  static const String homePath = '/home';
  static const String searchPath = '/search';
  static const String libraryPath = '/library';

  final Ref _ref;
  late final GoRouter router;

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

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  List<RouteBase> get _routes {
    return [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: homePath,
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: const PodcastHomePage(),
                  );
                },
                routes: [
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
                  GoRoute(
                    path: 'intro',
                    name: 'intro',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final (collectionId, title, author, thumbnailUrl) =
                          state.extra! as (int, String, String, String);
                      elapsedTime('navi: show PodcastIntroPage');
                      return _getPage(
                        child: PodcastIntroPage(
                          collectionId: collectionId,
                          title: title,
                          author: author,
                          thumbnailUrl: thumbnailUrl,
                        ),
                        state: state,
                      );
                    },
                  )
                  // GoRoute(
                  //   path: 'detail',
                  //   name: 'detail',
                  //   parentNavigatorKey: homeTabNavigatorKey,
                  //   pageBuilder: (context, state) {
                  //     final (feedUrl, collectionId, paletteGenerator) =
                  //         state.extra! as (String?, int?, PaletteGenerator);
                  //     return _getPage(
                  //       child: PodcastDetailsPage(
                  //         feedUrl: feedUrl,
                  //         collectionId: collectionId,
                  //         paletteGenerator: paletteGenerator,
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
                ],
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

  Future<void> pushPodcastDetail(Podcast podcast) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.network(podcast.image, cacheWidth: 480).image,
      size: const Size.fromWidth(480),
      maximumColorCount: 20,
    );

    await router.pushNamed(
      'detail',
      extra: (podcast, paletteGenerator),
    );
  }

  Future<void> pushPodcastIntro({
    required int collectionId,
    required String title,
    required String author,
    required String thumbnailUrl,
  }) async {
    await router.pushNamed(
      'intro',
      extra: (collectionId, title, author, thumbnailUrl),
    );
  }

  Future<void> pushEpisodeDetail({
    required Episode episode,
    required String heroPrefix,
  }) async {
    await router.pushNamed(
      'episode',
      extra: (episode, heroPrefix),
    );
  }

  Future<void> pushSettings() async {
    await router.pushNamed(
      'settings',
    );
  }

  Future<void> pushLatestEpisodes() async {
    await router.pushNamed(
      'latestEpisodes',
    );
  }

  Future<void> pushRecentlyPlayed() async {
    await router.pushNamed(
      'recentlyPlayed',
    );
  }
}
