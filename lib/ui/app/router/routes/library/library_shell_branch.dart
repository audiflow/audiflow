part of 'package:audiflow/ui/app/router/router.dart';

const libraryShellBranch = TypedStatefulShellBranch<LibraryShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<LibraryPageRoute>(
      path: LibraryPageRoute.path,
      routes: [
        TypedGoRoute<LicensePageRoute>(
          path: LicensePageRoute.path,
        ),
      ],
    ),
  ],
);

class LibraryShellBranch extends StatefulShellBranchData {
  const LibraryShellBranch();
}

class LibraryPageRoute extends GoRouteData {
  const LibraryPageRoute();

  static const path = '/library';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProviderScope(
      overrides: [
        libraryNavigatorProvider.overrideWithValue(
          const LibraryNavigator(),
        ),
      ],
      child: const LibraryPage(),
    );
  }
}

class LicensePageRoute extends GoRouteData {
  const LicensePageRoute();

  static const path = 'license';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LicensePage();
  }
}

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Mode'),
      ),
      body: const Center(
        child: Text('Library Mode'),
      ),
    );
  }
}
