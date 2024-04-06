//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_isar_store/dio_cache_interceptor_isar_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cached_http.g.dart';

@Riverpod(keepAlive: true)
CachedHttp cachedHttp(CachedHttpRef ref) => CachedHttp();

class CachedHttp {
  late Dio dio;
  late CacheOptions cacheOptions;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final dir = await getApplicationDocumentsDirectory();
    cacheOptions = CacheOptions(
      store: IsarCacheStore(dir.path),

      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors
      // (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is
      // desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
    );

    // Add cache interceptor with global/default options
    dio = Dio(
      BaseOptions(
        headers: {
          'User-Agent':
              'podcast_search/0.4.0 https://github.com/amugofjava/anytime_podcast_player',
        },
      ),
    )
      ..interceptors.add(LogInterceptor())
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<dynamic> fetch(
    String uri, {
    bool loadFromCache = true,
    ResponseType responseType = ResponseType.json,
  }) async {
    final policy = loadFromCache ? CachePolicy.request : CachePolicy.refresh;
    final options = cacheOptions
        .copyWith(policy: policy)
        .toOptions()
        .copyWith(responseType: responseType);
    final res = await dio.get<dynamic>(uri, options: options);
    return res.data;
  }
}
