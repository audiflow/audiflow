import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_app/features/settings/presentation/screens/opml_import_preview_screen.dart';
import 'package:audiflow_app/features/settings/presentation/widgets/opml_import_flow.dart';
import 'package:audiflow_app/features/settings/presentation/utils/opml_read_failure.dart';
import 'package:audiflow_app/features/settings/services/opml_file_picker.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Lets a test drive the controller through each result state without
/// touching the parental-control gate or the file picker.
class _FakeOpmlImportController extends OpmlImportController {
  final requestedFilters = <OpmlPickFilter>[];

  @override
  OpmlPickResult build() => OpmlPickIdle();

  @override
  Future<bool> pickAndParse(
    BuildContext context, {
    OpmlPickFilter filter = OpmlPickFilter.opml,
  }) async {
    requestedFilters.add(filter);
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

    testWidgets('shows the generic message, not the raw error text', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(
        OpmlPickError(
          OpmlReadFailure.unexpected,
          error: StateError('IsarError: Unique index violated.'),
        ),
      );
      await tester.pumpAndSettle();

      check(
        find.text('Something went wrong. Please try again later.').evaluate(),
      ).isNotEmpty();
      check(find.textContaining('IsarError').evaluate()).isEmpty();
    });

    testWidgets('surfaces a parse error without navigating', (tester) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickError(OpmlReadFailure.noFeeds));
      await tester.pumpAndSettle();

      check(
        find.text('No podcast feeds found in the file').evaluate(),
      ).isNotEmpty();
      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
    });

    testWidgets('offers all files when the filtered picker is cancelled', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickCancelled(filter: OpmlPickFilter.opml));
      await tester.pumpAndSettle();

      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
      await tester.tap(find.text('Show all files'));
      await tester.pumpAndSettle();

      check(fake.requestedFilters).deepEquals([OpmlPickFilter.allFiles]);
    });

    testWidgets('lets the all-files offer time out on its own', (tester) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickCancelled(filter: OpmlPickFilter.opml));
      await tester.pumpAndSettle();
      check(find.byType(SnackBar).evaluate()).isNotEmpty();

      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();

      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('drops the all-files offer when import starts again', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickCancelled(filter: OpmlPickFilter.opml));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      check(find.byType(SnackBar).evaluate()).isEmpty();
      check(fake.requestedFilters).deepEquals([OpmlPickFilter.opml]);
    });

    testWidgets('does nothing when the unfiltered picker is cancelled', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickCancelled(filter: OpmlPickFilter.allFiles));
      await tester.pumpAndSettle();

      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('shows progress and no preview while the file loads', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickLoading());
      await tester.pump();

      check(find.byType(CircularProgressIndicator).evaluate()).isNotEmpty();
      check(find.text('Reading file...').evaluate()).isNotEmpty();
      check(find.byType(OpmlImportPreviewScreen).evaluate()).isEmpty();
      check(find.byType(SnackBar).evaluate()).isEmpty();
    });

    testWidgets('removes the progress once loading ends', (tester) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickLoading());
      await tester.pump();
      fake.emit(OpmlPickError(OpmlReadFailure.noFeeds));
      await tester.pumpAndSettle();

      check(find.byType(CircularProgressIndicator).evaluate()).isEmpty();
    });

    testWidgets('disables the action while an import is loading', (
      tester,
    ) async {
      await pumpFlow(tester);

      fake.emit(OpmlPickLoading());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      check(button.onPressed).isNull();
    });
  });
}
