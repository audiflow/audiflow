import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/presentation/widgets/pin_entry_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('Submit button disabled until 4 digits entered', (tester) async {
    await tester.pumpWidget(
      _wrap(const PinEntrySheet(reason: GateReason.subscribe)),
    );
    final submit = find.widgetWithText(ElevatedButton, 'Submit');
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    final field = find.byType(TextField).first;
    await tester.enterText(field, '12');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    await tester.enterText(field, '1234');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNotNull();
  });
}
