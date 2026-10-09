import 'package:audiflow_app/app/haptics/haptics_providers.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/locale_controller.dart';
import 'package:audiflow_app/features/settings/presentation/screens/appearance_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget({bool hapticsSupported = true}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        hapticsSupportedProvider.overrideWithValue(
          AsyncData(hapticsSupported),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AppearanceSettingsScreen(),
      ),
    );
  }

  group('AppearanceSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppearanceSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Appearance title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Appearance'));
    });

    testWidgets('shows theme mode setting with System default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      // "System" appears in both theme mode and language controls
      expect(find.text('System'), findsWidgets);

      // System should be selected by default
      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, equals({ThemeMode.system}));
    });

    testWidgets('shows language setting with System default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Language'), findsOneWidget);
      // Default dropdown should show System
      expect(find.text('System'), findsWidgets);
    });

    testWidgets('shows text size setting with Medium default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      final segmented = tester.widget<SegmentedButton<double>>(
        find.byType(SegmentedButton<double>),
      );
      expect(segmented.selected, equals({1.0}));
    });

    testWidgets('shows preview text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Preview text at current size'), findsOneWidget);
    });

    testWidgets('changing theme mode updates selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap Dark segment
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, equals({ThemeMode.dark}));
    });

    testWidgets('selecting a language updates the locale controller', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppearanceSettingsScreen(),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<Locale?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Japanese').last);
      await tester.pumpAndSettle();

      check(
        container.read(localeControllerProvider),
      ).equals(const Locale('ja'));
      check(prefs.getString(SettingsKeys.locale)).equals('ja');
    });
  });

  group('AppearanceSettingsScreen TickerMode pause/resume', () {
    // Regression for rrousselGit/riverpod#4709 (see #479): resuming a
    // hidden screen after an upstream provider was invalidated must not
    // trip Riverpod's pausedActiveSubscriptionCount debug assertion.
    testWidgets('survives repository invalidation while hidden', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final tickerEnabled = ValueNotifier(true);
      addTearDown(tickerEnabled.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ValueListenableBuilder<bool>(
              valueListenable: tickerEnabled,
              builder: (context, enabled, child) =>
                  TickerMode(enabled: enabled, child: child!),
              child: const AppearanceSettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      tickerEnabled.value = false;
      await tester.pump();
      container.invalidate(appSettingsRepositoryProvider);
      await tester.pump();
      tickerEnabled.value = true;
      await tester.pumpAndSettle();

      check(tester.takeException()).isNull();
      check(
        find.byType(SegmentedButton<ThemeMode>).evaluate(),
      ).length.equals(1);
    });

    testWidgets('haptic feedback level defaults to Reduced and persists', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(800, 2000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestWidget());

      check(find.text('Haptic feedback').evaluate()).isNotEmpty();
      final selector = tester.widget<SegmentedButton<HapticFeedbackLevel>>(
        find.byType(SegmentedButton<HapticFeedbackLevel>),
      );
      check(selector.selected).deepEquals({HapticFeedbackLevel.reduced});

      await tester.tap(find.text('On'));
      await tester.pumpAndSettle();

      check(
        prefs.getString(SettingsKeys.hapticFeedbackLevel),
      ).equals(HapticFeedbackLevel.on.name);
      check(
        find.text('This device does not support haptic feedback').evaluate(),
      ).isEmpty();
    });

    testWidgets('haptic feedback is locked to Off without device support', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(800, 2000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestWidget(hapticsSupported: false));

      final selector = tester.widget<SegmentedButton<HapticFeedbackLevel>>(
        find.byType(SegmentedButton<HapticFeedbackLevel>),
      );
      check(selector.selected).deepEquals({HapticFeedbackLevel.off});
      check(selector.onSelectionChanged).isNull();
      check(
        find.text('This device does not support haptic feedback').evaluate(),
      ).isNotEmpty();

      await tester.tap(find.text('On'));
      await tester.pumpAndSettle();
      check(prefs.getString(SettingsKeys.hapticFeedbackLevel)).isNull();
    });
  });
}
