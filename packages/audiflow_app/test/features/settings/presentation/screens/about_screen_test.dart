import 'package:audiflow_app/features/settings/presentation/screens/about_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  late PackageInfo packageInfo;

  setUp(() {
    packageInfo = PackageInfo(
      appName: 'Audiflow',
      packageName: 'com.audiflow.app',
      version: '1.0.0',
      buildNumber: '42',
    );
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [packageInfoProvider.overrideWithValue(packageInfo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AboutScreen(),
      ),
    );
  }

  group('AboutScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with About title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('About'));
    });

    testWidgets('shows app name in header', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Audiflow'), findsOneWidget);
      expect(find.text('Your podcast companion'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.0.0 (42)'), findsOneWidget);
    });

    testWidgets('shows Open Source Licenses tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('shows Send Feedback tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('shows Rate the App tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Rate the App'), findsOneWidget);
    });

    testWidgets('tapping Send Feedback shows coming soon snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('tapping Rate the App shows coming soon snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
    });
  });
}
