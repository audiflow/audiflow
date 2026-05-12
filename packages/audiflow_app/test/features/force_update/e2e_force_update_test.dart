import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end tests for the force-update gate.
///
/// These tests drive the full stack — real [ForceUpdateRepositoryImpl] on
/// top of the real local + remote data sources, the real controller, the
/// real gate widget, and the real screens/banner. The only seams replaced
/// are:
/// - Dio (replaced by a `DioAdapter` so we never touch the network).
/// - SharedPreferences (mock initial values to prime the cache).
/// - `currentAppVersionProvider` (pinned semver per scenario).
/// - `forceUpdateConfigUrlProvider` (fake URL the adapter knows about).
/// - `forceUpdateReporterProvider` (recording reporter for Sentry seam).
/// - `urlLauncherProvider` (recording launcher so "Update now" stays a
///   pure assertion instead of triggering a platform channel call).
///
/// The goal is to catch wiring regressions between the layers — the
/// individual layers each have their own unit tests; this file proves
/// they compose correctly.

const _configUrl = 'https://example.test/app_config.json';
const _testTimeout = Timeout(Duration(seconds: 15));

/// Recording stand-in for [ForceUpdateReporter] so tests can assert
/// breadcrumbs / capture calls without booting Sentry.
class _RecordingReporter implements ForceUpdateReporter {
  final List<({String message, ForceUpdateLogLevel level})> breadcrumbs = [];
  final List<({Object error, String? message})> captures = [];

  @override
  void addBreadcrumb({
    required String message,
    required ForceUpdateLogLevel level,
    Map<String, Object?>? data,
  }) {
    breadcrumbs.add((message: message, level: level));
  }

  @override
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    String? message,
  }) async {
    captures.add((error: error, message: message));
  }
}

/// Recording launcher: stores invocations so "Update now" taps can be
/// asserted without hitting `url_launcher`'s platform channel.
class _RecordingLauncher {
  final List<Uri> calls = [];

  Future<bool> call(Uri uri) async {
    calls.add(uri);
    return true;
  }
}

/// Recording warning sink: lets us prove the repository surfaced a
/// validation failure (or error) to the composition root.
class _RecordingWarningSink {
  final List<({String message, Object? error})> records = [];

  void call(String message, {Object? error, StackTrace? stackTrace}) {
    records.add((message: message, error: error));
  }
}

Map<String, Object?> _configJson({
  int schemaVersion = 1,
  required String min,
  required String rec,
  bool maintenance = false,
  String messageKey = 'default',
  String? updateUrl,
}) => {
  'schema_version': schemaVersion,
  'min_version': min,
  'recommended_version': rec,
  'maintenance_mode': maintenance,
  'message_key': messageKey,
  'update_url': ?updateUrl,
};

/// Counts outbound GET requests for the force-update endpoint so tests
/// can assert "retry actually fired a fresh fetch" without instrumenting
/// the controller. Installed as a Dio interceptor.
class _RequestCounter {
  int gets = 0;
}

/// Builds a [ProviderContainer] with the full force-update stack wired up.
///
/// [seedPrefs] primes [SharedPreferences] before the repository's local
/// data source reads it; used to test the offline-cache honor path.
Future<
  ({
    ProviderContainer container,
    _RecordingLauncher launcher,
    _RecordingReporter reporter,
    _RecordingWarningSink warningSink,
    DioAdapter adapter,
    _RequestCounter counter,
  })
>
_makeContainer({
  required Version version,
  Map<String, Object> seedPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(seedPrefs);
  final prefs = await SharedPreferences.getInstance();

  final dio = Dio();
  final counter = _RequestCounter();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET' && options.path == _configUrl) {
          counter.gets++;
        }
        handler.next(options);
      },
    ),
  );
  final adapter = DioAdapter(dio: dio);

  final launcher = _RecordingLauncher();
  final reporter = _RecordingReporter();
  final warningSink = _RecordingWarningSink();

  final container = ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      sharedPreferencesProvider.overrideWithValue(prefs),
      forceUpdateConfigUrlProvider.overrideWithValue(_configUrl),
      currentAppVersionProvider.overrideWith((ref) async => version),
      forceUpdateReporterProvider.overrideWith((ref) => reporter),
      urlLauncherProvider.overrideWith((ref) => launcher.call),
      forceUpdateWarningSinkProvider.overrideWith((ref) => warningSink.call),
    ],
  );

  return (
    container: container,
    launcher: launcher,
    reporter: reporter,
    warningSink: warningSink,
    adapter: adapter,
    counter: counter,
  );
}

class _TestChild extends StatelessWidget {
  const _TestChild();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('CHILD-OK', key: Key('child-ok'))),
    );
  }
}

