import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_app/features/settings/presentation/screens/opml_import_preview_screen.dart';
import 'package:audiflow_app/features/settings/presentation/widgets/opml_import_flow.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Lets a test drive the controller through each result state without
/// touching the parental-control gate or the file picker.
class _FakeOpmlImportController extends OpmlImportController {
  int startCount = 0;

  @override
  OpmlPickResult build() => OpmlPickIdle();

  @override
  Future<bool> pickAndParse(BuildContext context) async {
    startCount++;
    return true;
  }

  void emit(OpmlPickResult result) => state = result;
}

void main() {
  late _FakeOpmlImportController fake;

  setUp(() => fake = _FakeOpmlImportController());

  Future<void> pumpFlow(WidgetTester tester) async {
    await tester.pumpApp(
      Scaffold(
        body: OpmlImportFlow(
          builder: (context, start) =>
              ElevatedButton(onPressed: start, child: const Text('Import')),
        ),
      ),
      overrides: [opmlImportControllerProvider.overrideWith(() => fake)],
    );
    await tester.pumpAndSettle();
  }

  group('OpmlImportFlow', () {
    testWidgets('opens the preview when a file parses', (tester) async {
      await pumpFlow(tester);

      fake.emit(
        OpmlPickSuccess(
          entries: const [
            OpmlEntry(title: 'A Podcast', feedUrl: 'https://example.com/a.xml'),
          ],
          subscribedFeedUrls: const {},
        ),
      );
      await tester.pumpAndSettle();

      check(find.byType(OpmlImportPreviewScreen).evaluate()).isNotEmpty();
    });

    testWidgets('surfaces a parse error without navigating', (tester) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickError('No podcast feeds found in the file'));
      await tester.pumpAndSettle();

      check(
        find.text('No podcast feeds found in the file').evaluate(),
      ).isNotEmpty();
      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
    });

    testWidgets('does nothing when the user cancels the picker', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickCancelled());
      await tester.pumpAndSettle();

      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('shows no preview while the file is still loading', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickLoading());
      await tester.pumpAndSettle();

      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('disables the action while an import is loading', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickLoading());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      check(button.onPressed).isNull();
    });
  });
}
