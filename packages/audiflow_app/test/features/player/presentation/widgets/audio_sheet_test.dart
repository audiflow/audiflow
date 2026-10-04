import 'package:audiflow_app/features/player/presentation/widgets/audio_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    double? height,
    double textScale = 1,
  }) {
    final sheet = AudioSheet(
      speed: speed,
      chipSpeeds: chipSpeeds,
      onSpeedPreview: previews.add,
      onSpeedCommit: commits.add,
    );
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
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
}
