import 'package:audiflow_app/features/player/presentation/widgets/audio_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/player_stubs.dart';

/// In-memory override store; the global speed is fixed at 1.0.
class _MemoryOverrides implements PodcastAudioPreferenceRepository {
  final Map<int, AudioSettings> rows = {};

  @override
  Future<AudioSettings?> get(int podcastId) async => rows[podcastId];

  @override
  Future<void> set(int podcastId, AudioSettings settings) async =>
      rows[podcastId] = settings;

  @override
  Future<void> clear(int podcastId) async => rows.remove(podcastId);

  @override
  Future<AudioSettings> resolveForPodcast(int podcastId) async =>
      rows[podcastId] ??
      const AudioSettings(speed: 1.0, effects: PlaybackEffects.off);
}

void main() {
  late List<double> previews;
  late List<double> commits;

  setUp(() {
    previews = [];
    commits = [];
  });

  Widget host({
    required double speed,
    required List<double> chipSpeeds,
    bool? podcastOverride,
    ValueChanged<bool>? onPodcastOverrideChanged,
    double? height,
    double textScale = 1,
  }) {
    final sheet = AudioSheet(
      speed: speed,
      chipSpeeds: chipSpeeds,
      onSpeedPreview: previews.add,
      onSpeedCommit: commits.add,
      podcastOverride: podcastOverride,
      onPodcastOverrideChanged: onPodcastOverrideChanged,
    );
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: height == null
            ? sheet
            : Align(
                alignment: Alignment.topCenter,
                child: SizedBox(height: height, child: sheet),
              ),
      ),
    );
  }

  List<String> chipLabels(WidgetTester tester) => tester
      .widgetList<ChoiceChip>(find.byType(ChoiceChip))
      .map((chip) => (chip.label as Text).data!)
      .toList();

  testWidgets('scrolls instead of overflowing in a short sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(speed: 1.3, chipSpeeds: [0.8, 1.0, 1.3], height: 120, textScale: 2),
    );

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byType(PlaybackSpeedSlider),
      50,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(PlaybackSpeedSlider).hitTestable(), findsOneWidget);
  });

  testWidgets('shows title, chips, and the slider without a big readout', (
    tester,
  ) async {
    await tester.pumpWidget(host(speed: 1.3, chipSpeeds: [1.0, 1.3]));

    expect(find.text('Audio'), findsOneWidget);
    // Only the selected chip shows the current speed.
    expect(find.text('1.3x'), findsOneWidget);
    expect(find.byType(PlaybackSpeedSlider), findsOneWidget);
    for (final label in ['0.5x', '1.0x', '2.0x', '3.0x']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('renders chips in the given ascending order', (tester) async {
    await tester.pumpWidget(host(speed: 1.0, chipSpeeds: [0.8, 1.0, 2.0]));

    expect(chipLabels(tester), ['0.8x', 'Normal', '2.0x']);
  });

  testWidgets('highlights only the chip matching the current speed', (
    tester,
  ) async {
    await tester.pumpWidget(host(speed: 2.0, chipSpeeds: [1.0, 1.5, 2.0]));

    final selected = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((chip) => chip.selected)
        .map((chip) => (chip.label as Text).data)
        .toList();
    expect(selected, ['2.0x']);
  });

  testWidgets('tapping a chip commits its speed', (tester) async {
    await tester.pumpWidget(host(speed: 2.0, chipSpeeds: [1.0, 2.0]));

    await tester.tap(find.text('Normal'));

    expect(commits, [1.0]);
    expect(previews, isEmpty);
  });

  testWidgets('tapping the already selected chip commits nothing', (
    tester,
  ) async {
    await tester.pumpWidget(host(speed: 2.0, chipSpeeds: [1.0, 2.0]));

    await tester.tap(find.widgetWithText(ChoiceChip, '2.0x'));

    expect(commits, isEmpty);
  });

  group('podcast override switch', () {
    testWidgets('is hidden without a podcast', (tester) async {
      await tester.pumpWidget(host(speed: 1.0, chipSpeeds: [1.0]));

      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('off: controls edit the global settings', (tester) async {
      await tester.pumpWidget(
        host(
          speed: 1.0,
          chipSpeeds: [1.0, 1.5],
          podcastOverride: false,
          onPodcastOverrideChanged: (_) {},
        ),
      );

      expect(find.text('Custom for this podcast'), findsOneWidget);
      expect(find.text('Applies to all podcasts'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
    });

    testWidgets('on: caption names this podcast, controls stay enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          speed: 1.5,
          chipSpeeds: [1.0, 1.5],
          podcastOverride: true,
          onPodcastOverrideChanged: (_) {},
        ),
      );

      expect(find.text('This podcast only'), findsOneWidget);
      await tester.tap(find.text('Normal'));
      expect(commits, [1.0]);
    });

    testWidgets('toggling reports the new value', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        host(
          speed: 1.0,
          chipSpeeds: [1.0],
          podcastOverride: false,
          onPodcastOverrideChanged: changes.add,
        ),
      );

      await tester.tap(find.byType(Switch));

      expect(changes, [true]);
    });
  });

  group('showAudioSheet for a podcast', () {
    late _MemoryOverrides overrides;

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsRepositoryProvider.overrideWithValue(
              StubAppSettingsRepository(),
            ),
            podcastAudioPreferenceRepositoryProvider.overrideWithValue(
              overrides,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAudioSheet(context, podcastId: 7),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    setUp(() => overrides = _MemoryOverrides());

    testWidgets('shows the override and turning it off deletes it', (
      tester,
    ) async {
      overrides.rows[7] = const AudioSettings(
        speed: 1.5,
        effects: PlaybackEffects.off,
      );
      await open(tester);

      expect(find.text('This podcast only'), findsOneWidget);
      expect(
        tester
            .widget<PlaybackSpeedSlider>(find.byType(PlaybackSpeedSlider))
            .speed,
        1.5,
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(overrides.rows, isEmpty);
      expect(find.text('Applies to all podcasts'), findsOneWidget);
      expect(
        tester
            .widget<PlaybackSpeedSlider>(find.byType(PlaybackSpeedSlider))
            .speed,
        1.0,
      );
    });

    testWidgets('turning it on copies the global speed', (tester) async {
      await open(tester);

      expect(find.text('Applies to all podcasts'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(
        overrides.rows[7],
        const AudioSettings(speed: 1.0, effects: PlaybackEffects.off),
      );
      expect(find.text('This podcast only'), findsOneWidget);
    });
  });
}
