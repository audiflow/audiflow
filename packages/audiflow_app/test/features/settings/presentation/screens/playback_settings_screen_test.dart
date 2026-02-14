import 'package:audiflow_app/features/settings/presentation/screens/playback_settings_screen.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
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
      child: const MaterialApp(home: PlaybackSettingsScreen()),
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
      expect(find.byType(Slider), findsOneWidget);
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
  });
}
