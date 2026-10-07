import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts at the anchor and follows it on scroll', (tester) async {
    final anchorKey = GlobalKey();
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AnchoredContentBackdrop(
          anchorKey: anchorKey,
          child: ListView(
            controller: controller,
            children: [
              const SizedBox(height: 150),
              SizedBox(key: anchorKey, height: 40),
              for (var i = 0; i < 30; i++) const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
    check(clipOf(tester).top).equals(150);

    // Same frame as the scroll: the edge never trails the content.
    controller.jumpTo(100);
    await tester.pump();
    check(clipOf(tester).top).equals(50);
  });

  testWidgets('no anchor shows no list surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AnchoredContentBackdrop(
          anchorKey: GlobalKey(),
          child: ListView(children: const [SizedBox(height: 100)]),
        ),
      ),
    );
    check(clipOf(tester).height).equals(0);
  });
}

/// The textured region, in backdrop coordinates.
Rect clipOf(WidgetTester tester) {
  final clip = tester.renderObject<RenderClipRect>(
    find.ancestor(
      of: find.byKey(ContentBackdrop.textureKey),
      matching: find.byType(ClipRect),
    ),
  );
  return clip.clipper!.getClip(clip.size);
}
