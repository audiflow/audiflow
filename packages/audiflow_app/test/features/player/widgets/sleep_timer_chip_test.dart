import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_chip.dart';
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders nothing when timer is off', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNothing);
  });

  testWidgets('renders Episode end label when endOfEpisode active', (
    tester,
  ) async {
    final c = await container();
    addTearDown(c.dispose);
    c.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · Episode end'), findsOneWidget);
  });

  testWidgets('renders Chapter end label when endOfChapter active', (
    tester,
  ) async {
    final c = await container();
    addTearDown(c.dispose);
    c.read(sleepTimerControllerProvider.notifier).setEndOfChapter();

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · Chapter end'), findsOneWidget);
  });

  testWidgets('renders N eps left when episodes active', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await c.read(sleepTimerControllerProvider.notifier).setEpisodes(3);

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · 3 eps left'), findsOneWidget);
  });
}
