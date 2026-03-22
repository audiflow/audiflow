import 'package:audiflow_app/features/search/presentation/widgets/search_country_chip.dart';
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
  group('SearchCountryChip', () {
    testWidgets('displays uppercase country code', (tester) async {
      await tester.pumpWidget(
        _wrap(SearchCountryChip(countryCode: 'jp', onTap: () {})),
      );

      check(find.text('JP').evaluate()).isNotEmpty();
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(SearchCountryChip(countryCode: 'us', onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(SearchCountryChip));
      check(tapped).isTrue();
    });

    testWidgets('has Semantics wrapper', (tester) async {
      await tester.pumpWidget(
        _wrap(SearchCountryChip(countryCode: 'jp', onTap: () {})),
      );

      check(find.byType(Semantics).evaluate()).isNotEmpty();
    });

    testWidgets('has Tooltip', (tester) async {
      await tester.pumpWidget(
        _wrap(SearchCountryChip(countryCode: 'us', onTap: () {})),
      );

      check(find.byType(Tooltip).evaluate()).isNotEmpty();
    });
  });
}
