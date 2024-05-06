part of 'package:audiflow/ui/app/router/router.dart';

const homeShellBranch = TypedStatefulShellBranch<HomeShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomePageRoute>(
      path: HomePageRoute.path,
      routes: [
        TypedGoRoute<DebugPageRoute>(
          path: DebugPageRoute.path,
        ),
        TypedGoRoute<HomeSettingPageRoute>(
          path: HomeSettingPageRoute.path,
          name: HomeSettingPageRoute.name,
        ),
      ],
    ),
  ],
);

class HomeShellBranch extends StatefulShellBranchData {
  const HomeShellBranch();
}

class HomePageRoute extends GoRouteData {
  const HomePageRoute();

  static const path = '/';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CustomAppLifecycleListener(
      onResume: () {
        // Example: Obtain the latest AppStatus and update if needed.
      },
      // By overriding the Provider in the Route build method, it is possible to
      // switch the implementation of Navigator based on the source of
      // navigation or the state.
      child: ProviderScope(
        overrides: [
          homeNavigatorProvider.overrideWithValue(const HomeNavigator()),
        ],
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Mode'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            ref.read(homeNavigatorProvider).pushSettingPage(context);
          },
          child: const Text('Setting'),
        ),
      ),
    );
  }
}
