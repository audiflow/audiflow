import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ArtworkOverlay keeps light status bar icons in light theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        builder: (context, child) => ThemedSystemUiOverlay(child: child!),
        home: const Scaffold(
          backgroundColor: Colors.black87,
          body: ArtworkOverlay(imageUrl: '', heroTag: 'artwork'),
        ),
      ),
    );

    check(
      SystemChrome.latestStyle?.statusBarIconBrightness,
    ).equals(Brightness.light);
  });
}
