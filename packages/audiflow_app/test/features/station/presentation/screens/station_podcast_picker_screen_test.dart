import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_podcast_picker_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the Japanese cancel label stays on one line', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(<Subscription>[]),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StationPodcastPickerScreen(selectedIds: {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cancel = find.text('キャンセル');
    final done = find.text('完了');
    // Wrapping would make the label taller than the one-line "完了".
    check(tester.getSize(cancel).height).equals(tester.getSize(done).height);
  });
}
