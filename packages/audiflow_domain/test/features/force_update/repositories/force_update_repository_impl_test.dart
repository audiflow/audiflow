import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/force_update/datasources/local/force_update_local_data_source.dart';
import 'package:audiflow_domain/src/features/force_update/datasources/remote/force_update_remote_data_source.dart';
import 'package:audiflow_domain/src/features/force_update/repositories/force_update_repository_impl.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

ForceUpdateConfig _validCfg() => const ForceUpdateConfig(
  schemaVersion: 1,
  minVersion: '2.0.0',
  recommendedVersion: '2.1.0',
  maintenanceMode: false,
  messageKey: 'default',
);

Map<String, Object?> _validJson() => const <String, Object?>{
  'schema_version': 1,
  'min_version': '2.0.0',
  'recommended_version': '2.1.0',
  'maintenance_mode': false,
  'message_key': 'default',
};

Map<String, Object?> _invalidJson() => const <String, Object?>{
  // recommended < min triggers configValidationFailure
  'schema_version': 1,
  'min_version': '3.0.0',
  'recommended_version': '2.0.0',
  'maintenance_mode': false,
  'message_key': 'default',
};

void main() {
  const url = 'https://example.com/app_config.json';
  late SharedPreferences prefs;
  late ForceUpdateLocalDataSource local;
  late Dio dio;
  late DioAdapter adapter;
  late ForceUpdateRemoteDataSource remote;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = ForceUpdateLocalDataSource(prefs);
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    remote = ForceUpdateRemoteDataSource(dio: dio, configUrl: url);
  });

  test('successful fetch caches and returns config', () async {
    adapter.onGet(url, (server) => server.reply(200, _validJson()));
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(_validCfg());
    check(await local.read()).equals(_validCfg());
    check(local.lastFetchAt()).isNotNull();
  });

  test('fetch fails, no cache: returns null (fail-open)', () async {
    adapter.onGet(url, (server) => server.reply(500, ''));
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).isNull();
  });

  test('fetch fails, cache exists: returns cached config', () async {
    await local.write(_validCfg(), fetchedAt: DateTime.utc(2026, 1, 1));
    adapter.onGet(url, (server) => server.reply(500, ''));
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(_validCfg());
  });

  test('invalid remote payload + no cache → null, cache untouched', () async {
    adapter.onGet(url, (server) => server.reply(200, _invalidJson()));
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).isNull();
    check(await local.read()).isNull();
  });

  test('invalid remote payload falls back to cached valid config', () async {
    await local.write(_validCfg(), fetchedAt: DateTime.utc(2026, 1, 1));
    adapter.onGet(url, (server) => server.reply(200, _invalidJson()));
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(_validCfg());
  });

  test('readCachedOnly returns cached without touching network', () async {
    await local.write(_validCfg(), fetchedAt: DateTime.utc(2026, 1, 1));
    // No adapter handler registered: a network call would throw.
    final repo = ForceUpdateRepositoryImpl(remote: remote, local: local);

    final result = await repo.readCachedOnly();

    check(result).equals(_validCfg());
  });

  test('warning sink fires on remote failure', () async {
    adapter.onGet(url, (server) => server.reply(500, ''));
    final warnings = <String>[];
    final repo = ForceUpdateRepositoryImpl(
      remote: remote,
      local: local,
      onWarning: (msg, {error, stackTrace}) => warnings.add(msg),
    );

    await repo.refresh();

    check(warnings).single.equals('Force-update fetch failed');
  });
}
