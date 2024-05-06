part of 'package:audiflow/ui/app/router/router.dart';

@TypedStatefulShellRoute<MainPageShellRoute>(
  branches: [
    homeShellBranch,
    searchShellBranch,
    libraryShellBranch,
  ],
)
class MainPageShellRoute extends StatefulShellRouteData {
  const MainPageShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainPage(navigationShell: navigationShell);
  }
}
