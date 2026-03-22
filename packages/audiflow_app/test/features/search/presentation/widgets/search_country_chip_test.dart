import 'package:audiflow_app/features/search/presentation/widgets/search_country_chip.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchCountryChip', () {
    testWidgets('displays uppercase country code', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchCountryChip(countryCode: 'jp', onTap: () {}),
          ),
        ),
      );

      check(find.text('JP').evaluate()).isNotEmpty();
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchCountryChip(
              countryCode: 'us',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SearchCountryChip));
      check(tapped).isTrue();
    });
  });
}
