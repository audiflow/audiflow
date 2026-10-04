import 'package:audiflow_app/features/settings/presentation/screens/playback_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
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

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PlaybackSettingsScreen(),
      ),
    );
  }

  group('PlaybackSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(PlaybackSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Playback title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Playback'));
    });

    testWidgets('shows playback speed with 1.0x default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Default Playback Speed'), findsOneWidget);
      expect(find.text('1.0x'), findsOneWidget);
      expect(find.byType(PlaybackSpeedSlider), findsOneWidget);
    });

    testWidgets('rounds a legacy off-grid speed to the nearest step', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'settings_playback_speed': 1.25});
      prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('1.3x'), findsOneWidget);
      final slider = tester.widget<PlaybackSpeedSlider>(
        find.byType(PlaybackSpeedSlider),
      );
      expect(slider.speed, 1.3);
    });

    testWidgets('reflects speed changes made elsewhere', (tester) async {
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
            home: const PlaybackSettingsScreen(),
          ),
        ),
      );

      await container
          .read(playbackSpeedSettingsControllerProvider.notifier)
          .save(2.4, recordRecent: true);
      await tester.pump();

      expect(find.text('2.4x'), findsOneWidget);
    });

    testWidgets('shows skip forward with 30 default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Skip Forward (seconds)'), findsOneWidget);

      final segmented = tester.widget<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>).first,
      );
      expect(segmented.selected, equals({30}));
    });

    testWidgets('shows skip backward with 10 default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Skip Backward (seconds)'), findsOneWidget);

      final segmented = tester.widget<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>).last,
      );
      expect(segmented.selected, equals({10}));
    });

    testWidgets('shows auto-complete threshold at 95%', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Auto-Complete Threshold'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      // Speed slider plus threshold slider.
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('shows continuous playback enabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuous Playback'), findsOneWidget);

      final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(toggle.value, isTrue);
    });

    testWidgets('toggling continuous playback updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(toggle.value, isFalse);
    });

    testWidgets(
      'tapping skip forward segment persists and reflects new value',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Default is 30; tap '45' segment
        await tester.tap(find.text('45'));
        await tester.pumpAndSettle();

        final segmented = tester.widget<SegmentedButton<int>>(
          find.byType(SegmentedButton<int>).first,
        );
        expect(segmented.selected, equals({45}));

        // Verify persisted: value survives provider invalidation
        expect(prefs.getInt('settings_skip_forward_seconds'), equals(45));
      },
    );
  });
}
