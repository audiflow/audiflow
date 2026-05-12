import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_semver/pub_semver.dart';

/// Null reporter prevents accidental Sentry calls if a cold-start
/// transition fires during the boot test.
class _NullReporter implements ForceUpdateReporter {
  @override
  void addBreadcrumb({
    required String message,
    required ForceUpdateLogLevel level,
    Map<String, Object?>? data,
  }) {}

  @override
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    String? message,
  }) async {}
}

/// Repository fake that always reports a healthy config.
class _NoUpdateRepository implements ForceUpdateRepository {
  static const _config = ForceUpdateConfig(
    schemaVersion: 1,
    minVersion: '1.0.0',
    recommendedVersion: '1.0.0',
    maintenanceMode: false,
    messageKey: 'default',
  );

  @override
  Future<ForceUpdateConfig?> refresh() async => _config;

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async => _config;

  @override
  DateTime? lastFetchAt() => DateTime.now().toUtc();
}

ForceUpdateLifecycleObserver _fakeObserverFactory(
  Future<void> Function() onResumed,
) {
  return ForceUpdateLifecycleObserver(onResumed);
}

/// Mirrors the production bootstrap shape: a [MaterialApp.router] with
/// `ForceUpdateGate` injected inside `builder`, sitting between the
/// MaterialApp and the router subtree.
class _BootApp extends StatelessWidget {
  _BootApp();

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: Center(child: Text('router-mounted', key: Key('router-text'))),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ForceUpdateGate(
        lifecycleObserverFactory: _fakeObserverFactory,
        child: child!,
      ),
      routerConfig: _router,
    );
  }
}

void main() {
  testWidgets('NoUpdate decision lets the router render pass-through', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          forceUpdateRepositoryProvider.overrideWith(
            (ref) => _NoUpdateRepository(),
          ),
          currentAppVersionProvider.overrideWith(
            (ref) async => Version.parse('2.0.0'),
          ),
          forceUpdateReporterProvider.overrideWith((ref) => _NullReporter()),
        ],
        child: _BootApp(),
      ),
    );
    await tester.pump();

    // Gate is mounted and transparent on NoUpdate: the router child
    // reaches the screen.
    check(find.byType(ForceUpdateGate).evaluate().length).equals(1);
    check(find.byKey(const Key('router-text')).evaluate().length).equals(1);
    expect(find.byType(ForceUpdateScreen), findsNothing);
    expect(find.byType(ForceUpdateBanner), findsNothing);
  });
}
