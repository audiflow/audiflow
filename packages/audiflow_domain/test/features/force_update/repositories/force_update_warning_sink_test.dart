import 'package:audiflow_domain/src/features/force_update/datasources/local/force_update_local_data_source.dart';
import 'package:audiflow_domain/src/features/force_update/datasources/remote/force_update_remote_data_source.dart';
import 'package:audiflow_domain/src/features/force_update/repositories/force_update_repository_impl.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records every sink invocation so we can assert exactly-once behavior
/// and inspect the error payload that the app-side override would
/// forward to Sentry.
class _RecordingSink {
  final List<({String message, Object? error, StackTrace? stackTrace})> events =
      [];

  void call(String message, {Object? error, StackTrace? stackTrace}) {
    events.add((message: message, error: error, stackTrace: stackTrace));
  }
}

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

  test(
    'sink invoked exactly once with error payload on transport failure',
    () async {
      adapter.onGet(url, (server) => server.reply(500, ''));
      final sink = _RecordingSink();
      final repo = ForceUpdateRepositoryImpl(
        remote: remote,
        local: local,
        onWarning: sink.call,
      );

      await repo.refresh();

      check(sink.events).length.equals(1);
      check(sink.events.single.message).equals('Force-update fetch failed');
      // App-side override needs the error to forward to Sentry; verify it
      // is non-null on the transport failure path.
      check(sink.events.single.error).isNotNull();
    },
  );

  test('sink invoked once on invalid payload (no error attached)', () async {
    adapter.onGet(url, (server) => server.reply(200, _invalidJson()));
    final sink = _RecordingSink();
    final repo = ForceUpdateRepositoryImpl(
      remote: remote,
      local: local,
      onWarning: sink.call,
    );

    await repo.refresh();

    check(sink.events).length.equals(1);
    check(sink.events.single.message).contains('rejected');
    // Validation failure carries no exception — app-side logic should
    // log it but skip the Sentry capture branch.
    check(sink.events.single.error).isNull();
  });
}
