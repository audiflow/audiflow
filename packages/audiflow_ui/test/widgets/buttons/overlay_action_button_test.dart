import 'package:audiflow_ui/src/widgets/buttons/overlay_action_button.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayActionButton', () {
    testWidgets('renders white icon with dark scrim', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OverlayActionButton(icon: Icons.arrow_back)),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(Colors.white);

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.color).equals(Colors.black.withValues(alpha: 0.35));
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

    testWidgets('has correct size and border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OverlayActionButton(icon: Icons.arrow_back)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(OverlayActionButton),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      check(sizedBox.width).equals(36.0);
      check(sizedBox.height).equals(36.0);

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.borderRadius).equals(BorderRadius.circular(10));
    });
  });
}
