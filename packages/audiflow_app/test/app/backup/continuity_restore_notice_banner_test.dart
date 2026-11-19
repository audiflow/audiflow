import 'package:audiflow_app/app/backup/continuity_restore_notice_banner.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const message = 'Your data was carried over from your previous device';

  Widget app(ContinuityRestoreNotice notice) => ProviderScope(
    overrides: [continuityRestoreNoticeProvider.overrideWithValue(notice)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ContinuityRestoreNoticeBanner(child: child!),
      home: const Scaffold(body: SizedBox()),
    ),
  );

  testWidgets('shows the notice once after a launch restore', (tester) async {
    final notice = ContinuityRestoreNotice()..raise();

    await tester.pumpWidget(app(notice));
    await tester.pump();

    check(find.text(message).evaluate()).isNotEmpty();
    check(notice.consume()).isFalse();
  });

  testWidgets('shows nothing without a launch restore', (tester) async {
    await tester.pumpWidget(app(ContinuityRestoreNotice()));
    await tester.pump();

    check(find.text(message).evaluate()).isEmpty();
  });
}
