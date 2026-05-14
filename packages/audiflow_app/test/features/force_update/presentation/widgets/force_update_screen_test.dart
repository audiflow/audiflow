import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

/// Repository fake matching the controller's contract; covers cases
/// where the controller's `build()` is exercised under test.
class _FakeRepository implements ForceUpdateRepository {
  ForceUpdateConfig? cached;
  ForceUpdateConfig? next;
  int refreshCalls = 0;

  @override
  Future<ForceUpdateConfig?> refresh() async {
    refreshCalls++;
    if (next != null) cached = next;
    return cached;
  }

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async => cached;

  @override
  DateTime? lastFetchAt() => null;
}

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
      home: child,
    ),
  );
}

void main() {
  testWidgets('hard update renders title, body and update button', (
    tester,
  ) async {
    final launcher = _RecordingLauncher();
    await tester.pumpWidget(
      _wrap(
        overrides: [urlLauncherProvider.overrideWithValue(launcher.call)],
        child: const ForceUpdateScreen(
          decision: HardUpdate(
            messageKey: 'default',
            updateUrl: 'https://example.com/update',
          ),
        ),
      ),
    );

    expect(find.text('Update Required'), findsOneWidget);
    expect(
      find.text('A newer version of Audiflow is required to continue.'),
      findsOneWidget,
    );
    expect(find.text('Update now'), findsOneWidget);
  });

  testWidgets('maintenance renders retry button and triggers refresh', (
    tester,
  ) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(
      _wrap(
        overrides: [
          forceUpdateRepositoryProvider.overrideWith((ref) => repo),
          currentAppVersionProvider.overrideWith(
            (ref) async => Version.parse('1.0.0'),
          ),
        ],
        child: const ForceUpdateScreen(
          decision: Maintenance(messageKey: 'maintenance'),
        ),
      ),
    );

    // Wait for the controller's first build() to complete so that
    // pressing Retry routes through a notifier in the AsyncData state.
    await tester.pump();

    expect(find.text('Under Maintenance'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    final baseline = repo.refreshCalls;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    check(baseline < repo.refreshCalls).isTrue();
  });

  testWidgets('tapping Update now invokes the injected launcher', (
    tester,
  ) async {
    final launcher = _RecordingLauncher();
    await tester.pumpWidget(
      _wrap(
        overrides: [urlLauncherProvider.overrideWithValue(launcher.call)],
        child: const ForceUpdateScreen(
          decision: HardUpdate(
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

  testWidgets('PopScope blocks back navigation', (tester) async {
    await tester.pumpWidget(
      _wrap(
        overrides: const [],
        child: const ForceUpdateScreen(
          decision: HardUpdate(messageKey: 'default'),
        ),
      ),
    );

    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    check(popScope.canPop).isFalse();
  });
}
