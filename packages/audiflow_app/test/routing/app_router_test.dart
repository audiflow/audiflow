import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter', () {
    testWidgets('search route is defined and navigates to SearchScreen',
        (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate to search route
      router.go('/search');
      await tester.pumpAndSettle();

      // Verify SearchScreen is displayed (Requirement 2.3)
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('search route is accessible from home navigation',
        (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Initial route should be home
      await tester.pumpAndSettle();

      // Navigate to search route
      router.go('/search');
      await tester.pumpAndSettle();

      // Search screen should be accessible
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    test('router configuration includes search route', () {
      final router = createAppRouter();

      // Verify the router can match the search path
      final match = router.routeInformationParser.configuration.findMatch(
        Uri.parse('/search'),
      );
      expect(match, isNotNull);
    });
  });
}
