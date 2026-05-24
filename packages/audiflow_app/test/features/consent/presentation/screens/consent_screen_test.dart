import 'package:audiflow_app/features/consent/presentation/controllers/privacy_consent_controller.dart';
import 'package:audiflow_app/features/consent/presentation/screens/consent_screen.dart';
import 'package:audiflow_app/features/consent/presentation/utils/in_app_browser_launcher_provider.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingLauncher {
  Uri? launched;

  Future<bool> call(Uri uri) async {
    launched = uri;
    return true;
  }
}

Future<Widget> _wrap({
  required Widget child,
  required List<dynamic> overrides,
  Locale locale = const Locale('en'),
}) async {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Continue button is disabled before user agrees', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      await _wrap(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ConsentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final continueButton = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    check(continueButton.onPressed).isNull();
  });

  testWidgets('checking the agree box enables Continue', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      await _wrap(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ConsentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final continueButton = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    check(continueButton.onPressed).isNotNull();
  });

  testWidgets('Read full policy opens in-app browser with en URL', (
    tester,
  ) async {
    final launcher = _RecordingLauncher();
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      await _wrap(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          inAppBrowserLauncherProvider.overrideWithValue(launcher.call),
        ],
        child: const ConsentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Read full Privacy Policy'));
    await tester.pump();

    check(launcher.launched).isNotNull();
    final uri = launcher.launched!;
    check(uri.host).equals('company.reedom.com');
    check(uri.path).equals('/audiflow/privacy-policy');
    check(uri.queryParameters['lang']).equals('en');
    check(uri.queryParameters['embed']).equals('1');
  });

  testWidgets('Read full policy opens ja URL when locale is ja', (
    tester,
  ) async {
    final launcher = _RecordingLauncher();
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      await _wrap(
        locale: const Locale('ja'),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          inAppBrowserLauncherProvider.overrideWithValue(launcher.call),
        ],
        child: const ConsentScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('プライバシーポリシー全文を読む'));
    await tester.pump();

    check(launcher.launched!.queryParameters['lang']).equals('ja');
  });

  testWidgets('Continue persists consent and navigates to /onboarding', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/consent',
      routes: [
        GoRoute(path: '/consent', builder: (_, _) => const ConsentScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Scaffold(body: Text('ONBOARDING')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    check(
      container.read(appSettingsRepositoryProvider).getPrivacyConsentAccepted(),
    ).isFalse();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    check(
      container.read(appSettingsRepositoryProvider).getPrivacyConsentAccepted(),
    ).isTrue();
    check(container.read(privacyConsentControllerProvider)).isTrue();
    expect(find.text('ONBOARDING'), findsOneWidget);
  });
}
