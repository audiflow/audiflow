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

  Widget host({required double speed, required List<double> chipSpeeds}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AudioSheet(
          speed: speed,
          chipSpeeds: chipSpeeds,
          onSpeedPreview: previews.add,
          onSpeedCommit: commits.add,
        ),
      ),
    );
  }

  List<String> chipLabels(WidgetTester tester) => tester
      .widgetList<ChoiceChip>(find.byType(ChoiceChip))
      .map((chip) => (chip.label as Text).data!)
      .toList();

  testWidgets('shows title, large readout, and the slider', (tester) async {
    await tester.pumpWidget(host(speed: 1.3, chipSpeeds: [1.0, 1.3]));

    expect(find.text('Audio'), findsOneWidget);
    // Readout plus the selected chip.
    expect(find.text('1.3x'), findsNWidgets(2));
    expect(find.byType(PlaybackSpeedSlider), findsOneWidget);
    expect(find.text('0.5x'), findsOneWidget);
    expect(find.text('3.0x'), findsOneWidget);
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
