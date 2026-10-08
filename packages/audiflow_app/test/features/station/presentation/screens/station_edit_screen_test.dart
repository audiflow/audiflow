import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_edit_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import '../station_fakes.dart';

Station _station(int id, String name) => Station()
  ..id = id
  ..name = name
  ..createdAt = DateTime(2026)
  ..updatedAt = DateTime(2026);

void main() {
  late FakeStationRepository stations;

  setUp(() => stations = FakeStationRepository());

  Future<void> pump(
    WidgetTester tester, {
    int? stationId,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stationRepositoryProvider.overrideWithValue(stations),
          stationPodcastRepositoryProvider.overrideWithValue(
            FakeStationPodcastRepository(),
          ),
          stationEpisodeRepositoryProvider.overrideWithValue(
            FakeStationEpisodeRepository(),
          ),
          stationReconcilerServiceProvider.overrideWithValue(FakeReconciler()),
          subscriptionRepositoryProvider.overrideWithValue(
            FakeSubscriptionRepository(),
          ),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(<Subscription>[]),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StationEditScreen(stationId: stationId),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  EditableText nameField(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText).first);

  testWidgets('a new station starts with its default name selected', (
    tester,
  ) async {
    await stations.create(_station(0, 'Station 1'));
    await stations.create(_station(0, 'News'));
    await pump(tester);
    final field = nameField(tester);
    final value = field.controller.value;
    check(value.text).equals('Station 2');
    check(value.selection.start).equals(0);
    check(value.selection.end).equals('Station 2'.length);
    check(field.focusNode.hasFocus).isTrue();
  });

  testWidgets('an existing station does not take focus', (tester) async {
    await stations.create(_station(0, 'Morning'));
    await pump(tester, stationId: 1);
    final field = nameField(tester);
    check(field.controller.text).equals('Morning');
    check(field.focusNode.hasFocus).isFalse();
  });

  testWidgets('has no save button', (tester) async {
    await pump(tester);
    check(find.text('Save').evaluate()).isEmpty();
  });

  testWidgets('a name typed while stations load is kept', (tester) async {
    stations.listGate = Completer<void>();
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'Commute');
    stations.listGate!.complete();
    await tester.pumpAndSettle();
    check(nameField(tester).controller.text).equals('Commute');
  });

  testWidgets('an existing station cannot be edited until it loads', (
    tester,
  ) async {
    await stations.create(_station(0, 'Morning'));
    stations.findGate = Completer<void>();
    await pump(tester, stationId: 1, settle: false);
    check(find.byType(TextField).evaluate()).isEmpty();
    check(find.byType(CircularProgressIndicator).evaluate()).length.equals(1);

    stations.findGate!.complete();
    await tester.pumpAndSettle();
    check(nameField(tester).controller.text).equals('Morning');
  });

  testWidgets('a failed load offers a retry instead of the form', (
    tester,
  ) async {
    await pump(tester, stationId: 99);
    check(find.byType(TextField).evaluate()).isEmpty();
    check(find.text("Couldn't load this station.").evaluate()).length.equals(1);
    check(find.text('Retry').evaluate()).length.equals(1);
  });
}
