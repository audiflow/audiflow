// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $mainPageShellRoute,
    ];

RouteBase get $mainPageShellRoute => StatefulShellRouteData.$route(
      factory: $MainPageShellRouteExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/',
              factory: $HomePageRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'debug',
                  parentNavigatorKey: DebugPageRoute.$parentNavigatorKey,
                  factory: $DebugPageRouteExtension._fromState,
                ),
                GoRouteData.$route(
                  path: 'setting',
                  name: 'homeSetting',
                  factory: $HomeSettingPageRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/search',
              factory: $SearchPageRouteExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/library',
              factory: $LibraryPageRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'license',
                  factory: $LicensePageRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    );

extension $MainPageShellRouteExtension on MainPageShellRoute {
  static MainPageShellRoute _fromState(GoRouterState state) =>
      const MainPageShellRoute();
}

extension $HomePageRouteExtension on HomePageRoute {
  static HomePageRoute _fromState(GoRouterState state) => const HomePageRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DebugPageRouteExtension on DebugPageRoute {
  static DebugPageRoute _fromState(GoRouterState state) =>
      const DebugPageRoute();

  String get location => GoRouteData.$location(
        '/debug',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HomeSettingPageRouteExtension on HomeSettingPageRoute {
  static HomeSettingPageRoute _fromState(GoRouterState state) =>
      const HomeSettingPageRoute();

  String get location => GoRouteData.$location(
        '/setting',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SearchPageRouteExtension on SearchPageRoute {
  static SearchPageRoute _fromState(GoRouterState state) =>
      const SearchPageRoute();

  String get location => GoRouteData.$location(
        '/search',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LibraryPageRouteExtension on LibraryPageRoute {
  static LibraryPageRoute _fromState(GoRouterState state) =>
      const LibraryPageRoute();

  String get location => GoRouteData.$location(
        '/library',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LicensePageRouteExtension on LicensePageRoute {
  static LicensePageRoute _fromState(GoRouterState state) =>
      const LicensePageRoute();

  String get location => GoRouteData.$location(
        '/library/license',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'cbe239eb1da0265bdf22aa484b810a7c00b35f85';

/// See also [router].
@ProviderFor(router)
final routerProvider = Provider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RouterRef = ProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
