import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/station/presentation/controllers/station_edit_controller.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_edit_screen.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_podcast_picker_screen.dart';
import 'package:audiflow_app/features/station/presentation/widgets/episode_limit_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
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
  late FakeStationPodcastRepository stationPodcasts;
  var subscriptions = <Subscription>[];

  setUp(() {
    stations = FakeStationRepository();
    stationPodcasts = FakeStationPodcastRepository();
    subscriptions = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    int? stationId,
    bool openPodcastPicker = false,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stationRepositoryProvider.overrideWithValue(stations),
          stationPodcastRepositoryProvider.overrideWithValue(stationPodcasts),
          stationEpisodeRepositoryProvider.overrideWithValue(
            FakeStationEpisodeRepository(),
          ),
          stationReconcilerServiceProvider.overrideWithValue(FakeReconciler()),
          subscriptionRepositoryProvider.overrideWithValue(
            FakeSubscriptionRepository(),
          ),
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(subscriptions),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StationEditScreen(
            stationId: stationId,
            openPodcastPicker: openPodcastPicker,
          ),
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

  testWidgets('opens podcast selection once loaded when asked', (tester) async {
    await stations.create(_station(0, 'Morning'));
    await pump(tester, stationId: 1, openPodcastPicker: true);
    check(find.byType(StationPodcastPickerScreen).evaluate()).length.equals(1);
  });

  testWidgets('does not open podcast selection by default', (tester) async {
    await stations.create(_station(0, 'Morning'));
    await pump(tester, stationId: 1);
    check(find.byType(StationPodcastPickerScreen).evaluate()).isEmpty();
  });

  group('per-podcast episode limit', () {
    Future<void> pumpWithPodcast(
      WidgetTester tester, {
      int? episodeLimit,
    }) async {
      // Tall enough that the podcast row and every sheet option are on screen.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await stations.create(_station(0, 'Morning')..defaultEpisodeLimit = 3);
      await stationPodcasts.add(1, 7, episodeLimit: episodeLimit);
      subscriptions = [
        Subscription()
          ..id = 7
          ..itunesId = 'itunes-7'
          ..feedUrl = 'https://example.com/7.xml'
          ..title = 'Daily Show'
          ..artistName = 'Host',
      ];
      await pump(tester, stationId: 1);
    }

    Finder inSheet(Finder finder) =>
        find.descendant(of: find.byType(EpisodeLimitSheet), matching: finder);

    EpisodeLimitMode selectedMode(WidgetTester tester) => tester
        .widget<AppSegmentedControl<EpisodeLimitMode>>(
          find.byType(AppSegmentedControl<EpisodeLimitMode>),
        )
        .selected;

    Finder rowLabel(String label) => find.descendant(
      of: find.widgetWithText(ListTile, 'Daily Show'),
      matching: find.text(label),
    );

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.text('Daily Show'));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping a podcast opens the sheet on the default', (
      tester,
    ) async {
      await pumpWithPodcast(tester);
      await openSheet(tester);

      check(find.byType(EpisodeLimitSheet).evaluate()).length.equals(1);
      check(inSheet(find.text('Default (3)')).evaluate()).length.equals(1);
      check(selectedMode(tester)).equals(EpisodeLimitMode.stationDefault);
    });

    testWidgets('a typed count stores the override and closes the sheet', (
      tester,
    ) async {
      await pumpWithPodcast(tester);
      await openSheet(tester);
      await tester.tap(inSheet(find.text('1')));
      await tester.tap(inSheet(find.text('2')));
      await tester.pump();
      await tester.tap(inSheet(find.widgetWithText(FilledButton, 'Set')));
      await tester.pumpAndSettle();

      check(find.byType(EpisodeLimitSheet).evaluate()).isEmpty();
      check(rowLabel('Latest 12').evaluate()).length.equals(1);
    });

    testWidgets('tapping All overrides a numeric default', (tester) async {
      await pumpWithPodcast(tester);
      await openSheet(tester);
      await tester.tap(inSheet(find.text('All')));
      await tester.pumpAndSettle();

      check(find.byType(EpisodeLimitSheet).evaluate()).isEmpty();
      check(rowLabel('All').evaluate()).length.equals(1);
      await openSheet(tester);
      check(selectedMode(tester)).equals(EpisodeLimitMode.all);
    });

    testWidgets('tapping default clears an existing override', (tester) async {
      await pumpWithPodcast(tester, episodeLimit: allEpisodesSentinel);
      check(rowLabel('All').evaluate()).length.equals(1);

      await openSheet(tester);
      check(selectedMode(tester)).equals(EpisodeLimitMode.all);
      await tester.tap(inSheet(find.text('Default (3)')));
      await tester.pumpAndSettle();

      check(rowLabel('Latest 3').evaluate()).length.equals(1);
    });
  });

  testWidgets('the station-wide limit takes a typed count', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await stations.create(_station(0, 'Morning')..defaultEpisodeLimit = 3);
    await pump(tester, stationId: 1);

    await tester.tap(find.widgetWithText(ListTile, 'Episodes'));
    await tester.pumpAndSettle();
    check(find.text('Default for this station').evaluate()).length.equals(1);
    await tester.tap(
      find.descendant(
        of: find.byType(EpisodeLimitSheet),
        matching: find.text('7'),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Set'));
    await tester.pumpAndSettle();

    final row = find.widgetWithText(ListTile, 'Episodes');
    check(
      find.descendant(of: row, matching: find.text('Latest 7')).evaluate(),
    ).length.equals(1);
  });
}
