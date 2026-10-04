import 'package:audiflow_app/features/player/presentation/widgets/audio_sheet.dart';
import 'package:audiflow_app/features/player/presentation/widgets/player_action_row.dart';
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_icon_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/player_stubs.dart';

void main() {
  Future<ProviderContainer> container() async {
    SharedPreferences.setMockInitialValues({'settings_playback_speed': 1.3});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        audioPlayerControllerProvider.overrideWith(
          () => StubAudioPlayerController(const PlaybackState.idle()),
        ),
        currentEpisodeHasChaptersProvider.overrideWith((ref) async => false),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget host(ProviderContainer container, {Widget? outputPicker}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PlayerActionRow(outputPicker: outputPicker)),
      ),
    );
  }

  testWidgets('shows the Audio button with the speed and the sleep timer', (
    tester,
  ) async {
    await tester.pumpWidget(host(await container()));

    expect(find.widgetWithText(AudioButton, '1.3x'), findsOneWidget);
    expect(find.byType(SleepTimerIconButton), findsOneWidget);
  });

  testWidgets('hides the output picker slot until one is provided', (
    tester,
  ) async {
    const pickerKey = Key('picker');
    final c = await container();
    await tester.pumpWidget(host(c));
    expect(find.byType(Expanded), findsNWidgets(2));

    await tester.pumpWidget(
      host(c, outputPicker: const SizedBox(key: pickerKey)),
    );
    expect(find.byKey(pickerKey), findsOneWidget);
    expect(find.byType(Expanded), findsNWidgets(3));
  });

  testWidgets('tapping the Audio button opens the Audio sheet', (tester) async {
    await tester.pumpWidget(host(await container()));

    await tester.tap(find.byType(AudioButton));
    await tester.pumpAndSettle();

    expect(find.byType(AudioSheet), findsOneWidget);
    final sheet = tester.widget<AudioSheet>(find.byType(AudioSheet));
    expect(sheet.speed, 1.3);
  });
}
