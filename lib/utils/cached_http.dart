import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:sentry_dio/sentry_dio.dart';

class CachedHttp {
  CachedHttp(String cacheDir) {
    cacheOptions = CacheOptions(
      store: FileCacheStore(cacheDir),

      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors
      // (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour
      // is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
    );

    // Add cache interceptor with global/default options
    dio = Dio(
      BaseOptions(
        headers: {
          'User-Agent': 'github.com/reedom/audiflow',
        },
        validateStatus: (status) => status != null && status < 400,
        connectTimeout: const Duration(seconds: 3),
      ),
    )
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
      ..interceptors.add(LogInterceptor());
    dio.addSentry();
  }

  late final Dio dio;
  late final CacheOptions cacheOptions;

  Future<T?> fetch<T>(
    String uri, {
    bool loadFromCache = true,
    ResponseType responseType = ResponseType.json,
  }) async {
    for (var i = 1; i <= 3; ++i) {
      try {
        final policy =
            loadFromCache ? CachePolicy.request : CachePolicy.refresh;
        final options = cacheOptions
            .copyWith(policy: policy)
            .toOptions()
            .copyWith(responseType: responseType);
        final res = await dio.get<T>(uri, options: options);
        return res.data;
      } on DioException catch (err) {
        if (err.type != DioExceptionType.connectionTimeout) {
          logger.e('Dio error: $err');
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 300 * i));
      }
    }
    throw const NetworkTimeoutException();
  }
}
