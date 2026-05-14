import 'package:audiflow_app/features/review_prompt/presentation/widgets/review_prompt_dialog.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<ReviewPromptAction?> pump(
    WidgetTester tester, {
    required Future<void> Function(BuildContext) tap,
  }) async {
    ReviewPromptAction? captured;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                captured = await ReviewPromptDialog.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tap(tester.element(find.byType(AlertDialog)));
    await tester.pumpAndSettle();
    return captured;
  }

  testWidgets('Rate now returns rateNow', (tester) async {
    final result = await pump(
      tester,
      tap: (context) async => await tester.tap(find.text('Rate now')),
    );
    check(result).equals(ReviewPromptAction.rateNow);
  });

  testWidgets('Later returns later', (tester) async {
    final result = await pump(
      tester,
      tap: (context) async => await tester.tap(find.text('Later')),
    );
    check(result).equals(ReviewPromptAction.later);
  });

  testWidgets("Don't ask again returns dontAskAgain", (tester) async {
    final result = await pump(
      tester,
      tap: (context) async => await tester.tap(find.text("Don't ask again")),
    );
    check(result).equals(ReviewPromptAction.dontAskAgain);
  });
}
