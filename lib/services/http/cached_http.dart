import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';

// part 'cached_http.g.dart';

// @Riverpod(keepAlive: true)
// CachedHttp cachedHttp(CachedHttpRef ref) => CachedHttp();

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
          'User-Agent':
              'podcast_search/0.4.0 https://github.com/reedom/audiflow',
        },
        validateStatus: (status) => status != null && status < 400,
      ),
    )
      ..interceptors.add(LogInterceptor())
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  late final Dio dio;
  late final CacheOptions cacheOptions;

  Future<T?> fetch<T>(
    String uri, {
    bool loadFromCache = true,
    ResponseType responseType = ResponseType.json,
  }) async {
    final policy = loadFromCache ? CachePolicy.request : CachePolicy.refresh;
    final options = cacheOptions
        .copyWith(policy: policy)
        .toOptions()
        .copyWith(responseType: responseType);
    final res = await dio.get<T>(uri, options: options);
    return res.data;
  }
}
