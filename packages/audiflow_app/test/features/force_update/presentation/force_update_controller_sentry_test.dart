import 'package:audiflow_app/features/force_update/force_update.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

/// Records every breadcrumb / capture the controller produces so the
/// test can assert without running the real Sentry SDK.
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

class _FakeRepository implements ForceUpdateRepository {
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

/// Repository that throws on refresh — exercises the controller-level
/// catch path so we can assert capture-on-throw behavior.
class _ThrowingRepository implements ForceUpdateRepository {
  ForceUpdateConfig? cached;

  @override
  Future<ForceUpdateConfig?> refresh() async {
    throw StateError('boom');
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

ProviderContainer _container({
  required ForceUpdateRepository repo,
  required _RecordingReporter reporter,
  required Version version,
}) {
  return ProviderContainer(
    overrides: [
      forceUpdateRepositoryProvider.overrideWith((ref) => repo),
      currentAppVersionProvider.overrideWith((ref) async => version),
      forceUpdateReporterProvider.overrideWith((ref) => reporter),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('soft -> hard transition records a warning-level breadcrumb', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final reporter = _RecordingReporter();
    final container = _container(
      repo: repo,
      reporter: reporter,
      version: Version.parse('2.0.5'),
    );
    addTearDown(container.dispose);

    // Cold start: SoftUpdate from cache. No breadcrumb yet — those are
    // only recorded on transitions during refresh.
    final before = await container.read(forceUpdateControllerProvider.future);
    check(before).isA<SoftUpdate>();
    check(reporter.breadcrumbs).isEmpty();

    // Server tightens minVersion above current => hard update.
    repo.next = _config(min: '2.0.6', rec: '2.1.0');
    await container.read(forceUpdateControllerProvider.notifier).refresh();

    check(reporter.breadcrumbs).length.equals(1);
    final crumb = reporter.breadcrumbs.single;
    check(crumb.level).equals(ForceUpdateLogLevel.warning);
    check(crumb.message).contains('SoftUpdate');
    check(crumb.message).contains('HardUpdate');
  });

  test('no breadcrumb when the decision is unchanged', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final reporter = _RecordingReporter();
    final container = _container(
      repo: repo,
      reporter: reporter,
      version: Version.parse('2.0.5'),
    );
    addTearDown(container.dispose);

    await container.read(forceUpdateControllerProvider.future);

    // Server returns the same decision shape: no transition, no crumb.
    repo.next = _config(min: '1.0.0', rec: '2.1.0');
    await container.read(forceUpdateControllerProvider.notifier).refresh();

    check(reporter.breadcrumbs).isEmpty();
  });

  test('maintenance decision uses warning level', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final reporter = _RecordingReporter();
    final container = _container(
      repo: repo,
      reporter: reporter,
      version: Version.parse('2.0.5'),
    );
    addTearDown(container.dispose);

    await container.read(forceUpdateControllerProvider.future);

    repo.next = _config(
      min: '1.0.0',
      rec: '2.1.0',
      maintenance: true,
      key: 'maintenance',
    );
    await container.read(forceUpdateControllerProvider.notifier).refresh();

    check(reporter.breadcrumbs).length.equals(1);
    check(
      reporter.breadcrumbs.single.level,
    ).equals(ForceUpdateLogLevel.warning);
  });

  test(
    'controller does not capture for transitions on the happy path',
    () async {
      final repo = _FakeRepository()
        ..cached = _config(min: '1.0.0', rec: '2.1.0');
      final reporter = _RecordingReporter();
      final container = _container(
        repo: repo,
        reporter: reporter,
        version: Version.parse('2.0.5'),
      );
      addTearDown(container.dispose);

      await container.read(forceUpdateControllerProvider.future);
      repo.next = _config(min: '2.0.6', rec: '2.1.0');
      await container.read(forceUpdateControllerProvider.notifier).refresh();

      // Successful refresh path only produces breadcrumbs; the
      // controller-level captureException is reserved for the catch path.
      check(reporter.captures).isEmpty();
    },
  );

  test('captureException is called when repo.refresh throws', () async {
    final repo = _ThrowingRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final reporter = _RecordingReporter();
    final container = _container(
      repo: repo,
      reporter: reporter,
      version: Version.parse('2.0.5'),
    );
    addTearDown(container.dispose);

    await container.read(forceUpdateControllerProvider.future);
    await container.read(forceUpdateControllerProvider.notifier).refresh();

    check(reporter.captures).length.equals(1);
    check(reporter.captures.single.error).isA<StateError>();
    check(reporter.captures.single.message).equals('ForceUpdate refresh threw');
  });
}
