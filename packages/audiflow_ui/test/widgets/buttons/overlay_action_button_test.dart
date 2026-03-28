import 'package:audiflow_ui/src/widgets/buttons/overlay_action_button.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayActionButton', () {
    testWidgets('renders white icon with light scrim on dark artwork', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OverlayActionButton(icon: Icons.arrow_back)),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(Colors.white);

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.color).equals(Colors.white.withValues(alpha: 0.2));
    });

    testWidgets('renders dark icon with dark scrim on light artwork', (
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

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.color).equals(Colors.black.withValues(alpha: 0.25));
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OverlayActionButton));
      check(tapped).isTrue();
    });

    testWidgets('hit target is 48x48 with 36x36 visual', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OverlayActionButton(icon: Icons.arrow_back)),
        ),
      );

      final sizedBoxes = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(OverlayActionButton),
              matching: find.byType(SizedBox),
            ),
          )
          .toList();

      // First SizedBox: hit target (48x48)
      check(sizedBoxes[0].width).equals(48.0);
      check(sizedBoxes[0].height).equals(48.0);

      // Second SizedBox: visual container (36x36)
      check(sizedBoxes[1].width).equals(36.0);
      check(sizedBoxes[1].height).equals(36.0);

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.borderRadius).equals(BorderRadius.circular(10));
    });

    testWidgets('semantics enabled is false when onTap is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OverlayActionButton(icon: Icons.arrow_back)),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(OverlayActionButton),
              matching: find.byType(Semantics),
            )
            .first,
      );
      check(semantics.properties.enabled).equals(false);
    });

    testWidgets('semantics enabled is true when onTap is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(icon: Icons.arrow_back, onTap: () {}),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(OverlayActionButton),
              matching: find.byType(Semantics),
            )
            .first,
      );
      check(semantics.properties.enabled).equals(true);
    });
  });
}
