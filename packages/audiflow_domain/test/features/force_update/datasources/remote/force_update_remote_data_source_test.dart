import 'package:audiflow_domain/src/features/force_update/datasources/remote/force_update_remote_data_source.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ForceUpdateRemoteDataSource ds;
  const url = 'https://example.com/app_config.json';

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    ds = ForceUpdateRemoteDataSource(dio: dio, configUrl: url);
  });

  test('returns parsed config on 200', () async {
    adapter.onGet(url, (server) {
      server.reply(200, {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': false,
        'message_key': 'default',
      });
    });

    final cfg = await ds.fetch();

    check(cfg.minVersion).equals('2.0.0');
    check(cfg.recommendedVersion).equals('2.1.0');
    check(cfg.messageKey).equals('default');
  });

  test('throws DioException on non-200', () async {
    adapter.onGet(url, (server) => server.reply(500, ''));

    await check(ds.fetch()).throws<DioException>();
  });

  test('throws on payload that is not a JSON object', () async {
    adapter.onGet(url, (server) => server.reply(200, [1, 2, 3]));

    await check(ds.fetch()).throws<FormatException>();
  });

  test('throws StateError when configUrl is empty', () async {
    final empty = ForceUpdateRemoteDataSource(dio: dio, configUrl: '');
    await check(empty.fetch()).throws<StateError>();
  });
}
