import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = 'https://example.com/art.jpg';

int? _decodedWidth(WidgetTester tester) {
  final image = tester.widget<ExtendedImage>(find.byType(ExtendedImage));
  final provider = image.image;
  return provider is ExtendedResizeImage ? provider.width : null;
}

Widget _host(Widget child, {double devicePixelRatio = 3}) {
  return MediaQuery(
    data: MediaQueryData(devicePixelRatio: devicePixelRatio),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('ArtworkImage.decodeWidth', () {
    test('scales the logical width to physical pixels, rounding up', () {
      check(ArtworkImage.decodeWidth(64, 3)).equals(192);
      check(ArtworkImage.decodeWidth(64, 2.75)).equals(176);
      check(ArtworkImage.decodeWidth(10.1, 1)).equals(11);
    });

    test('returns null for an unbounded or empty width', () {
      check(ArtworkImage.decodeWidth(double.infinity, 3)).isNull();
      check(ArtworkImage.decodeWidth(0, 3)).isNull();
    });
  });

  group('ArtworkImage', () {
    testWidgets('decodes at the explicit width times the pixel ratio', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const ArtworkImage(url: _url, width: 64, height: 64)),
      );

      check(_decodedWidth(tester)).equals(192);
    });

    testWidgets('decodes at the constrained width when none is given', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Center(
            child: SizedBox(width: 120, child: ArtworkImage(url: _url)),
          ),
          devicePixelRatio: 2,
        ),
      );

      check(_decodedWidth(tester)).equals(240);
    });

    testWidgets('shows the placeholder while loading', (tester) async {
      await tester.pumpWidget(
        _host(
          const ArtworkImage(
            url: _url,
            width: 64,
            height: 64,
            placeholder: Text('placeholder'),
          ),
        ),
      );

      check(find.text('placeholder').evaluate()).isNotEmpty();
    });

    // flutter_test answers every HTTP request with 400, so the load fails
    // once ExtendedImage's retries run out (about a second of real time).
    // Each failure test uses its own URL: a load left pending by an earlier
    // test stays in the image cache and would never settle here.
    Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
      for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
      }
    }

    testWidgets('shows the placeholder when loading fails', (tester) async {
      await tester.pumpWidget(
        _host(
          const ArtworkImage(
            url: 'https://example.com/failed-placeholder.jpg',
            width: 64,
            height: 64,
            loading: Text('loading'),
            placeholder: Text('placeholder'),
          ),
        ),
      );
      await pumpUntilFound(tester, find.text('placeholder'));

      check(find.text('placeholder').evaluate()).isNotEmpty();
      check(find.text('loading').evaluate()).isEmpty();
    });

    testWidgets('falls back to the tap-to-retry failure state without a '
        'placeholder', (tester) async {
      await tester.pumpWidget(
        _host(
          const ArtworkImage(
            url: 'https://example.com/failed-default.jpg',
            width: 64,
            height: 64,
          ),
        ),
      );
      final failed = find.text('Failed to load image');
      await pumpUntilFound(tester, failed);

      check(failed.evaluate()).isNotEmpty();
    });
  });
}
