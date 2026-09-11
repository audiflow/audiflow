import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension for pumping widgets with providers, theme, and routing
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('en'),
    // flutter_riverpod does not export the `Override` type, so the element
    // type is erased and cast back, as the other screen tests here do.
    List<dynamic> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp(
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
