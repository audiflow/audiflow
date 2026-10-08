import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, double top) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: ContentBackdrop(top: top),
    ),
  );

  testWidgets('shows the texture only below top', (tester) async {
    await pump(tester, 200);
    final clip = tester.renderObject<RenderClipRect>(
      find.ancestor(
        of: find.byKey(ContentBackdrop.textureKey),
        matching: find.byType(ClipRect),
      ),
    );
    check(
      clip.clipper!.getClip(const Size(800, 600)),
    ).equals(const Rect.fromLTRB(0, 200, 800, 600));
  });

  testWidgets('an off-screen top hides the texture', (tester) async {
    await pump(tester, double.infinity);
    final clip = tester.renderObject<RenderClipRect>(
      find.ancestor(
        of: find.byKey(ContentBackdrop.textureKey),
        matching: find.byType(ClipRect),
      ),
    );
    check(clip.clipper!.getClip(const Size(800, 600)).height).equals(0);
  });

  test('base color sits between bg and surface', () {
    const colors = AppColors.light;
    final base = ContentBackdrop.baseColorFor(colors);
    check(base).not((it) => it.equals(colors.bg));
    check(base).not((it) => it.equals(colors.surface));
  });
}
