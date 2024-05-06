part of 'package:audiflow/ui/app/router/router.dart';

const searchShellBranch = TypedStatefulShellBranch<SearchShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<SearchPageRoute>(
      path: SearchPageRoute.path,
    ),
  ],
);

class SearchShellBranch extends StatefulShellBranchData {
  const SearchShellBranch();
}

class SearchPageRoute extends GoRouteData {
  const SearchPageRoute();

  static const path = '/search';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProviderScope(
      overrides: [
        searchNavigatorProvider.overrideWithValue(
          const SearchNavigator(),
        ),
      ],
      child: const SearchPage(),
    );
  }
}

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Mode'),
      ),
      body: const Center(
        child: Text('Search Mode'),
      ),
    );
  }
}
