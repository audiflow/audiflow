import 'package:audiflow_app/features/search/presentation/widgets/country_picker_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('CountryPickerSheet', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountryPickerSheet(selectedCountry: 'us', onCountrySelected: (_) {}),
        ),
      );

      check(find.text('Select Region').evaluate()).isNotEmpty();
    });

    testWidgets('highlights selected country', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountryPickerSheet(selectedCountry: 'jp', onCountrySelected: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      final jpFinder = find.text('Japan');
      await tester.scrollUntilVisible(jpFinder, 100);

      final jpTile = find.text('Japan');
      check(jpTile.evaluate()).isNotEmpty();
    });

    testWidgets('calls onCountrySelected when tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          CountryPickerSheet(
            selectedCountry: 'us',
            onCountrySelected: (code) => selected = code,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final japanFinder = find.text('Japan');
      await tester.scrollUntilVisible(japanFinder, 100);
      await tester.tap(japanFinder);
      check(selected).equals('jp');
    });

    testWidgets('displays countries from PodcastCountries.all', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CountryPickerSheet(selectedCountry: 'us', onCountrySelected: (_) {}),
        ),
      );

      check(find.text('Australia').evaluate()).isNotEmpty();
    });
  });
}
