import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_icon_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

Widget wrap(ProviderContainer c, Widget child) {
  return UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('icon is outlined when timer is off', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerIconButton()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.nights_stay_outlined), findsOneWidget);
  });

  testWidgets('icon is filled when timer is active', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerIconButton()));
    await tester.pumpAndSettle();

    c.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
  });
}
