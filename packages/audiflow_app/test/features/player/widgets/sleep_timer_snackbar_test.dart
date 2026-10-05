import 'dart:async';

import 'package:audiflow_app/features/player/presentation/controllers/sleep_timer_ui_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> container(
  Stream<PlayerLifecycleEvent> lifecycle,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      playerLifecycleEventsProvider.overrideWith((ref) => lifecycle),
    ],
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
  late StreamController<PlayerLifecycleEvent> lifecycle;

  setUp(() {
    lifecycle = StreamController<PlayerLifecycleEvent>.broadcast();
    addTearDown(lifecycle.close);
  });

  Future<ProviderContainer> pumpHost(WidgetTester tester) async {
    final c = await container(lifecycle.stream);
    addTearDown(c.dispose);
    await tester.pumpWidget(
      wrap(c, const SleepTimerSnackbarHost(child: SizedBox.shrink())),
    );
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('SleepTimerSnackbarHost mounts without error', (tester) async {
    await pumpHost(tester);

    expect(find.byType(SleepTimerSnackbarHost), findsOneWidget);
  });

  testWidgets('says so when leaving the target cancels the timer', (
    tester,
  ) async {
    final c = await pumpHost(tester);
    c.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();

    lifecycle.add(const EpisodeSwitchedLifecycle());
    await tester.pump();
    await tester.pump();

    expect(find.text('Sleep timer cancelled'), findsOneWidget);
  });

  testWidgets('shows nothing when the timer is turned off directly', (
    tester,
  ) async {
    final c = await pumpHost(tester);
    final notifier = c.read(sleepTimerControllerProvider.notifier)
      ..setEndOfEpisode();

    notifier.setOff();
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
