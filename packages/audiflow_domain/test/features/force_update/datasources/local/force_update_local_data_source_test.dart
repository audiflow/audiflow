import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/force_update/datasources/local/force_update_local_data_source.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ForceUpdateLocalDataSource ds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    ds = ForceUpdateLocalDataSource(prefs);
  });

  test('returns null when no cached value', () async {
    check(await ds.read()).isNull();
    check(ds.lastFetchAt()).isNull();
  });

  test('round-trips a stored config', () async {
    const cfg = ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '2.0.0',
      recommendedVersion: '2.1.0',
      maintenanceMode: false,
      messageKey: 'default',
    );

    await ds.write(cfg, fetchedAt: DateTime.utc(2026, 5, 4, 12));

    final read = await ds.read();
    check(read).equals(cfg);
    check(ds.lastFetchAt()).equals(DateTime.utc(2026, 5, 4, 12));
  });

  test('discards corrupt cache and returns null', () async {
    await prefs.setString(forceUpdateCacheKey, 'not json');
    check(await ds.read()).isNull();
    check(prefs.getString(forceUpdateCacheKey)).isNull();
  });

  test('clears cached state', () async {
    const cfg = ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '2.0.0',
      recommendedVersion: '2.1.0',
      maintenanceMode: false,
      messageKey: 'default',
    );
    await ds.write(cfg, fetchedAt: DateTime.utc(2026, 5, 4));

    await ds.clear();

    check(await ds.read()).isNull();
    check(ds.lastFetchAt()).isNull();
  });
}
