import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingLauncher {
  Uri? launched;

  Future<bool> call(Uri uri) async {
    launched = uri;
    return true;
  }
}

Widget _wrap({required Widget child, required List<dynamic> overrides}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders title, body, and both actions for SoftUpdate', (
    tester,
  ) async {
    final launcher = _RecordingLauncher();
    await tester.pumpWidget(
      _wrap(
        overrides: [urlLauncherProvider.overrideWithValue(launcher.call)],
        child: const ForceUpdateBanner(
          decision: SoftUpdate(
            messageKey: 'default',
            updateUrl: 'https://example.com/update',
          ),
        ),
      ),
    );

    expect(find.text('Update Required'), findsOneWidget);
    expect(
      find.text('A newer version of Audiflow is available.'),
      findsOneWidget,
    );
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('Later dismisses the banner for the session', (tester) async {
    await tester.pumpWidget(
      _wrap(
        overrides: const [],
        child: const ForceUpdateBanner(
          decision: SoftUpdate(messageKey: 'default'),
        ),
      ),
    );

    expect(find.text('Later'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pump();

    expect(find.text('Later'), findsNothing);
    expect(find.text('Update now'), findsNothing);
  });

  testWidgets('Update now invokes the injected launcher', (tester) async {
    final launcher = _RecordingLauncher();
    await tester.pumpWidget(
      _wrap(
        overrides: [urlLauncherProvider.overrideWithValue(launcher.call)],
        child: const ForceUpdateBanner(
          decision: SoftUpdate(
            messageKey: 'default',
            updateUrl: 'https://example.com/update',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Update now'));
    await tester.pump();

    check(launcher.launched).isNotNull();
    check(launcher.launched!.toString()).equals('https://example.com/update');
  });

  testWidgets('hidden when dismissed flag is already set', (tester) async {
    await tester.pumpWidget(
      _wrap(
        overrides: const [],
        child: const ForceUpdateBanner(
          decision: SoftUpdate(messageKey: 'default'),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ForceUpdateBanner)),
    );
    container.read(softUpdateBannerDismissedProvider.notifier).dismiss();
    await tester.pump();

    expect(find.text('Update now'), findsNothing);
    expect(find.text('Later'), findsNothing);
  });
}
