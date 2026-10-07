import 'dart:ui' show Tristate;

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required String selected, ValueChanged<String>? onChanged}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: AppSegmentedControl<String>(
              segments: const [('episodes', 'Episodes'), ('series', 'Series')],
              selected: selected,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  group('AppSegmentedControl', () {
    testWidgets('sunken pill track with a surface thumb', (tester) async {
      await tester.pumpWidget(host(selected: 'episodes'));
      final track =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(AppSegmentedControl.trackKey),
                  )
                  .decoration
              as BoxDecoration;
      check(track.color).equals(AppColors.light.surfaceSunken);
      check(track.borderRadius).equals(AppBorders.pill);
      final thumb =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(AppSegmentedControl.thumbKey),
                  )
                  .decoration
              as BoxDecoration;
      check(thumb.color).equals(AppColors.light.surface);
    });

    testWidgets('thumb sits under the selected segment', (tester) async {
      await tester.pumpWidget(host(selected: 'series'));
      await tester.pumpAndSettle();
      final thumb = tester.getRect(find.byKey(AppSegmentedControl.thumbKey));
      final label = tester.getCenter(find.text('Series'));
      check(thumb.contains(label)).isTrue();
    });

    testWidgets('selected label is ink and bold, the other secondary', (
      tester,
    ) async {
      await tester.pumpWidget(host(selected: 'episodes'));
      final on = tester.widget<Text>(find.text('Episodes')).style!;
      final off = tester.widget<Text>(find.text('Series')).style!;
      check(on.color).equals(AppColors.light.ink);
      check(on.fontWeight).equals(FontWeight.w600);
      check(off.color).equals(AppColors.light.inkSecondary);
    });

    testWidgets('tapping a segment reports its value', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(host(selected: 'episodes', onChanged: log.add));
      await tester.tap(find.text('Series'));
      check(log).deepEquals(['series']);
    });

    testWidgets('segments are selectable buttons for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(selected: 'series'));
      final node = tester.getSemantics(find.text('Series'));
      check(node.flagsCollection.isSelected).equals(Tristate.isTrue);
      check(node.flagsCollection.isButton).isTrue();
      handle.dispose();
    });
  });
}
