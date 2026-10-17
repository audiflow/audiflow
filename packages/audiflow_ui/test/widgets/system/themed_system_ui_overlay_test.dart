import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required ThemeMode themeMode, Widget? home}) {
  return MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    builder: (context, child) => ThemedSystemUiOverlay(child: child!),
    home: home ?? const Scaffold(body: SizedBox.expand()),
  );
}

void _checkIconsFor(SystemUiOverlayStyle? style, Brightness icons) {
  check(style).isNotNull()
    ..has(
      (s) => s.statusBarIconBrightness,
      'statusBarIconBrightness',
    ).equals(icons)
    // iOS reads the brightness of the content behind the bar, the
    // inverse of the icon brightness.
    ..has(
      (s) => s.statusBarBrightness,
      'statusBarBrightness',
    ).equals(icons == Brightness.dark ? Brightness.light : Brightness.dark)
    ..has((s) => s.statusBarColor, 'statusBarColor').equals(Colors.transparent);
}

void main() {
  group('ThemedSystemUiOverlay.styleOn', () {
    test('uses dark icons over a light background', () {
      _checkIconsFor(
        ThemedSystemUiOverlay.styleOn(Brightness.light),
        Brightness.dark,
      );
    });

    test('uses light icons over a dark background', () {
      _checkIconsFor(
        ThemedSystemUiOverlay.styleOn(Brightness.dark),
        Brightness.light,
      );
    });
  });

  group('ThemedSystemUiOverlay', () {
    testWidgets('applies dark icons for the light theme', (tester) async {
      await tester.pumpWidget(_app(themeMode: ThemeMode.light));

      _checkIconsFor(SystemChrome.latestStyle, Brightness.dark);
    });

    testWidgets('applies light icons for the dark theme', (tester) async {
      await tester.pumpWidget(_app(themeMode: ThemeMode.dark));

      _checkIconsFor(SystemChrome.latestStyle, Brightness.light);
    });

    testWidgets('follows the in-app theme over the platform brightness', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(_app(themeMode: ThemeMode.light));

      _checkIconsFor(SystemChrome.latestStyle, Brightness.dark);
    });

    testWidgets('restores the theme style after a Cupertino sheet closes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showCupertinoSheet<void>(
                    context: context,
                    scrollableBuilder: (_, _) =>
                        const Scaffold(body: SizedBox.expand()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // The sheet's own region keeps light icons over its dark top gap; it
      // leaves the bar color null, so only the icons are checked here.
      check(
        SystemChrome.latestStyle?.statusBarIconBrightness,
      ).equals(Brightness.light);

      Navigator.of(tester.element(find.text('open'))).pop();
      await tester.pumpAndSettle();
      _checkIconsFor(SystemChrome.latestStyle, Brightness.dark);
    });
  });
}
