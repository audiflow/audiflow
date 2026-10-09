import 'package:audiflow_app/app/haptics/haptics_providers.dart';
import 'package:audiflow_app/features/settings/presentation/screens/haptics_catalog_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

/// Mirrors the app root: the scope player follows the level provider, so
/// the screen exercises the same gating the real app applies.
class _ScopedApp extends ConsumerWidget {
  const _ScopedApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HapticsScope(
      player: ref.watch(hapticPlayerProvider),
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: HapticsCatalogScreen(),
      ),
    );
  }
}

void main() {
  late SharedPreferences prefs;
  late _RecordingHapticPlayer recorder;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    recorder = _RecordingHapticPlayer();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Tall enough that the lazy list builds every token row.
    tester.view
      ..physicalSize = const Size(400, 3000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          platformHapticPlayerProvider.overrideWithValue(recorder),
        ],
        child: const _ScopedApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every token', (tester) async {
    await pumpScreen(tester);
    for (final token in HapticToken.values) {
      check(find.text(token.name).evaluate()).isNotEmpty();
    }
  });

  testWidgets('tapping a row plays its token', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('thresholdCross'));
    await tester.tap(find.text('error'));
    check(
      recorder.played,
    ).deepEquals([HapticToken.thresholdCross, HapticToken.error]);
  });

  testWidgets('the level selector changes the saved level and gating', (
    tester,
  ) async {
    await pumpScreen(tester);
    // Reduced is the default: only outcome tokens such as success play.
    await tester.tap(find.text('selection'));
    await tester.tap(find.text('success'));
    check(recorder.played).deepEquals([HapticToken.success]);
    recorder.played.clear();

    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();

    check(
      prefs.getString(SettingsKeys.hapticFeedbackLevel),
    ).equals(HapticFeedbackLevel.off.name);

    await tester.tap(find.text('selection'));
    await tester.tap(find.text('success'));
    check(recorder.played).isEmpty();
  });
}
