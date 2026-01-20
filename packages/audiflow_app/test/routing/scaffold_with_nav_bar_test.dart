import 'package:audiflow_app/routing/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('ScaffoldWithNavBar', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/a',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ScaffoldWithNavBar(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/a',
                    builder: (context, state) =>
                        const Center(child: Text('Tab A')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/b',
                    builder: (context, state) =>
                        const Center(child: Text('Tab B')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/c',
                    builder: (context, state) =>
                        const Center(child: Text('Tab C')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets('renders NavigationBar with three destinations', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('displays correct destination labels', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays correct destination icons', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byIcon(Symbols.search), findsOneWidget);
      expect(find.byIcon(Symbols.library_music), findsOneWidget);
      expect(find.byIcon(Symbols.settings), findsOneWidget);
    });

    testWidgets('selectedIndex reflects current tab', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Initial tab is 0
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, equals(0));
    });

    testWidgets('tapping destination calls goBranch', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Initially on Tab A
      expect(find.text('Tab A'), findsOneWidget);

      // Tap Library destination (index 1)
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      // Should now be on Tab B
      expect(find.text('Tab B'), findsOneWidget);

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, equals(1));
    });

    testWidgets('renders navigation shell as body', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(ScaffoldWithNavBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
