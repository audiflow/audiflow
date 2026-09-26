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
  });
}
