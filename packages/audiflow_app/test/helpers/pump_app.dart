import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension for pumping widgets with providers, theme, and routing
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('en'),
  }) async {
    await pumpWidget(
      ProviderScope(
        child: MaterialApp(themeMode: themeMode, locale: locale, home: widget),
      ),
    );
  }
}
