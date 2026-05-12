import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

/// Repository fake that returns a single configured config. `next` is
/// honored by `refresh()` to verify the controller's full path.
class _FakeRepository implements ForceUpdateRepository {
  _FakeRepository({this.cached});

  ForceUpdateConfig? cached;
  ForceUpdateConfig? next;

  @override
  Future<ForceUpdateConfig?> refresh() async {
    if (next != null) cached = next;
    return cached;
  }

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async => cached;

  @override
  DateTime? lastFetchAt() => null;
}

ForceUpdateConfig _config({
  required String min,
  required String rec,
  bool maintenance = false,
  String key = 'default',
}) => ForceUpdateConfig(
  schemaVersion: 1,
  minVersion: min,
  recommendedVersion: rec,
  maintenanceMode: maintenance,
  messageKey: key,
);

/// Test observer factory that returns a non-functional observer; the
/// gate still registers/unregisters it but no real lifecycle wiring runs.
ForceUpdateLifecycleObserver _fakeObserverFactory(
  Future<void> Function() onResumed,
) {
  return ForceUpdateLifecycleObserver(onResumed);
}

Widget _wrap({
  required _FakeRepository repo,
  required Version version,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      forceUpdateRepositoryProvider.overrideWith((ref) => repo),
      currentAppVersionProvider.overrideWith((ref) async => version),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ForceUpdateGate(
        lifecycleObserverFactory: _fakeObserverFactory,
        child: child,
      ),
    ),
  );
}

void main() {
  const childKey = Key('child');
  const child = SizedBox(key: childKey);

  testWidgets('renders child only when NoUpdate', (tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(
      _wrap(repo: repo, version: Version.parse('2.0.0'), child: child),
    );
    await tester.pump();

    expect(find.byKey(childKey), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
    expect(find.byType(ForceUpdateBanner), findsNothing);
  });

  testWidgets('renders ForceUpdateScreen on HardUpdate', (tester) async {
    final repo = _FakeRepository(
      cached: _config(min: '3.0.0', rec: '3.0.0'),
    );
    await tester.pumpWidget(
      _wrap(repo: repo, version: Version.parse('2.0.0'), child: child),
    );
    await tester.pump();

    expect(find.byType(ForceUpdateScreen), findsOneWidget);
    expect(find.byKey(childKey), findsNothing);
  });

  testWidgets('renders ForceUpdateScreen on Maintenance', (tester) async {
    final repo = _FakeRepository(
      cached: _config(
        min: '1.0.0',
        rec: '1.0.0',
        maintenance: true,
        key: 'maintenance',
      ),
    );
    await tester.pumpWidget(
      _wrap(repo: repo, version: Version.parse('2.0.0'), child: child),
    );
    await tester.pump();

    expect(find.byType(ForceUpdateScreen), findsOneWidget);
    expect(find.text('Under Maintenance'), findsOneWidget);
    expect(find.byKey(childKey), findsNothing);
  });

  testWidgets('renders child + banner on SoftUpdate', (tester) async {
    final repo = _FakeRepository(
      cached: _config(min: '1.0.0', rec: '3.0.0'),
    );
    await tester.pumpWidget(
      _wrap(repo: repo, version: Version.parse('2.0.0'), child: child),
    );
    await tester.pump();

    expect(find.byKey(childKey), findsOneWidget);
    expect(find.byType(ForceUpdateBanner), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
  });

  testWidgets('lifecycle observer factory receives a resume callback', (
    tester,
  ) async {
    Future<void> Function()? captured;
    ForceUpdateLifecycleObserver capturingFactory(
      Future<void> Function() onResumed,
    ) {
      captured = onResumed;
      return ForceUpdateLifecycleObserver(onResumed);
    }

    final repo = _FakeRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          forceUpdateRepositoryProvider.overrideWith((ref) => repo),
          currentAppVersionProvider.overrideWith(
            (ref) async => Version.parse('2.0.0'),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ForceUpdateGate(
            lifecycleObserverFactory: capturingFactory,
            child: child,
          ),
        ),
      ),
    );
    await tester.pump();

    check(captured).isNotNull();
  });
}
