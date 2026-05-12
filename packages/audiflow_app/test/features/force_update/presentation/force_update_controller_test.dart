import 'package:audiflow_app/features/force_update/presentation/force_update_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

/// Hand-rolled fake repository to avoid codegen mocks (per project rules).
///
/// Configure [cached] / [next] before `refresh()` is called, and override
/// [refreshThrows] to simulate a transient error. The repository's
/// fail-open contract is preserved: a thrown error never propagates,
/// instead [refresh] returns the last cached value.
class _FakeRepository implements ForceUpdateRepository {
  ForceUpdateConfig? cached;
  ForceUpdateConfig? next;
  bool refreshThrows = false;
  DateTime? _lastFetchAt;

  int refreshCalls = 0;

  void setNow(DateTime when) => _lastFetchAt = when;

  @override
  Future<ForceUpdateConfig?> refresh() async {
    refreshCalls++;
    if (refreshThrows) return cached;
    if (next != null) {
      cached = next;
      _lastFetchAt = DateTime.now().toUtc();
    }
    return cached;
  }

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async => cached;

  @override
  DateTime? lastFetchAt() => _lastFetchAt;
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
  required _FakeRepository repo,
  required Version version,
}) {
  return ProviderContainer(
    overrides: [
      forceUpdateRepositoryProvider.overrideWith((ref) => repo),
      currentAppVersionProvider.overrideWith((ref) async => version),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'cold start with no cache emits NoUpdate then refresh fetches',
    () async {
      final repo = _FakeRepository()
        ..next = _config(min: '2.0.0', rec: '2.1.0');
      final container = _container(repo: repo, version: Version.parse('2.0.5'));
      addTearDown(container.dispose);

      final first = await container.read(forceUpdateControllerProvider.future);
      check(first).isA<NoUpdate>();

      // Allow the background refresh microtask + async work to run.
      await Future<void>.delayed(Duration.zero);
      await container.read(forceUpdateControllerProvider.future);

      check(repo.refreshCalls).equals(1);
      final settled = container.read(forceUpdateControllerProvider).value!;
      check(settled).isA<SoftUpdate>();
    },
  );

  test(
    'cold start with cached hard-update is honored before network',
    () async {
      final repo = _FakeRepository()
        ..cached = _config(min: '3.0.0', rec: '3.1.0');
      final container = _container(repo: repo, version: Version.parse('2.0.0'));
      addTearDown(container.dispose);

      final initial = await container.read(
        forceUpdateControllerProvider.future,
      );

      // Offline-block honored: HardUpdate emitted from the cache without
      // waiting for the network round trip.
      check(initial).isA<HardUpdate>();
    },
  );

  test(
    'refresh transitions soft -> hard when remote tightens minVersion',
    () async {
      final repo = _FakeRepository()
        ..cached = _config(min: '1.0.0', rec: '2.1.0'); // soft @ 2.0.5
      final container = _container(repo: repo, version: Version.parse('2.0.5'));
      addTearDown(container.dispose);

      final first = await container.read(forceUpdateControllerProvider.future);
      check(first).isA<SoftUpdate>();

      // Server bumps minVersion above current => hard update on next fetch.
      repo.next = _config(min: '2.0.6', rec: '2.1.0');

      await container.read(forceUpdateControllerProvider.notifier).refresh();

      final after = container.read(forceUpdateControllerProvider).value!;
      check(after).isA<HardUpdate>();
    },
  );

  test('refresh failure preserves current decision', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final container = _container(repo: repo, version: Version.parse('2.0.5'));
    addTearDown(container.dispose);

    final before = await container.read(forceUpdateControllerProvider.future);
    check(before).isA<SoftUpdate>();

    repo.refreshThrows = true;

    await container.read(forceUpdateControllerProvider.notifier).refresh();

    final after = container.read(forceUpdateControllerProvider).value!;
    check(after).isA<SoftUpdate>();
  });

  test('maintenance flag yields Maintenance regardless of version', () async {
    final repo = _FakeRepository()
      ..cached = _config(
        min: '1.0.0',
        rec: '1.0.0',
        maintenance: true,
        key: 'maintenance',
      );
    final container = _container(repo: repo, version: Version.parse('999.0.0'));
    addTearDown(container.dispose);

    final result = await container.read(forceUpdateControllerProvider.future);
    check(result).isA<Maintenance>();
  });

  test('refreshIfStale is a no-op when lastFetchAt is fresh', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0')
      // Set `next` so the fake's `refresh()` contract is exercised and
      // stamps `_lastFetchAt` from the background refresh.
      ..next = _config(min: '1.0.0', rec: '2.1.0');
    final container = _container(repo: repo, version: Version.parse('2.0.5'));
    addTearDown(container.dispose);

    await container.read(forceUpdateControllerProvider.future);
    // Allow background refresh to run and increment refreshCalls.
    await Future<void>.delayed(Duration.zero);
    await container.read(forceUpdateControllerProvider.future);
    final baseline = repo.refreshCalls;
    // Sanity check: the background refresh stamped lastFetchAt; the
    // staleness check below is meaningful only if this is non-null.
    check(repo.lastFetchAt()).isNotNull();

    await container
        .read(forceUpdateControllerProvider.notifier)
        .refreshIfStale();

    check(repo.refreshCalls).equals(baseline);
  });

  test('refreshIfStale calls refresh when lastFetchAt is null', () async {
    final repo = _FakeRepository()
      ..cached = _config(min: '1.0.0', rec: '2.1.0');
    final container = _container(repo: repo, version: Version.parse('2.0.5'));
    addTearDown(container.dispose);

    await container.read(forceUpdateControllerProvider.future);
    // Wait for the build-time background microtask to settle. The fake
    // leaves `lastFetchAt` null because `next` is unset, so the cold
    // start path through refreshIfStale must call refresh().
    await Future<void>.delayed(Duration.zero);
    await container.read(forceUpdateControllerProvider.future);
    check(repo.lastFetchAt()).isNull();
    final baseline = repo.refreshCalls;

    await container
        .read(forceUpdateControllerProvider.notifier)
        .refreshIfStale();

    check(repo.refreshCalls).equals(baseline + 1);
  });
}
