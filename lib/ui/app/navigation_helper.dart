// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/app/app_bottom_navigation_bar.dart';
import 'package:audiflow/ui/pages/episode_page.dart';
import 'package:audiflow/ui/pages/podcast_chart_page.dart';
import 'package:audiflow/ui/pages/podcast_details_page.dart';
import 'package:audiflow/ui/pages/podcast_season_page.dart';
import 'package:audiflow/ui/pages/search_page.dart';
import 'package:audiflow/ui/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

class NavigationHelper {
  factory NavigationHelper.setup() => _instance;

  NavigationHelper._internal() {
    final routes = [
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
                    child: const PodcastChartPage(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'season',
                    name: 'season',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final (podcast, season, heroPrefix) =
                          state.extra! as (Podcast, Season, String);
                      return _getPage(
                        child: PodcastSeasonPage(
                          podcast: podcast,
                          season: season,
                          heroPrefix: heroPrefix,
                        ),
                        state: state,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'detail',
                    name: 'detail',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final (metadata, heroPrefix, paletteGenerator) =
                          state.extra! as (
                        PodcastMetadata,
                        String,
                        PaletteGenerator
                      );
                      return _getPage(
                        child: PodcastDetailsPage(
                          metadata: metadata,
                          heroPrefix: heroPrefix,
                          paletteGenerator: paletteGenerator,
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
                      final (metadata, episode, heroPrefix) =
                          state.extra! as (PodcastMetadata, Episode, String);
                      return _getPage(
                        child: EpisodePage(
                          metadata: metadata,
                          episode: episode,
                          heroPrefix: heroPrefix,
                        ),
                        state: state,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      return _getPage(
                        child: const SettingsPage(),
                        state: state,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: searchTabNavigatorKey,
            routes: [
              GoRoute(
                path: searchPath,
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
          return AppBottomNavigationBar(
            navigationShell: navigationShell,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: homePath,
      routes: routes,
    );
  }

  static final NavigationHelper _instance = NavigationHelper._internal();

  static late final GoRouter router;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> searchTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> settingsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String signUpPath = '/signUp';
  static const String signInPath = '/signIn';

  static const String homePath = '/home';
  static const String detailPath = '/home/detail';
  static const String searchPath = '/search';
  static const String searchDetailPath = '/search';

  static Page<Widget> _getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }

  static Future<void> pushPodcastDetail({
    required PodcastMetadata metadata,
    required String heroPrefix,
  }) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.network(metadata.thumbImageUrl, cacheWidth: 480).image,
      size: const Size.fromWidth(480),
      maximumColorCount: 20,
    );

    await router.pushNamed(
      'detail',
      extra: (metadata, heroPrefix, paletteGenerator),
    );
  }

  static Future<void> pushEpisodeDetail({
    required PodcastMetadata metadata,
    required Episode episode,
    required String heroPrefix,
  }) async {
    await NavigationHelper.router.pushNamed(
      'episode',
      extra: (metadata, episode, heroPrefix),
    );
  }

  static Future<void> pushSettings() async {
    await NavigationHelper.router.pushNamed(
      'settings',
    );
  }
}
