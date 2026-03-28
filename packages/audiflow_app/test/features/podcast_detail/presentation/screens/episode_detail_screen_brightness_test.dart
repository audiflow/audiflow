import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeDetailScreen adaptive overlay', () {
    testWidgets('AnnotatedRegion uses light style for dark artwork', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.dark,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(Colors.white);
    });

    testWidgets('AnnotatedRegion uses dark style for light artwork', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.light,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(const Color(0xFF1A1A1A));
    });
  });
}
