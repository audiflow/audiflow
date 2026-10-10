import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _contentKey = Key('content');

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    required Size screen,
    AlignmentDirectional alignment = AlignmentDirectional.bottomCenter,
    double maxWidth = 400,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showCompactSheet<void>(
              context: context,
              alignment: alignment,
              maxWidth: maxWidth,
              builder: (_) => const SizedBox(key: _contentKey, height: 120),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect contentRect(WidgetTester tester) =>
      tester.getRect(find.byKey(_contentKey));

  testWidgets('spans the screen when narrower than maxWidth', (tester) async {
    await openSheet(tester, screen: const Size(390, 844));

    final rect = contentRect(tester);
    expect(rect.left, 0);
    expect(rect.width, 390);
  });

  testWidgets('caps width and centers by default on a wide screen', (
    tester,
  ) async {
    await openSheet(tester, screen: const Size(1024, 768));

    final rect = contentRect(tester);
    expect(rect.width, 400);
    expect(rect.center.dx, 512);
  });

  testWidgets('end alignment keeps a gap from the trailing edge', (
    tester,
  ) async {
    await openSheet(
      tester,
      screen: const Size(1024, 768),
      alignment: AlignmentDirectional.bottomEnd,
    );

    final rect = contentRect(tester);
    expect(rect.width, 400);
    expect(rect.right, 1024 - CompactSheet.edgeGap);
  });

  testWidgets('tapping beside the sheet dismisses it', (tester) async {
    await openSheet(
      tester,
      screen: const Size(1024, 768),
      alignment: AlignmentDirectional.bottomEnd,
    );

    await tester.tapAt(Offset(40, contentRect(tester).center.dy));
    await tester.pumpAndSettle();

    expect(find.byKey(_contentKey), findsNothing);
  });

  testWidgets('tapping the sheet itself keeps it open', (tester) async {
    await openSheet(tester, screen: const Size(1024, 768));

    await tester.tapAt(contentRect(tester).center);
    await tester.pumpAndSettle();

    expect(find.byKey(_contentKey), findsOneWidget);
  });
}
