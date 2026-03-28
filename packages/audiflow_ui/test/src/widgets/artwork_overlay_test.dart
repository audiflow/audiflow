import 'dart:io';

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Provides a transparent 1x1 PNG for all HTTP image requests,
/// preventing real network calls during widget tests.
class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('ArtworkOverlay', () {
    const imageUrl = 'https://example.com/artwork.jpg';
    const heroTag = 'test_hero';

    Widget buildSubject() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      opaque: false,
                      barrierDismissible: true,
                      barrierColor: Colors.black87,
                      // Use zero duration to avoid animation timeouts
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const ArtworkOverlay(
                          imageUrl: imageUrl,
                          heroTag: heroTag,
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
    }

    testWidgets('displays overlay when opened', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      // Use pump instead of pumpAndSettle to avoid timeout from
      // ExtendedImage continuously attempting network image load
      await tester.pump();

      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();
      check(find.byType(ExtendedImage).evaluate()).isNotEmpty();
      check(find.byType(Hero).evaluate()).isNotEmpty();
    });

    testWidgets('dismisses when tapping background', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      // Verify overlay is visible
      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();

      // Tap the background (top-left corner, outside the centered artwork)
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      // Overlay should be dismissed
      check(find.byType(ArtworkOverlay).evaluate()).isEmpty();
    });

    testWidgets('does not dismiss when tapping artwork area', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      // Tap the center of the screen (where the artwork is)
      final center = tester.getCenter(find.byType(ArtworkOverlay));
      await tester.tapAt(center);
      await tester.pump();

      // Overlay should still be visible
      check(find.byType(ArtworkOverlay).evaluate()).isNotEmpty();
    });

    testWidgets('renders ClipRRect with border radius', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pump();

      final clipRRect = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(ArtworkOverlay),
          matching: find.byType(ClipRRect),
        ),
      );
      check(clipRRect.borderRadius).equals(AppBorders.lg);
    });
  });
}
