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
        home: RepaintBoundary(
          key: _boundaryKey,
          child: AnchoredContentBackdrop(
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
      ),
    );
    check(clipOf(tester).top).equals(150);
    // y=100 sits above the list surface: plain screen color.
    check(await pixelAt(tester, 100)).equals(AppColors.light.bg);

    // Same frame as the scroll: the painted edge never trails the content.
    controller.jumpTo(100);
    await tester.pump();
    check(clipOf(tester).top).equals(50);
    check(
      await pixelAt(tester, 100),
    ).not((it) => it.equals(AppColors.light.bg));
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

final _boundaryKey = GlobalKey();

/// The color actually painted at (4, [y]), read back from the layer tree,
/// so a clip that was never repainted shows up as stale.
Future<Color> pixelAt(WidgetTester tester, double y) async {
  // Flush any repaint already requested; a clip nobody asked to repaint
  // stays as it was, which is what this check is meant to catch.
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data!;
  });
  final offset = ((y.round() * boundary.size.width.round()) + 4) * 4;
  return Color.fromARGB(
    bytes!.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}
