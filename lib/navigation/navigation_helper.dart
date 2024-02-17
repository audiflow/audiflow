import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/features/podcast_chart/ui/podcast_chart_page.dart';
import 'package:seasoning/features/podcast_details/ui/podcast_details.dart';
import 'package:seasoning/ui/seasoning_app.dart';

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
                    path: 'detail',
                    parentNavigatorKey: homeTabNavigatorKey,
                    pageBuilder: (context, state) {
                      final baseInfo = state.extra as PodcastSummary?;
                      return _getPage(
                        child: PodcastDetails(baseInfo!),
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
                    child: const SizedBox.shrink(),
                    state: state,
                  );
                },
                // routes: [
                //   GoRoute(
                //     path: 'detail',
                //     parentNavigatorKey: searchTabNavigatorKey,
                //     pageBuilder: (context, state) {
                //       final url = state.extra! as String;
                //       return _getPage(
                //         child: PodcastDetails(podcast),
                //         state: state,
                //       );
                //     },
                //   ),
                // ]
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingsTabNavigatorKey,
            routes: [
              GoRoute(
                path: settingsPath,
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
        builder: (context, state, navigationShell) {
          return AppBottomNavigationBar(
            navigationShell: navigationShell,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: signUpPath,
        pageBuilder: (context, state) {
          return _getPage(
            child: const SignUpPage(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: signInPath,
        pageBuilder: (context, state) {
          return _getPage(
            child: const SignInPage(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: rootDetailPath,
        pageBuilder: (context, state) {
          return _getPage(
            child: const DetailPage(),
            state: state,
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

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String signUpPath = '/signUp';
  static const String signInPath = '/signIn';
  static const String rootDetailPath = '/rootDetail';

  static const String homePath = '/home';
  static const String detailPath = '/home/detail';
  static const String settingsPath = '/settings';
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
}
