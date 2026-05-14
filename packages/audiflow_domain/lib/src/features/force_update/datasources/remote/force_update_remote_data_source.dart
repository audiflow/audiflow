import 'package:dio/dio.dart';

import '../../constants.dart';
import '../../models/force_update_config.dart';

/// Fetches the force-update config JSON from a static URL.
///
/// Network failures bubble as [DioException]; payload shape mismatches
/// surface as [FormatException]. Configuration mistakes (empty URL)
/// throw [StateError] to fail loudly during boot.
class ForceUpdateRemoteDataSource {
  const ForceUpdateRemoteDataSource({
    required Dio dio,
    required String configUrl,
  }) : _dio = dio,
       _url = configUrl;

  final Dio _dio;
  final String _url;

  Future<ForceUpdateConfig> fetch() async {
    if (_url.isEmpty) {
      throw StateError('FORCE_UPDATE_CONFIG_URL is not configured');
    }

    final response = await _dio.get<Object?>(
      _url,
      options: Options(
        responseType: ResponseType.json,
        sendTimeout: forceUpdateFetchTimeout,
        receiveTimeout: forceUpdateFetchTimeout,
      ),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException(
        'Expected JSON object from force-update config; got ${data.runtimeType}',
      );
    }
    return ForceUpdateConfig.fromJson(data);
  }
}
