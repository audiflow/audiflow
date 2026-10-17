import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Brightness? _iconBrightness() =>
    SystemChrome.latestStyle?.statusBarIconBrightness;

void main() {
  testWidgets(
    'ArtworkOverlay.show switches to light icons with the scrim in light '
    'theme and restores the page style after dismiss',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          builder: (context, child) => ThemedSystemUiOverlay(child: child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => ArtworkOverlay.show(
                    context,
                    imageUrl: '',
                    heroTag: 'artwork',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      check(_iconBrightness()).equals(Brightness.dark);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // The scrim has barely faded in, so the page still shows behind the bar.
      check(_iconBrightness()).equals(Brightness.dark);

      await tester.pump(const Duration(milliseconds: 300));
      check(_iconBrightness()).equals(Brightness.light);

      Navigator.of(tester.element(find.text('open'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      check(_iconBrightness()).equals(Brightness.dark);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ArtworkOverlay), findsNothing);
      check(_iconBrightness()).equals(Brightness.dark);
    },
  );
}