/// Inert lifecycle observer factory — keeps tests from registering on the
/// real [WidgetsBinding] observer registry.
ForceUpdateLifecycleObserver _inertObserverFactory(
  Future<void> Function() onResumed,
) => ForceUpdateLifecycleObserver(onResumed);

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ForceUpdateGate(
      lifecycleObserverFactory: _inertObserverFactory,
      child: const _TestChild(),
    ),
  ),
);

/// Pre-canned valid (NoUpdate-for-2.x) cached config used by the
/// invalid-payload fallback scenario.
String _cachedNoUpdateJson() =>
    '{"schema_version":1,"min_version":"1.0.0","recommended_version":"1.0.0",'
    '"maintenance_mode":false,"message_key":"default"}';

/// Pre-canned valid (HardUpdate-for-1.x) cached config used by the
/// offline-block scenario.
String _cachedHardUpdateJson() =>
    '{"schema_version":1,"min_version":"2.0.0","recommended_version":"2.0.0",'
    '"maintenance_mode":false,"message_key":"default"}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    '1. NoUpdate happy path: gate renders child, no banner, no screen',
    (tester) async {
      final h = await _makeContainer(version: Version.parse('2.1.0'));
      addTearDown(h.container.dispose);

      h.adapter.onGet(_configUrl, (server) {
        server.reply(200, _configJson(min: '2.0.0', rec: '2.0.0'));
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      check(find.byKey(const Key('child-ok')).evaluate()).isNotEmpty();
      expect(find.byType(ForceUpdateScreen), findsNothing);
      expect(find.byType(ForceUpdateBanner), findsNothing);

      // No captures (no errors) and no warning-sink records (no failures).
      check(h.reporter.captures).isEmpty();
      check(h.warningSink.records).isEmpty();
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '2. HardUpdate: gate renders blocking screen + tap launches store URL',
    (tester) async {
      final h = await _makeContainer(version: Version.parse('1.0.0'));
      addTearDown(h.container.dispose);

      const storeUrl = 'https://apps.apple.com/app/id000';
      h.adapter.onGet(_configUrl, (server) {
        server.reply(
          200,
          _configJson(
            min: '2.0.0',
            rec: '2.1.0',
            messageKey: 'default',
            updateUrl: storeUrl,
          ),
        );
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      // ForceUpdateScreen is mounted; the child is replaced.
      expect(find.byType(ForceUpdateScreen), findsOneWidget);
      expect(find.byKey(const Key('child-ok')), findsNothing);
      // Hard-update copy from the default messageKey.
      expect(find.text('Update Required'), findsOneWidget);

      // PopScope blocks back: assert canPop is false.
      final popScope = tester.widget<PopScope>(
        find.descendant(
          of: find.byType(ForceUpdateScreen),
          matching: find.byType(PopScope),
        ),
      );
      check(popScope.canPop).isFalse();

      // Tap "Update now" → launcher receives the server-provided URL.
      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();
      check(h.launcher.calls).length.equals(1);
      check(h.launcher.calls.single.toString()).equals(storeUrl);
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '3. Maintenance: gate renders maintenance screen + Retry triggers refresh',
    (tester) async {
      final h = await _makeContainer(version: Version.parse('2.0.0'));
      addTearDown(h.container.dispose);

      h.adapter.onGet(_configUrl, (server) {
        server.reply(
          200,
          _configJson(
            min: '1.0.0',
            rec: '1.0.0',
            maintenance: true,
            messageKey: 'maintenance',
          ),
        );
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      expect(find.byType(ForceUpdateScreen), findsOneWidget);
      expect(find.text('Under Maintenance'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      final getsBeforeRetry = h.counter.gets;

      // Tap retry: controller.refresh() fires a fresh fetch through dio.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Outbound request count strictly increases past the cold-start fetch.
      check(getsBeforeRetry < h.counter.gets).isTrue();
      // Still in maintenance → screen stays mounted.
      expect(find.byType(ForceUpdateScreen), findsOneWidget);

      // Cold start NoUpdate -> Maintenance recorded as a warning breadcrumb.
      final maintenanceCrumb = h.reporter.breadcrumbs.singleWhere(
        (b) => b.message.contains('Maintenance'),
      );
      check(maintenanceCrumb.level).equals(ForceUpdateLogLevel.warning);
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '4. Cached HardUpdate is honored when remote is offline',
    (tester) async {
      final cachedAt = DateTime.now().toUtc().toIso8601String();
      final h = await _makeContainer(
        version: Version.parse('1.0.0'),
        seedPrefs: {
          forceUpdateCacheKey: _cachedHardUpdateJson(),
          forceUpdateLastFetchKey: cachedAt,
        },
      );
      addTearDown(h.container.dispose);

      // Simulate offline: remote throws on every call.
      h.adapter.onGet(_configUrl, (server) {
        server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(path: _configUrl),
            type: DioExceptionType.connectionError,
            error: 'offline',
          ),
        );
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      // Cache-honored HardUpdate keeps the screen up even though the
      // background refresh hit a network error (fail-open contract).
      expect(find.byType(ForceUpdateScreen), findsOneWidget);
      expect(find.byKey(const Key('child-ok')), findsNothing);

      // The warning sink received the fetch failure.
      check(h.warningSink.records).isNotEmpty();
      final hasFetchFailureRecord = h.warningSink.records.any(
        (r) => r.message.contains('fetch failed') && r.error != null,
      );
      check(hasFetchFailureRecord).isTrue();
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '5. Soft -> Hard transition via refresh records a warning breadcrumb',
    (tester) async {
      final h = await _makeContainer(version: Version.parse('2.0.5'));
      addTearDown(h.container.dispose);

      // Use replyCallback so the data callback runs *per request*: the
      // first GET (cold-start background refresh) returns SoftUpdate,
      // subsequent GETs (after explicit refresh) return HardUpdate.
      var requestCount = 0;
      h.adapter.onGet(_configUrl, (server) {
        server.replyCallback(200, (_) {
          requestCount++;
          if (requestCount == 1) {
            return _configJson(min: '1.0.0', rec: '2.1.0');
          }
          return _configJson(min: '2.0.6', rec: '2.1.0');
        });
      });

      await tester.pumpWidget(_wrap(h.container));
      // Cold start: pumpAndSettle drives the background refresh microtask
      // to completion. (See test 1: pumpAndSettle works for the cold path.)
      await tester.pumpAndSettle();

      // Soft state: child rendered with banner on top.
      expect(find.byType(ForceUpdateBanner), findsOneWidget);
      expect(find.byKey(const Key('child-ok')), findsOneWidget);

      h.reporter.breadcrumbs.clear();

      // The explicit refresh() must run under runAsync so Dio's real
      // timer-backed work (sendTimeout / receiveTimeout) can progress;
      // the test's fake clock used by pump() does not advance real timers.
      await tester.runAsync(() async {
        await h.container
            .read(forceUpdateControllerProvider.notifier)
            .refresh();
      });
      // Drain the state-change frame after refresh resolves.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ForceUpdateScreen), findsOneWidget);
      expect(find.byType(ForceUpdateBanner), findsNothing);

      final transition = h.reporter.breadcrumbs.singleWhere(
        (b) =>
            b.message.contains('SoftUpdate') &&
            b.message.contains('HardUpdate'),
      );
      check(transition.level).equals(ForceUpdateLogLevel.warning);
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '6. Invalid remote payload falls back to valid cache; warning sink fires',
    (tester) async {
      // Prime cache with a NoUpdate config so the fallback yields a
      // mounting-the-child outcome.
      final h = await _makeContainer(
        version: Version.parse('2.0.0'),
        seedPrefs: {
          forceUpdateCacheKey: _cachedNoUpdateJson(),
          forceUpdateLastFetchKey: DateTime.now().toUtc().toIso8601String(),
        },
      );
      addTearDown(h.container.dispose);

      // recommended_version below min_version: validator rejects.
      h.adapter.onGet(_configUrl, (server) {
        server.reply(200, _configJson(min: '5.0.0', rec: '1.0.0'));
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('child-ok')), findsOneWidget);
      expect(find.byType(ForceUpdateScreen), findsNothing);
      expect(find.byType(ForceUpdateBanner), findsNothing);

      // Validation failure surfaced as a warning with no error object
      // (it is a rejection, not an exception).
      final rejection = h.warningSink.records.singleWhere(
        (r) => r.message.contains('rejected'),
      );
      check(rejection.error).isNull();
    },
    timeout: _testTimeout,
  );

  testWidgets(
    '7. Unknown schemaVersion (no cache) fails open and renders child',
    (tester) async {
      final h = await _makeContainer(version: Version.parse('2.0.0'));
      addTearDown(h.container.dispose);

      h.adapter.onGet(_configUrl, (server) {
        server.reply(
          200,
          _configJson(schemaVersion: 999, min: '2.0.0', rec: '2.0.0'),
        );
      });

      await tester.pumpWidget(_wrap(h.container));
      await tester.pumpAndSettle();

      // Fail-open: child renders, no blocking UI.
      expect(find.byKey(const Key('child-ok')), findsOneWidget);
      expect(find.byType(ForceUpdateScreen), findsNothing);
      expect(find.byType(ForceUpdateBanner), findsNothing);

      // The repository routed the schema-version rejection to the sink.
      final rejection = h.warningSink.records.singleWhere(
        (r) => r.message.contains('rejected'),
      );
      check(rejection.error).isNull();
    },
    timeout: _testTimeout,
  );
}
