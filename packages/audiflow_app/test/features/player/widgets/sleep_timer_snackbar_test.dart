import 'package:audiflow_app/features/player/presentation/controllers/sleep_timer_ui_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('SleepTimerSnackbarHost mounts without error', (tester) async {
    final c = await container();
    addTearDown(c.dispose);

    await tester.pumpWidget(
      wrap(c, const SleepTimerSnackbarHost(child: SizedBox.shrink())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SleepTimerSnackbarHost), findsOneWidget);
  });
}
